//
// --------------------------------------------------------------------------
// MoreSheet.m
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2019
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import "MoreSheet.h"
#import "ConfigFileInterface_App.h"
#import "MessagePort_App.h"
#import "AppDelegate.h"
#import "Utility_App.h"
#import "Locator.h"


@interface MoreSheet ()
@property (strong) IBOutlet NSPanel *sheetPanel; // TODO: Remove. This should be the same as the automatically generated _window property.
@property (weak) IBOutlet NSTextField *versionLabel;
@property (weak) IBOutlet NSButton *doneButton;
@end

@implementation MoreSheet

#pragma mark - Constants

#pragma mark - Static stuff

+ (void)load {
    _instance = [[MoreSheet alloc] initWithWindowNibName:@"MoreSheet"];
}
static MoreSheet *_instance;
+ (MoreSheet *)instance {
    return _instance;
}

# pragma mark - IBActions

- (IBAction)appOverrideButton:(id)sender {
    [OverridePanel.instance begin];
}
- (IBAction)doneButton:(id)sender {
    [self end];
}

//- (void)mouseDown:(NSEvent *)event {
//    NSLog(@"mousduunsn");
//    
//    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
//    [AppDelegate.mainView.window makeFirstResponder:NULL];
//    [_sheetPanel makeKeyWindow];
//    [_sheetPanel makeFirstResponder:NULL];
//}

#pragma mark - Class methods - Public


#pragma mark - Instance methods - Public

- (void)begin {
    [AppDelegate.mainWindow beginSheet:self.window completionHandler:nil];
    [self.window makeKeyWindow]; // Doesn't work
    
}
- (void)end {
    [AppDelegate.mainWindow endSheet:self.window];
//    [[[NSApplication sharedApplication] mainWindow] endSheet:self.window]; // There is no main window when the app isn't frontmost...
//    [ScrollOverridePanel.instance close];
}

#pragma mark - Instance methods - Private

- (void)windowDidLoad {
    [super windowDidLoad];
    [self updateUI];
    if (@available(macOS 26.0, *))
        self.window.contentView.prefersCompactControlSizeMetrics = YES; /// [Aug 2025] You can set this NO or YES – both look wrong size next to the 'Buy me a milkshake' button.
}

- (void)updateUI {
    
    /// Load version label
    NSString *versionString = [NSString stringWithFormat:@"Version %@ (%ld)",
                               (NSString *)Locator.bundleVersionShort,
                               (long)Locator.bundleVersion];
    [self.versionLabel setStringValue:versionString];
    
}

@end
