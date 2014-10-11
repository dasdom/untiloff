//
//  DDHAlertView.m
//  Until Off
//
//  Created by dasdom on 07.11.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DDHAlertView.h"

typedef void(^ActionBlock)(void);

@interface DDHAlertView () <UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *buttonsArray;
@end

@implementation DDHAlertView

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle
{
    if ((self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil]))
    {
        _buttonsArray = [NSArray array];
    }
    return self;
}

- (void)addButtonWithTitle:(NSString*)title andAction:(void(^)(void))block
{
    NSDictionary *buttonDictionary;
    if (block)
    {
        buttonDictionary = @{@"title" : title, @"block" : block};
    }
    else
    {
        buttonDictionary = @{@"title" : title};
    }
    self.buttonsArray = [self.buttonsArray arrayByAddingObject:buttonDictionary];
    
    [self addButtonWithTitle:title];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex %ld", (long)buttonIndex);
    
    if (buttonIndex < 1)
    {
        return;
    }
    
    NSDictionary *buttonDictionary = self.buttonsArray[buttonIndex-1];
    ActionBlock block = buttonDictionary[@"block"];
    
    if (block) block();
}

@end
