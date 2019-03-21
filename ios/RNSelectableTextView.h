//
//  RNSelectableTextView.h
//  RNSelectableText
//
//  Created by Gabriel R. Abreu on 13/03/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <RCTText/RCTTextView.h>
#import <React/RCTComponent.h>

@interface RNSelectableTextView : RCTTextView;

@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nullable, nonatomic, copy) NSArray<NSNumber *> *highlightColor;

@end
