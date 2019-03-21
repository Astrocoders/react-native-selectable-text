//
//  RNSelectableTextView.m
//  RNSelectableText
//
//  Created by Gabriel R. Abreu on 13/03/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNSelectableTextView.h"
#define RGB(r, g, b) [UIColor colorWithRed:(float)r/255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]

@implementation RNSelectableTextView {
    NSString* selectedText;
    NSTextStorage *_Nullable _textStorage;
    UILongPressGestureRecognizer* _gesture;
}

- (dispatch_queue_t) methodQueue
{
    return dispatch_get_main_queue();
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSString *sel = NSStringFromSelector(action);
    NSRange match = [sel rangeOfString:@"_CUSTOM_SELECTOR_"];
    if (match.location == 0) {
        return YES;
    }
    return NO;
}

- (void)setTextStorage:(NSTextStorage *)textStorage
          contentFrame:(CGRect)contentFrame
       descendantViews:(NSArray<UIView *> *)descendantViews
{
    _textStorage = textStorage;
    [super setTextStorage:textStorage contentFrame:contentFrame descendantViews:descendantViews];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{    
    if (!self.isFirstResponder) {
        [self becomeFirstResponder];
    }
    
    gesture.view.backgroundColor = RGB( [self.highlightColor[0] floatValue], [self.highlightColor[1] floatValue], [self.highlightColor[2] floatValue] );

    _gesture = gesture;

    UIMenuController *menuController = [UIMenuController sharedMenuController];

    if (menuController.isMenuVisible) return;

    NSMutableArray *menuControllerItems = [NSMutableArray arrayWithCapacity:self.menuItems.count];

    for(NSString *menuItemName in self.menuItems) {
        NSString *sel = [NSString stringWithFormat:@"_CUSTOM_SELECTOR_%@", menuItemName];
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle: menuItemName
                                                      action: NSSelectorFromString(sel)];

        [menuControllerItems addObject: item];
    }

    menuController.menuItems = menuControllerItems;
    [menuController setTargetRect:self.bounds inView:self];
    [menuController setMenuVisible:YES animated:YES];
}

- (BOOL)becomeFirstResponder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    
    _gesture.view.backgroundColor = nil;
    
    return [super resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)tappedMenuItem:(NSString *)eventType {
    NSAttributedString *attributedText = _textStorage;
    
    self.onSelection(@{
        @"content": [_textStorage string],
        @"eventType": eventType,
        @"selectionStart": @0,
        @"selectionEnd": [NSNumber numberWithUnsignedInteger:attributedText.length]
    });
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
    NSRange match = [sel rangeOfString:@"_CUSTOM_SELECTOR_"];
    if (match.location == 0) {
        [self tappedMenuItem:[sel substringFromIndex:17]];
    } else {
        [super forwardInvocation:invocation];
    }
}

@end
