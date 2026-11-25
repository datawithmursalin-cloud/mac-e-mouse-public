//
// --------------------------------------------------------------------------
// VectorSubPixelator.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2020
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "VectorSubPixelator.h"
#import "SubPixelator.h"

@implementation VectorSubPixelator {
    SubPixelator *_spX;
    SubPixelator *_spY;
}

+ (VectorSubPixelator *) pixelator {
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _spX = [SubPixelator pixelator];
        _spY = [SubPixelator pixelator];
    }
    return self;
}

- (MFVector)intVectorWithDoubleVector:(MFVector)inpVec {
    inpVec.x = [_spX intDeltaWithDoubleDelta:inpVec.x];
    inpVec.y = [_spY intDeltaWithDoubleDelta:inpVec.y];
    return inpVec;
}

@end
