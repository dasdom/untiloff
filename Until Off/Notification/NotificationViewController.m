//
//  NotificationViewController.m
//  Until Off
//
//  Created by dasdom on 19.10.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationView.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

#define kAlertDateOne @"kAlertDateOne"
#define kAlertOneIsOn @"kAlertOneIsOn"
#define kAlertDateTwo @"kAlertDateTwo"
#define kAlertTwoIsOn @"kAlertTwoIsOn"

NSString * const kRegisterNotificationSettings = @"kRegisterNotificationSettings";

@interface NotificationViewController ()
@property (nonatomic, strong) NotificationView *notificationView;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSDate *dateOne;
@property (nonatomic, strong) NSDate *dateTwo;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation NotificationViewController

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    _notificationView = [[NotificationView alloc] initWithFrame:frame];
    [_notificationView.datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];

    UITapGestureRecognizer *tapRecognizerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnReminderHostViewHappend:)];
    [_notificationView.reminderHostViewOne addGestureRecognizer:tapRecognizerOne];
    
    UITapGestureRecognizer *tapRecognizerTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnReminderHostViewHappend:)];
    [_notificationView.reminderHostViewTwo addGestureRecognizer:tapRecognizerTwo];
    
    self.view = _notificationView;

    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.timeStyle = NSDateFormatterShortStyle;
    _dateFormatter.dateStyle = NSDateFormatterNoStyle;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    self.title = NSLocalizedString(@"Reminder", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   
    self.dateOne = [userDefaults objectForKey:kAlertDateOne];
    BOOL switchOneIsOn = [userDefaults boolForKey:kAlertOneIsOn];
    NSDate *nowDate = [NSDate date];
    if (switchOneIsOn && self.dateOne)
    {
        self.notificationView.dateLabelOne.text = [self.dateFormatter stringFromDate:self.dateOne];
        self.notificationView.switchOne.on = YES;
        [self.notificationView.datePicker setDate:self.dateOne animated:YES];
    }
    else
    {
        self.dateOne = [NSDate date];
        self.notificationView.dateLabelOne.text = [self.dateFormatter stringFromDate:nowDate];
        self.notificationView.switchOne.on = NO;
    }
    
    self.dateTwo = [userDefaults objectForKey:kAlertDateTwo];
    BOOL switchTwoIsOn = [userDefaults boolForKey:kAlertTwoIsOn];
    if (switchTwoIsOn && self.dateTwo)
    {
        self.notificationView.dateLabelTwo.text = [self.dateFormatter stringFromDate:self.dateTwo];
        self.notificationView.switchTwo.on = YES;
    }
    else
    {
        self.dateTwo = [NSDate date];
        self.notificationView.dateLabelTwo.text = [self.dateFormatter stringFromDate:nowDate];
        self.notificationView.switchTwo.on = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    BOOL registerUserNotificationSettings = NO;
    if (self.notificationView.switchOne.isOn)
    {
        [userDefaults setObject:self.dateOne forKey:kAlertDateOne];
        [userDefaults setBool:YES forKey:kAlertOneIsOn];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        [localNotification setFireDate: self.dateOne];
        [localNotification setRepeatInterval: NSCalendarUnitDay];
        [localNotification setAlertBody: NSLocalizedString(@"Would you like to save the current battery state?", nil)];
        [localNotification setAlertAction: NSLocalizedString(@"Save", nil)];
        [localNotification setCategory:@"MEASUREMENT_CATEGORY"];
        [[UIApplication sharedApplication] scheduleLocalNotification: localNotification];
        registerUserNotificationSettings = YES;
    }
    else
    {
        [userDefaults removeObjectForKey:kAlertDateOne];
        [userDefaults setBool:NO forKey:kAlertOneIsOn];
    }
    
    if (self.notificationView.switchTwo.isOn)
    {
        [userDefaults setObject:self.dateTwo forKey:kAlertDateTwo];
        [userDefaults setBool:YES forKey:kAlertTwoIsOn];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        [localNotification setFireDate: self.dateTwo];
        [localNotification setRepeatInterval: NSCalendarUnitDay];
        [localNotification setAlertBody: NSLocalizedString(@"Would you like to save the current battery state?", nil)];
        [localNotification setAlertAction: NSLocalizedString(@"Save", nil)];
        [localNotification setCategory:@"MEASUREMENT_CATEGORY"];
        [[UIApplication sharedApplication] scheduleLocalNotification: localNotification];
        registerUserNotificationSettings = YES;
    }
    else
    {
        [userDefaults removeObjectForKey:kAlertDateTwo];
        [userDefaults setBool:NO forKey:kAlertTwoIsOn];
    }
    
    if (registerUserNotificationSettings) {
        NSDictionary *defaultPreferences = @{kRegisterNotificationSettings : @YES};
        [userDefaults registerDefaults:defaultPreferences];
        [userDefaults synchronize];
        if ([userDefaults boolForKey:kRegisterNotificationSettings]) {
            UIMutableUserNotificationAction *measurementAction = [[UIMutableUserNotificationAction alloc] init];
            measurementAction.identifier = @"MEASUREMENT_ACTION";
            measurementAction.title = @"Save";
            measurementAction.activationMode = UIUserNotificationActivationModeBackground;
            
            UIMutableUserNotificationCategory *measurementCategory = [[UIMutableUserNotificationCategory alloc] init];
            [measurementCategory setActions:@[measurementAction] forContext:UIUserNotificationActionContextDefault];
            measurementCategory.identifier = @"MEASUREMENT_CATEGORY";
            
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:[NSSet setWithObject:measurementCategory]];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            
            [userDefaults setBool:NO forKey:kRegisterNotificationSettings];
            [userDefaults synchronize];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - bar button actions
- (void)doneButtonTouched:(UIBarButtonItem*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - date picker action
- (void)datePickerChanged:(UIDatePicker*)sender
{
    if (self.tag == 0)
    {
        self.dateOne = sender.date;
        self.notificationView.dateLabelOne.text = [self.dateFormatter stringFromDate:sender.date];
    }
    else
    {
        self.dateTwo = sender.date;
        self.notificationView.dateLabelTwo.text = [self.dateFormatter stringFromDate:sender.date];
    }
}

#pragma mark - resture actions
- (void)tapOnReminderHostViewHappend:(UITapGestureRecognizer*)sender
{
    self.notificationView.reminderHostViewOne.layer.borderColor = [[UIColor grayColor] CGColor];
    self.notificationView.reminderHostViewOne.layer.borderWidth = 1.0f;
    self.notificationView.reminderHostViewTwo.layer.borderColor = [[UIColor grayColor] CGColor];
    self.notificationView.reminderHostViewTwo.layer.borderWidth = 1.0f;

    self.tag = sender.view.tag;
    sender.view.layer.borderColor = [[Utilities globalTintColor] CGColor];
    sender.view.layer.borderWidth = 2.0f;
    
    if (sender.view.tag == 0)
    {
        [self.notificationView.datePicker setDate:self.dateOne animated:YES];
    }
    else
    {
        [self.notificationView.datePicker setDate:self.dateTwo animated:YES];
    }

}

@end
