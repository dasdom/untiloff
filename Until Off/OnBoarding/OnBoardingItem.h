//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnBoardingItem : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title text:(NSString *)text;
@end
