#import "RNCSliderManager.h"

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "RNSelectableText.h"
#import <RCTText/RCTTextView.h>

@implementation RNSelectableText


RCT_EXPORT_MODULE()

- void (RCTTextView *)view
{
    RCTTextView *selectableText = [RCTTextView new];
    return selectableText;
}

@end
  
