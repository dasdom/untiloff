//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OnBoardingItem;

@interface OnBoardingInfoView : UIView
//@property NSLayoutConstraint *topConstraint;
- (void)updateWithItem:(OnBoardingItem *)item;
- (UIView *)topView;
@end
