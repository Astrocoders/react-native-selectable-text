#import <UIKit/UIKit.h>
#import <RCTText/RCTTextViewManager.h>

@interface RNSelectableTextManager : RCTTextViewManager

@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nullable, nonatomic, copy) NSArray<NSNumber *> *highlightColor;

@end
