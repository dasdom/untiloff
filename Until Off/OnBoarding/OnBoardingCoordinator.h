//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OnBoardingItem;

@interface OnBoardingCoordinator : NSObject
- (void)start;
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController onBoardingItems:(NSArray<OnBoardingItem *> *)items;
@end
