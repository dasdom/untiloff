//
//  DDHAlertView.h
//  Until Off
//
//  Created by dasdom on 07.11.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDHAlertView : UIAlertView

- (id)initWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle;
- (void)addButtonWithTitle:(NSString*)title andAction:(void(^)(void))block;

@end
