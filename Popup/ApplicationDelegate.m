#import "ApplicationDelegate.h"
#import "DDHotKeyCenter.h"

@implementation ApplicationDelegate

@synthesize panelController = _panelController;
@synthesize menubarController = _menubarController;

#pragma mark -

- (void)dealloc
{
    [_panelController removeObserver:self forKeyPath:@"hasActivePanel"];
}

#pragma mark -

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSApplicationDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    self.menubarController.hasActiveIcon = YES;
    self.panelController.hasActivePanel = YES;
    [_panelController openConnectTabEvenIfOnComposePage:NO withHiddenWebview:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

    // Install icon into the menu bar
    self.menubarController = [[MenubarController alloc] init];
    _panelController = [self panelController];
    
	DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
	[c registerHotKeyWithKeyCode:kVK_ANSI_B modifierFlags:(NSControlKeyMask|NSShiftKeyMask) target:self action:@selector(hotkeyWithEvent:) object:nil];

    [self checkUpdates:NO];
}

- (void)checkUpdates:(BOOL)shouldTerminate
{
    dispatch_queue_t queue = dispatch_get_global_queue(0,0);
    dispatch_async(queue,^{
        NSLog(@"checking for updates");
        NSLog(@"my version is %d", VERSION);

        int theirVersion = [[self unixSinglePathCommandWithReturn:@"curl -s https://raw.github.com/soheil/BirdDrop-OSX/master/version.txt"] intValue];
        NSLog(@"their version is %d", theirVersion);

        if (theirVersion > VERSION) {
            system("rm -rf /tmp/b.dmg >> /tmp/birddrop.log; hdiutil detach /Volumes/BirdDrop >> /tmp/birddrop.log; curl -o /tmp/b.dmg https://raw.github.com/soheil/BirdDrop-OSX/master/BirdDrop.dmg >> /tmp/birddrop.log; hdiutil attach -nobrowse /tmp/b.dmg >> /tmp/birddrop.log; rm -rf /Applications/BirdDrop.app >> /tmp/birddrop.log; cp -r /Volumes/BirdDrop/BirdDrop.app /Applications >> /tmp/birddrop.log; hdiutil detach /Volumes/BirdDrop >> /tmp/birddrop.log;");
        }

        if (shouldTerminate) exit(0);
    });
}

- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
    [self togglePanel:nil];
}

- (NSString *)unixSinglePathCommandWithReturn:(NSString *) command {
    // performs a unix command by sending it to /bin/sh and returns stdout.
    // trims trailing carriage return
    // not as efficient as running command directly, but provides wildcard expansion
    
    NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    NSData *inData = nil;
    NSString* returnValue = nil;
    
    NSTask *unixTask = [[NSTask alloc] init];
    [unixTask setStandardOutput:newPipe];
    [unixTask setLaunchPath:@"/bin/csh"];
    [unixTask setArguments:[NSArray arrayWithObjects:@"-c", command , nil]];
    [unixTask launch];
    [unixTask waitUntilExit];
    
    while ((inData = [readHandle availableData]) && [inData length]) {
        
        returnValue= [[NSString alloc]
                      initWithData:inData encoding:[NSString defaultCStringEncoding]];
        
        returnValue = [returnValue substringToIndex:[returnValue length]-1];
        
        NSLog(@"%@",returnValue);
    }
    
    return returnValue;
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    [self checkUpdates:YES];
    [[NSApp keyWindow] setIsVisible:NO];
    return NSTerminateLater;

}
#pragma mark - Actions

- (IBAction)togglePanel:(id)sender
{
    self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
    self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
}

#pragma mark - Public accessors

- (PanelController *)panelController
{
    if (_panelController == nil) {
        _panelController = [[PanelController alloc] initWithDelegate:self];
        [_panelController addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PanelController *)controller
{
    return self.menubarController.statusItemView;
}

@end
