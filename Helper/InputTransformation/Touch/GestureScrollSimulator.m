//
// --------------------------------------------------------------------------
// GestureScrollSimulator.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2020
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "GestureScrollSimulator.h"
#import <QuartzCore/QuartzCore.h>
#import <Cocoa/Cocoa.h>
#import "VectorSubPixelator.h"

@implementation GestureScrollSimulator

static const double dragSmoothingTime = 0.014;

static CADisplayLink *_displayLink API_AVAILABLE(macos(14.0));
static NSTimer *_fallbackTimer;
static CGPoint _location;
static MFVector _pendingDrag;
static BOOL _gestureActive;
static CFTimeInterval _lastFrameTime;
static VectorSubPixelator *_linePixelator;

static MFVector scaled(MFVector vector, double factor) {
    return (MFVector){vector.x * factor, vector.y * factor};
}

static MFVector wholePoints(MFVector vector) {
    return (MFVector){round(vector.x), round(vector.y)};
}

static BOOL hasMovement(MFVector vector) {
    return vector.x != 0 || vector.y != 0;
}

static void postScroll(MFVector points, IOHIDEventPhaseBits phase, CGMomentumScrollPhase momentum) {
    // Precise and gesture deltas share the same whole points. Legacy line deltas
    // carry their own fractional remainder.
    MFVector lines = [_linePixelator intVectorWithDoubleVector:scaled(points, 0.1)];
    [GestureScrollSimulator postGestureScrollEventWithGestureVector:points
                                                        scrollVector:lines
                                                   scrollVectorPoint:points
                                                               phase:phase
                                                       momentumPhase:momentum
                                                            location:_location];
}

static void startFrameUpdates(void) {
    if (@available(macOS 14.0, *)) {
        if (_displayLink != nil) return;
        CGDirectDisplayID display = 0;
        uint32_t count = 0;
        CGGetDisplaysWithPoint(_location, 1, &display, &count);
        for (NSScreen *screen in NSScreen.screens) {
            if (count && [screen.deviceDescription[@"NSScreenNumber"] unsignedIntValue] == display) {
                _displayLink = [screen displayLinkWithTarget:GestureScrollSimulator.class selector:@selector(displayFrame:)];
                [_displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
                return;
            }
        }
    }
    if (_fallbackTimer != nil) return;
    _fallbackTimer = [NSTimer timerWithTimeInterval:1.0 / 60.0 target:GestureScrollSimulator.class
                                          selector:@selector(timerFrame:) userInfo:nil repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:_fallbackTimer forMode:NSRunLoopCommonModes];
}

static void stopFrameUpdates(void) {
    if (@available(macOS 14.0, *)) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    [_fallbackTimer invalidate];
    _fallbackTimer = nil;
}

+ (void)postGestureScrollEventWithDeltaX:(double)dx deltaY:(double)dy phase:(IOHIDEventPhaseBits)phase location:(CGPoint)location {
    if (phase == kIOHIDEventPhaseBegan) {
        if (dx == 0 && dy == 0) return;
        _gestureActive = YES;
        _location = location;
        _lastFrameTime = CACurrentMediaTime();
        _linePixelator = [VectorSubPixelator pixelator];

        // Start with one point and settle any threshold movement while held.
        MFVector first = wholePoints(scaled((MFVector){dx, dy}, 1.0 / fmax(fabs(dx), fabs(dy))));
        _pendingDrag = (MFVector){dx - first.x, dy - first.y};
        postScroll(first, kIOHIDEventPhaseBegan, kCGMomentumScrollPhaseNone);
        startFrameUpdates();
    } else if (_gestureActive && phase == kIOHIDEventPhaseEnded) {
        _gestureActive = NO;
        stopFrameUpdates();
        _pendingDrag = (MFVector){};
        postScroll((MFVector){}, kIOHIDEventPhaseEnded, kCGMomentumScrollPhaseNone);
        // Some apps start their own inertia when a gesture ends. Explicitly
        // end momentum so the drag stops at the release position.
        postScroll((MFVector){}, kIOHIDEventPhaseUndefined, kCGMomentumScrollPhaseEnd);
    } else if (_gestureActive && phase == kIOHIDEventPhaseChanged) {
        _pendingDrag.x += dx;
        _pendingDrag.y += dy;
    }
}

+ (void)displayFrame:(CADisplayLink *)link API_AVAILABLE(macos(14.0)) {
    advanceFrame(CACurrentMediaTime());
}

+ (void)timerFrame:(NSTimer *)timer {
    advanceFrame(CACurrentMediaTime());
}

static void advanceFrame(CFTimeInterval now) {
    if (!_gestureActive || now <= _lastFrameTime) return;
    double elapsed = fmin(now - _lastFrameTime, 1.0 / 30.0);
    _lastFrameTime = now;
    MFVector output = wholePoints(scaled(_pendingDrag, -expm1(-elapsed / dragSmoothingTime)));
    // Emit a pending whole point even if the exponential step rounds to zero.
    if (output.x == 0 && fabs(_pendingDrag.x) > 0.5) output.x = copysign(1, _pendingDrag.x);
    if (output.y == 0 && fabs(_pendingDrag.y) > 0.5) output.y = copysign(1, _pendingDrag.y);
    _pendingDrag.x -= output.x;
    _pendingDrag.y -= output.y;
    if (hasMovement(output)) {
        postScroll(output, kIOHIDEventPhaseChanged, kCGMomentumScrollPhaseNone);
    }
}

// Emit the scroll-wheel and companion gesture events for a simulated trackpad.
+ (void)postGestureScrollEventWithGestureVector:(MFVector)vecGesture
                                   scrollVector:(MFVector)vecScroll
                              scrollVectorPoint:(MFVector)vecScrollPoint
                                          phase:(IOHIDEventPhaseBits)phase
                                  momentumPhase:(CGMomentumScrollPhase)momentumPhase
                                      location:(CGPoint)loc {
    
    
//    printf("Posting gesture scroll event with delta values:\n");
//    printf("gesture: x:%f y:%f \nscroll: x:%f y:%f \nscrollPt: x:%f y:%f\n",
//          vecGesture.x, vecGesture.y, vecScroll.x, vecScroll.y, vecScrollPoint.x, vecScrollPoint.y);
    
    //
    // Create type 22 event
    //
    
    CGEventRef e22 = CGEventCreate(NULL);
    
    // Set static fields
    
    CGEventSetDoubleValueField(e22, 55, 22); // 22 -> NSEventTypeScrollWheel // Setting field 55 is the same as using CGEventSetType(), I'm not sure if that has weird side-effects though, so I'd rather do it this way.
    CGEventSetDoubleValueField(e22, 88, 1); // magic?
    
    // Set dynamic fields
    
    // Scroll deltas
    
    CGEventSetDoubleValueField(e22, kCGScrollWheelEventDeltaAxis1, floor(vecScroll.y));
    CGEventSetDoubleValueField(e22, kCGScrollWheelEventPointDeltaAxis1, round(vecScrollPoint.y));
    
    CGEventSetDoubleValueField(e22, kCGScrollWheelEventDeltaAxis2, floor(vecScroll.x));
    CGEventSetDoubleValueField(e22, kCGScrollWheelEventPointDeltaAxis2, round(vecScrollPoint.x));
    
    // Phase
    
    CGEventSetDoubleValueField(e22, 99, phase);
    CGEventSetDoubleValueField(e22, 123, momentumPhase);
    
    CGEventSetLocation(e22, loc);
    CGEventPost(kCGHIDEventTap, e22);
    CFRelease(e22);
    
    if (momentumPhase == 0) {
        
        //
        // Create type 29 subtype 6 event
        //
        
        CGEventRef e29 = CGEventCreate(NULL);
        
        // Set static fields
        
        CGEventSetDoubleValueField(e29, 55, 29); // 29 -> NSEventTypeGesture // Setting field 55 is the same as using CGEventSetType()
        CGEventSetDoubleValueField(e29, 110, 6); // Field 110 -> subtype // 6 -> kIOHIDEventTypeScroll
        
        // Set dynamic fields
        
        double xVec = (double)vecGesture.x;
        if (xVec == 0) {
            xVec = -0.0f; // The original events only contain -0 but this probs doesn't make a difference.
        }
        CGEventSetDoubleValueField(e29, 116, xVec);
        
        double yVec = (double)vecGesture.y;
        if (yVec == 0) {
            yVec = -0.0f; // The original events only contain -0 but this probs doesn't make a difference.
        }
        CGEventSetDoubleValueField(e29, 119, yVec);
        
        CGEventSetIntegerValueField(e29, 132, phase);
        
        // Post t29s6 events
        CGEventSetLocation(e29, loc);
        CGEventPost(kCGHIDEventTap, e29);
        //    printEvent(e29);
        CFRelease(e29);
    }
}

@end
