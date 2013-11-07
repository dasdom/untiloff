//
//  ElementFactory.m
//  Until Off
//
//  Created by dasdom on 17.10.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "ElementFactory.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation ElementFactory

+ (UIButton*)mainScreenButtonWithImage:(UIImage*)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.contentMode = UIViewContentModeCenter;
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = [[Utilities globalTintColor] CGColor];
    button.layer.cornerRadius = 3.0f;
    return button;
}

@end
