#if __has_include(<RCTText/RCTTextSelection.h>)
#import <RCTText/RCTTextSelection.h>
#else
#import "RCTTextSelection.h"
#endif

#if __has_include(<RCTText/RCTUITextView.h>)
#import <RCTText/RCTUITextView.h>
#else
#import "RCTUITextView.h"
#endif

#import "RNSelectableTextView.h"

#if __has_include(<RCTText/RCTTextAttributes.h>)
#import <RCTText/RCTTextAttributes.h>
#else
#import "RCTTextAttributes.h"
#endif

#import <React/RCTUtils.h>

@implementation RNSelectableTextView
{
    RCTUITextView *_backedTextInputView;
}

NSString *const CUSTOM_SELECTOR = @"_CUSTOM_SELECTOR_";

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    if (self = [super initWithBridge:bridge]) {
        // `blurOnSubmit` defaults to `false` for <TextInput multiline={true}> by design.
        self.blurOnSubmit = NO;
        
        _backedTextInputView = [[RCTUITextView alloc] initWithFrame:self.bounds];
        _backedTextInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backedTextInputView.backgroundColor = [UIColor clearColor];
        _backedTextInputView.textColor = [UIColor blackColor];
        // This line actually removes 5pt (default value) left and right padding in UITextView.
        _backedTextInputView.textContainer.lineFragmentPadding = 0;
#if !TARGET_OS_TV
        _backedTextInputView.scrollsToTop = NO;
#endif
        _backedTextInputView.scrollEnabled = NO;
        _backedTextInputView.textInputDelegate = self;
        _backedTextInputView.editable = NO;
        _backedTextInputView.selectable = YES;
        _backedTextInputView.contextMenuHidden = YES;

        for (UIGestureRecognizer *gesture in [_backedTextInputView gestureRecognizers]) {
            if (
                [gesture isKindOfClass:[UIPanGestureRecognizer class]]
            ) {
                [_backedTextInputView setExclusiveTouch:NO];
                gesture.enabled = YES;
            } else {
                gesture.enabled = NO;
            }
        }

        [self addSubview:_backedTextInputView];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        longPressGesture.minimumPressDuration = 0.25;

        UITapGestureRecognizer *tapGesture = [ [UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 2;
        
        UITapGestureRecognizer *singleTapGesture = [ [UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapGesture.numberOfTapsRequired = 1;
        
        [_backedTextInputView addGestureRecognizer:longPressGesture];
        [_backedTextInputView addGestureRecognizer:tapGesture];
        [_backedTextInputView addGestureRecognizer:singleTapGesture];
        
        [self setUserInteractionEnabled:YES];
    }

    return self;
}

-(void) _handleGesture
{
    if (!_backedTextInputView.isFirstResponder) {
        [_backedTextInputView becomeFirstResponder];
    }

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if (menuController.isMenuVisible) return;

    NSMutableArray *menuControllerItems = [NSMutableArray arrayWithCapacity:self.menuItems.count];
    
    for(NSString *menuItemName in self.menuItems) {
        NSString *sel = [NSString stringWithFormat:@"%@%@", CUSTOM_SELECTOR, menuItemName];
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle: menuItemName
                                                      action: NSSelectorFromString(sel)];
        
        [menuControllerItems addObject: item];
    }
    
    menuController.menuItems = menuControllerItems;

    [menuController setTargetRect:self.bounds inView:self];
    [menuController setMenuVisible:YES animated:YES];
}

- (void) _handleHighlightGesture
{
    if (!_backedTextInputView.isFirstResponder) {
        [_backedTextInputView becomeFirstResponder];
    }
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if (menuController.isMenuVisible) return;
    
    NSMutableArray *menuControllerItems = [NSMutableArray arrayWithCapacity:self.menuItems.count];
    
    for(NSString *menuItemName in self.menuItems) {
        NSString *sel = [NSString stringWithFormat:@"%@%@", CUSTOM_SELECTOR, menuItemName];
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle: menuItemName
                                                      action: NSSelectorFromString(sel)];
        
        if ([menuItemName isEqualToString:@"Marcar"]) {
            sel = [NSString stringWithFormat:@"%@%@", CUSTOM_SELECTOR, @"Desmarcar"];
            item = [[UIMenuItem alloc] initWithTitle: @"Desmarcar"
                                              action: NSSelectorFromString(sel)];
        }
        
        [menuControllerItems addObject: item];
    }
    
    menuController.menuItems = menuControllerItems;
    [menuController setTargetRect:self.bounds inView:self];
    [menuController setMenuVisible:YES animated:YES];
}

-(void) handleSingleTap: (UITapGestureRecognizer *) gesture
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuVisible:false];
    
    CGPoint pos = [gesture locationInView:_backedTextInputView];
    pos.y += _backedTextInputView.contentOffset.y;
    
    UITextPosition *tapPos = [_backedTextInputView closestPositionToPoint:pos];
    UITextRange *word = [_backedTextInputView.tokenizer rangeEnclosingPosition:tapPos withGranularity:(UITextGranularityWord) inDirection:UITextLayoutDirectionRight];
    
    UITextPosition* beginning = _backedTextInputView.beginningOfDocument;
    
    UITextPosition *selectionStart = word.start;
    
    const NSInteger location = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionStart];
    
    for (NSDictionary *cur in _highlights) {
        NSInteger selectionStart = [[cur objectForKey:@"start"] integerValue];
        NSInteger selectionEnd = [[cur objectForKey:@"end"] integerValue];
        
        if (location >= selectionStart && location <= selectionEnd) {
            [_backedTextInputView select:self];
            [_backedTextInputView setSelectedRange:NSMakeRange(selectionStart, selectionEnd - selectionStart)];
            [self _handleHighlightGesture];
            break;
        }
    }
}

-(void) handleLongPress: (UILongPressGestureRecognizer *) gesture
{
    CGPoint pos = [gesture locationInView:_backedTextInputView];
    pos.y += _backedTextInputView.contentOffset.y;

    UITextPosition *tapPos = [_backedTextInputView closestPositionToPoint:pos];
    UITextRange *word = [_backedTextInputView.tokenizer rangeEnclosingPosition:tapPos withGranularity:(UITextGranularityWord) inDirection:UITextLayoutDirectionRight];

    UITextPosition* beginning = _backedTextInputView.beginningOfDocument;

    UITextPosition *selectionStart = word.start;
    UITextPosition *selectionEnd = word.end;

    const NSInteger location = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger endLocation = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionEnd];

    if (location == 0 && endLocation == 0) return;

    [_backedTextInputView select:self];
    [_backedTextInputView setSelectedRange:NSMakeRange(location, endLocation - location)];
    [self _handleGesture];
}

-(void) handleTap: (UITapGestureRecognizer *) gesture
{
    [_backedTextInputView select:self];
    [_backedTextInputView selectAll:self];
    [self _handleGesture];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (self.value) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:self.value attributes:self.textAttributes.effectiveTextAttributes];
        
        [super setAttributedText:str];
    } else {
        [super setAttributedText:attributedText];
    }
}

- (id<RCTBackedTextInputViewProtocol>)backedTextInputView
{
    return _backedTextInputView;
}

- (void)tappedMenuItem:(NSString *)eventType
{
    RCTTextSelection *selection = self.selection;
    
    NSUInteger start = selection.start;
    NSUInteger end = selection.end - selection.start;
    
    NSString *highlightId = [self getHighlightFromRange:selection.start withEnd:selection.end];
    
    self.onSelection(@{
        @"content": [[self.attributedText string] substringWithRange:NSMakeRange(start, end)],
        @"eventType": eventType,
        @"selectionStart": @(start),
        @"selectionEnd": @(selection.end),
        @"highlightId": highlightId
    });
    
    [_backedTextInputView setSelectedTextRange:nil notifyDelegate:false];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if ([super methodSignatureForSelector:sel]) {
        return [super methodSignatureForSelector:sel];
    }
    return [super methodSignatureForSelector:@selector(tappedMenuItem:)];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:CUSTOM_SELECTOR];
    if (match.location == 0) {
        [self tappedMenuItem:[sel substringFromIndex:17]];
    } else {
        [super forwardInvocation:invocation];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSString *sel = NSStringFromSelector(action);
    NSRange match = [sel rangeOfString:CUSTOM_SELECTOR];

    if (match.location == 0) {
        return YES;
    }
    return NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!_backedTextInputView.isFirstResponder) {
        [_backedTextInputView setSelectedTextRange:nil notifyDelegate:true];
    } else {
        UIView *sub = nil;
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point toView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            
            NSLog(@"%@", result.class);
            
            if (!result.isFirstResponder) {
                NSString *name = NSStringFromClass([result class]);

                if ([name isEqual:@"UITextRangeView"]) {
                    sub = result;
                }
            }
        }
        
        if (sub == nil) {
            [_backedTextInputView setSelectedTextRange:nil notifyDelegate:true];
        }
    }

    return [super hitTest:point withEvent:event];
}

- (NSString *) getHighlightFromRange: (NSInteger) start withEnd:(NSInteger) end
{
    NSString *highlightId = @"";
    
    for (NSDictionary *cur in _highlights) {
        NSInteger highlightStart = [[cur objectForKey:@"start"] integerValue];
        NSInteger highlightEnd = [[cur objectForKey:@"end"] integerValue];
        
        if (highlightStart == start && highlightEnd == end) {
            highlightId = [cur objectForKey:@"id"];
            break;
        }
    }
    
    return highlightId;
}

@end
