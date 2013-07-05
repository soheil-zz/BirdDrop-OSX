#import "PanelController.h"
#import "BackgroundView.h"
#import "StatusItemView.h"
#import "MenubarController.h"
#import "ApplicationDelegate.h"

#define OPEN_DURATION .08
#define CLOSE_DURATION .1

#define SEARCH_INSET 10

#define POPUP_HEIGHT 495
#define PANEL_WIDTH 325
#define MENU_ANIMATION_DURATION .1

#pragma mark -

@implementation PanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;
@synthesize searchField = _searchField;
@synthesize textField = _textField;
@synthesize webView;
@synthesize webView1;
@synthesize back;

#pragma mark -

- (void)windowDidLoad{
     NSEvent* (^handler)(NSEvent*) = ^(NSEvent *theEvent) {
         NSWindow *targetWindow = theEvent.window;
         if (targetWindow != self.window) {
              return theEvent;
         }

         NSEvent *result = theEvent;
         if (theEvent.keyCode == 53) {
             self.hasActivePanel = NO;
             result = nil;
         }

         return result;
     };
     eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:handler];
}

- (id)initWithDelegate:(id<PanelControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Panel"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    [self awakeFromNib];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:self.searchField];
}

#pragma mark -

- (IBAction)openTwitter:(id)sender;
{
    if (sender) {
        webView.frame = CGRectMake(0, 0, originalWebviewFrame.size.width, originalWebviewFrame.size.height);
    }
    [back setHidden:YES];
    NSString *iphone = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";
    [webView setCustomUserAgent: iphone];
    
    NSURL *url = [NSURL URLWithString:@"https://www.twitter.com"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[webView mainFrame] loadRequest:urlRequest];
    
    [webView1 setCustomUserAgent: iphone];
    [[webView1 mainFrame] loadRequest:urlRequest];
}

- (void)awakeFromNib
{
    [self openTwitter:nil];
    [super awakeFromNib];

    // Make a fully skinned panel
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];
    
    // Resize panel
    NSRect panelRect = [[self window] frame];
    panelRect.size.height = POPUP_HEIGHT;
    [[self window] setFrame:panelRect display:NO];
    
    // Follow search string
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runSearch) name:NSControlTextDidChangeNotification object:self.searchField];
    
    originalWebviewFrame = webView.frame;
}

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id < WebPolicyDecisionListener >)listener
{
    clickedOnLinkOnce = YES;
    [[self.webView mainFrame] loadRequest:request];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    BOOL isTwitter = [request.URL.host rangeOfString:@"twitter.com"].location != NSNotFound;
    if (clickedOnLinkOnce) self.webView.frame = CGRectMake(0, (isTwitter ? 0 : -10), originalWebviewFrame.size.width, originalWebviewFrame.size.height - (isTwitter ? 0 : 10));
    [back setHidden:isTwitter];
    [listener use];
}

- (void)bindKeys
{
    [webView stringByEvaluatingJavaScriptFromString:
     @"function addHash(){if(document.querySelector('.tweet-box-textarea') && document.querySelector('.tweet-box-textarea').value=='')document.querySelector('.tweet-box-textarea').value=' via #birddrop '; setTimeout(addHash, 1000);}; setTimeout(addHash, 1000);"
     ];
    [webView stringByEvaluatingJavaScriptFromString:
     @"var arrowi=0; var arrowj=0; var semaphore=0;document.body.addEventListener('keydown', function(ev) { if(semaphore)return; semaphore=1; var el = document.getSelection().anchorNode;if (el && (el.innerHTML.indexOf('input') !== -1 || el.innerHTML.indexOf('textarea') !== -1)) {return 0;}; if(document.location.pathname=='/'&&ev.keyCode==13){var el=document.querySelector('.stream-item:nth-child('+arrowj+')');if(el)doclick(el);}if(document.location.pathname=='/'&&(ev.keyCode==38||ev.keyCode==40)){if(arrowj<0)arrowj=0;var el=document.querySelector('.stream-item:nth-child('+arrowj+')'); if(el)el.style.backgroundColor='white'; if(ev.keyCode==38)arrowj--; if(ev.keyCode==40)arrowj++; el=document.querySelector('.stream-item:nth-child('+arrowj+')'); if(el){el.style.backgroundColor='lightblue';if(arrowj%4==0||ev.keyCode==38)el.scrollIntoView();}semaphore=0;/*up-down is done*/} var sel; if(!ev.metaKey&&ev.keyCode==37)arrowi--; if(!ev.metaKey&&ev.keyCode==39)arrowi++; if(arrowi<0)arrowi=3; if(arrowi>3)arrowi=0; var char=String.fromCharCode(ev.keyCode); if(!ev.metaKey&&(ev.keyCode==37||ev.keyCode==39))char=['H','C','D','M'][arrowi]; switch(char) { case 'H': sel = '.navbar div[tab=\"tweets\"]'; break; case 'C': sel =      '.navbar div[tab=\"connect\"]'; break; case 'D': sel = '.navbar div[tab=\"discover\"]'; break; case 'M': sel = '.navbar div[tab=\"account\"]'; break; case 'N': sel = '.navItems div[nav=\"compose\"]'; break; case 'S': sel = '.navItems div[nav=\"search\"]'; break; } var el =         document.querySelector(sel); if (el) { doclick(el); } function doclick(el) {var evt = document.createEvent('MouseEvents'); evt.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false,         false, false, false, 0, null); el.dispatchEvent(evt); } setTimeout(function(){semaphore=0}, 100)}, false);"
     ];
    [webView stringByEvaluatingJavaScriptFromString:
     @"var styleBirddrop = document.createElement('style');styleBirddrop.innerHTML = '.navItem { cursor: pointer !important; } a { cursor: pointer !important; }'; document.body.appendChild(styleBirddrop);"
     ];
    NSLog(@"inserting key.js & css");
}

- (void)checkActivity
{
    isNotFirstTimeLoadAcitivity = YES;
    NSString *resultTimestamp = [webView1 stringByEvaluatingJavaScriptFromString:
                                 @"document.querySelector('.stream-item').getAttribute('activity');"
                                ];
    NSString *resultActivityText = [webView1 stringByEvaluatingJavaScriptFromString:
                                 @"document.querySelector('.stream-item').innerText;"
                                 ];
    int currentActivityTimestamp = (int)[resultTimestamp integerValue];
    NSLog(@"last activity timestamp: %d", currentActivityTimestamp);
    [self openConnectTabEvenIfOnComposePage:YES withHiddenWebview:YES];
    
    if (lastActivityTimestamp != 0 && lastActivityTimestamp != currentActivityTimestamp) {
        NSLog(@"sending notification");
        StatusItemView *statusItemView = nil;
        if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
        {
            statusItemView = [self.delegate statusItemViewForPanelController:self];
            statusItemView.hasActivity = YES;
        }
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        if (notification) {
            notification.title = @"New Twitter BirdDropping";
            notification.informativeText = resultActivityText;
            notification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }
    lastActivityTimestamp = currentActivityTimestamp;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if ([sender isEqualTo:webView]) {
        [self bindKeys];
        if (!bindKeysTimer) {
            bindKeysTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                         target:self
                                       selector:@selector(bindKeys)
                                       userInfo:nil
                                        repeats:YES];
        }
    } else {
        NSLog(@"webview1 load complete");
        if (!isNotFirstTimeLoadAcitivity) [self checkActivity];
        if (!checkActivityTimer) {
            checkActivityTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                             target:self
                                           selector:@selector(checkActivity)
                                           userInfo:nil
                                            repeats:YES];
        }
    }
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel
{
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag
{
    if (_hasActivePanel != flag)
    {
        _hasActivePanel = flag;
        
        if (_hasActivePanel)
        {
            [self openPanel];
        }
        else
        {
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *panel = [self window];
    NSRect statusRect = [self statusRectForWindow:panel];
    NSRect panelRect = [panel frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat panelX = statusX - NSMinX(panelRect);
    
    self.backgroundView.arrowX = panelX;
    
    NSRect searchRect = [self.searchField frame];
    searchRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    searchRect.origin.x = SEARCH_INSET;
    searchRect.origin.y = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET - NSHeight(searchRect);
    
    if (NSIsEmptyRect(searchRect))
    {
        [self.searchField setHidden:YES];
    }
    else
    {
        [self.searchField setFrame:searchRect];
        [self.searchField setHidden:NO];
    }
    
    NSRect textRect = [self.textField frame];
    textRect.size.width = NSWidth([self.backgroundView bounds]) - SEARCH_INSET * 2;
    textRect.origin.x = SEARCH_INSET;
    textRect.size.height = NSHeight([self.backgroundView bounds]) - ARROW_HEIGHT - SEARCH_INSET * 3 - NSHeight(searchRect);
    textRect.origin.y = SEARCH_INSET;
    
    if (NSIsEmptyRect(textRect))
    {
        [self.textField setHidden:YES];
    }
    else
    {
        [self.textField setFrame:textRect];
        [self.textField setHidden:NO];
    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActivePanel = NO;
}

- (void)runSearch
{
    NSString *searchFormat = @"";
    NSString *searchString = [self.searchField stringValue];
    if ([searchString length] > 0)
    {
        searchFormat = NSLocalizedString(@"Search for ‘%@’…", @"Format for search request");
    }
    NSString *searchRequest = [NSString stringWithFormat:searchFormat, searchString];
    [self.textField setStringValue:searchRequest];
}

#pragma mark - Public methods

- (void)openConnectTabEvenIfOnComposePage:(BOOL)shouldForceOpen withHiddenWebview:(BOOL)shouldBeHiddenWebview
{
    BOOL isOnComposePage = NO;
    if (!shouldForceOpen && isOnComposePage) return;
    NSURL *url = [NSURL URLWithString:@"https://mobile.twitter.com/i/connect"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    WebView *webviewToUse = shouldBeHiddenWebview ? webView1 : webView;
    [[webviewToUse mainFrame] loadRequest:urlRequest];
}

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)])
    {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openPanel
{
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];

    NSRect panelRect = [panel frame];
    panelRect.size.width = PANEL_WIDTH;
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:statusRect display:YES];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[panel animator] setFrame:panelRect display:YES];
    [[panel animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)closePanel
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self.window orderOut:nil];
    });
}

@end
