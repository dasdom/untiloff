//
//  NotificationView.m
//  Until Off
//
//  Created by dasdom on 19.10.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "NotificationView.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation NotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.98f alpha:1.0f];

        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = NSLocalizedString(@"Set and activate reminder", nil);
        [self addSubview:label];
        
        _reminderHostViewOne = [[UIView alloc] init];
        _reminderHostViewOne.translatesAutoresizingMaskIntoConstraints = NO;
        _reminderHostViewOne.tag = 0;
        _reminderHostViewOne.layer.cornerRadius = 3.0f;
        _reminderHostViewOne.layer.borderWidth = 2.0f;
        _reminderHostViewOne.layer.borderColor = [[Utilities globalTintColor] CGColor];
        [self addSubview:_reminderHostViewOne];
        
//        _datePickerOne = [[UIDatePicker alloc] init];
//        _datePickerOne.translatesAutoresizingMaskIntoConstraints = NO;
//        _datePickerOne.datePickerMode = UIDatePickerModeTime;
//        [self addSubview:_datePickerOne];
        
        _dateLabelOne = [[UILabel alloc] init];
        _dateLabelOne.translatesAutoresizingMaskIntoConstraints = NO;
        _dateLabelOne.text = @"Reminder 1";
        [_reminderHostViewOne addSubview:_dateLabelOne];
        
        _switchOne = [[UISwitch alloc] init];
        _switchOne.translatesAutoresizingMaskIntoConstraints = NO;
        _switchOne.tag = 0;
        [_reminderHostViewOne addSubview:_switchOne];
        
        _reminderHostViewTwo = [[UIView alloc] init];
        _reminderHostViewTwo.translatesAutoresizingMaskIntoConstraints = NO;
        _reminderHostViewTwo.tag = 1;
        _reminderHostViewTwo.layer.cornerRadius = 3.0f;
        _reminderHostViewTwo.layer.borderWidth = 1.0f;
        _reminderHostViewTwo.layer.borderColor = [[UIColor grayColor] CGColor];
        [self addSubview:_reminderHostViewTwo];
        
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.translatesAutoresizingMaskIntoConstraints = NO;
        _datePicker.datePickerMode = UIDatePickerModeTime;
        [self addSubview:_datePicker];
        
        _dateLabelTwo = [[UILabel alloc] init];
        _dateLabelTwo.translatesAutoresizingMaskIntoConstraints = NO;
        _dateLabelTwo.text = @"Reminder 2";
        [_reminderHostViewTwo addSubview:_dateLabelTwo];

        _switchTwo = [[UISwitch alloc] init];
        _switchTwo.tag = 1;
        _switchTwo.translatesAutoresizingMaskIntoConstraints = NO;
        [_reminderHostViewTwo addSubview:_switchTwo];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(label, _reminderHostViewOne, _dateLabelOne, _switchOne, _reminderHostViewTwo, _dateLabelTwo, _switchTwo, _datePicker);
        [_reminderHostViewOne addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_dateLabelOne]-[_switchOne(50)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
        [_reminderHostViewOne addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dateLabelOne]|" options:0 metrics:nil views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-75-[label]-10-[_reminderHostViewOne(60,==_reminderHostViewTwo)]-10-[_reminderHostViewTwo]-[_datePicker]" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDictionary]];
        
        [_reminderHostViewTwo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_dateLabelTwo]-[_switchTwo(50)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
        [_reminderHostViewTwo addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dateLabelTwo]|" options:0 metrics:nil views:viewsDictionary]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[label(==_reminderHostViewOne,==_reminderHostViewTwo)]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewsDictionary]];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
