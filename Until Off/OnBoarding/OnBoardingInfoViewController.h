//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OnBoardingItem;

@interface OnBoardingInfoViewController : UIViewController
@property NSInteger index;
- (instancetype)initWithOnBoardingItem:(OnBoardingItem *)onBoardingItem;
@end
