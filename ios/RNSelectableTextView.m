//
//  RNSelectableTextView.m
//  RNSelectableText
//
//  Created by Gabriel R. Abreu on 13/03/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNSelectableTextView.h"

@implementation RNSelectableTextView {
    NSString* selectedText;
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (!self.isFirstResponder) {
        [self becomeFirstResponder];
    }
    
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)tappedMenuItem:(NSString *)text {
    self.onSelection(@{
                       @"content": text,
                       @"eventType": text
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
