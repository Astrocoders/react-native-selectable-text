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

-(void)setMenuItems:(NSArray<NSString *> *)menuItems {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSMutableArray *menuControllerItems = [NSMutableArray arrayWithCapacity:menuItems.count];
    
    for(NSString *menuItemName in menuItems) {
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle: menuItemName
                                                      action: @selector(handleMenuItemPress:)];
        [menuControllerItems addObject: item];
    }
    
    [menuController setMenuItems: menuControllerItems];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(handleMenuItemPress:);
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    if (menuController.isMenuVisible) {
        return;
    }
    
    if (!self.isFirstResponder) {
        [self becomeFirstResponder];
    }
    
    [menuController setTargetRect:self.bounds inView:self];
    [menuController setMenuVisible:YES animated:YES];
    
    [self setMenuItems:self.menuItems];
}


- (void)handleMenuItemPress:(id) sender
{
    self.onSelection(@{
        @"content": @("foo"),
        @"eventType": @("foobar")
    });
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
