//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import "OnBoardingItem.h"

@implementation OnBoardingItem

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title text:(NSString *)text {
    self = [super init];
    if (self) {
        _image = image;
        _title = title;
        _text = text;
    }
    return self;
}

@end
