#import <RCTText/RCTBaseTextInputViewManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNSelectableTextManager : RCTBaseTextInputViewManager

@property (nonnull, nonatomic, copy) NSString *value;
@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nonatomic, copy) RCTDirectEventBlock onHighlightPress;
@property (nullable, nonatomic, copy) NSArray<NSDictionary *> *highlights;

@end

NS_ASSUME_NONNULL_END
