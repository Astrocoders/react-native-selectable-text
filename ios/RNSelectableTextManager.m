

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "RNSelectableTextManager.h"
#import "RNSelectableTextView.h"

@implementation RNSelectableTextManager {
    RCTDirectEventBlock _onSelection;
}

RCT_EXPORT_MODULE()

- (RNSelectableTextView *)view
{
    RNSelectableTextView *selectableText = [RNSelectableTextView new];
    return selectableText;
}

RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(menuItems, NSArray);
RCT_EXPORT_VIEW_PROPERTY(highlightColor, NSArray);

@end
  
