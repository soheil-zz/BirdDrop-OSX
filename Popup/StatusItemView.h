@interface StatusItemView : NSView <NSMenuDelegate> {
@private
    NSImage *_image;
    NSImage *_alternateImage;
    NSImage *_blueImage;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
    BOOL _hasActivity;
    SEL _action;
    __unsafe_unretained id _target;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, strong, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, strong) NSImage *blueImage;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic, setter = setHasActivity:) BOOL hasActivity;
@property (nonatomic, readonly) NSRect globalRect;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

@end
