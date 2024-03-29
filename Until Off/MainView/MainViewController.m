//  Created by dasdom on 29.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "Measurement.h"
#import "Prediction.h"
#import "Geofence.h"
#import "AppDelegate.h"
#import "BatteryCalculation.h"
#import "LocationServiceViewController.h"
#import "PredictionsOverviewViewController.h"
#import "NotificationViewController.h"
#import "MeasurementsManager.h"
#import "DescriptionView.h"
#import "Utilities.h"
#import <CoreLocation/CoreLocation.h>
#import "Until_Off-Swift.h"
#import <QuartzCore/QuartzCore.h>
#import "UntilOffStyleKit.h"
#import "OnBoardingCoordinator.h"
#import "OnBoardingItem.h"

#define kLevelDiff @"kLevelDiff"
#define kTimeDiff @"kTimeDiff"
#define kMaxPointsInTimeForCalculation @"kMaxPointsInTimeForCalculation"

//NSString * const kLastPredictionDate = @"lastPredictionDate";

@interface MainViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) MainView *mainView;
@property (nonatomic, strong) NSArray *measurementArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MeasurementsManager *measurementManager;
@property (nonatomic, assign) NSUInteger stopIndex;
@property (nonatomic, assign) CGFloat timeDiff;
@property (nonatomic, assign) CGFloat levelDiff;
@property (nonatomic, assign) NSInteger predictionOfTotalSeconds;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) DescriptionView *descriptionView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL showTimeOfOff;
@property (nonatomic, strong) OnBoardingCoordinator *onBoardingCoordinator;
@end

@implementation MainViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    if ((self = [super init]))
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        _mainView = [[MainView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        [_mainView.locationServiceButton addTarget:self action:@selector(showLocationServiceSettings:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView.predictionOverviewButton addTarget:self action:@selector(showPredictionOverview:) forControlEvents:UIControlEventTouchUpInside];
//        [_mainView.infoButton addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
        [_mainView.addPredictionButton addTarget:self action:@selector(addPredictionTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_mainView.addNotificationButton addTarget:self action:@selector(addNotification:) forControlEvents:UIControlEventTouchUpInside];
//        [_mainView.settingButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
        
        _measurementManager = [[MeasurementsManager alloc] initWithManagedObjectContext:managedObjectContext];
        
        _managedObjectContext = managedObjectContext;
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        
        _showTimeOfOff = [[NSUserDefaults standardUserDefaults] boolForKey:[SettingsTableViewController showTimeOfOffKey]];
    }
    return self;
}

- (void)loadView {

    self.view = self.mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    UIImage *settingsImage = [UntilOffStyleKit imageOfSettingsIconWithSize:CGSizeMake(25, 25)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:settingsImage style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.onBoardingCoordinator = nil;
    
    NSArray *regionArray = [[self.locationManager monitoredRegions] allObjects];
    for (CLRegion *region in regionArray)
    {
        [self.locationManager stopMonitoringForRegion:region];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Geofence" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];

    NSError *fetchError;
    NSArray *geofenceArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        for (Geofence *geofence in geofenceArray)
        {
            NSLog(@"geofence.name: %@, %@", geofence.name, geofence.radius);
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([geofence.latitude doubleValue], [geofence.longitude doubleValue]);
            CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:coordinate radius:[geofence.radius floatValue] identifier:geofence.name];
            [self.locationManager startMonitoringForRegion:circularRegion];
        }
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.locationManager.distanceFilter = 1000.0f;

    BOOL currentShowTimeOfOff = [[NSUserDefaults standardUserDefaults] boolForKey:[SettingsTableViewController showTimeOfOffKey]];
    if (self.showTimeOfOff != currentShowTimeOfOff) {
        [self.mainView setNeedsDisplay];
        self.showTimeOfOff = currentShowTimeOfOff;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"appAlreadyStarted"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"appAlreadyStarted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self showDescription];
    }
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    [UIView animateWithDuration:5.0f delay:2.0f options:kNilOptions animations:^{
//        self.mainView.shapeLayer.strokeEnd = 1.0f;
//    } completion:^(BOOL finished) {
//        
//    }];
//}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExitRegion: %@", region);
    
    [self.measurementManager addMeasurement];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.measurementManager addMeasurement];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion: %@ with error %@", region, error);
}

#pragma mark -
- (void)showDescription {
//    [self.animator removeAllBehaviors];
//    self.animator = nil;
//
//    self.descriptionView = [[DescriptionView alloc] initWithFrame:self.view.bounds];
//    [self.descriptionView.dismissButton addTarget:self action:@selector(hideDescription:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.descriptionView];
//
//    UIDynamicAnimator* animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.descriptionView];
//    UIGravityBehavior* gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[self.descriptionView.descriptionHostView]];
//    UIDynamicItemBehavior *friction = [[UIDynamicItemBehavior alloc] initWithItems:@[self.descriptionView.descriptionHostView]];
////    friction.friction = 10.0f;
//    friction.density = 1.0f;
//    friction.resistance = 1.0f;
//
//    CGSize halfHostViewSize = self.descriptionView.descriptionHostView.frame.size;
//    halfHostViewSize.width = ceilf(halfHostViewSize.width/2.0f);
//    halfHostViewSize.height = ceilf(halfHostViewSize.height/2.0f);
//
//    CGPoint anchorPoint = CGPointMake(self.descriptionView.descriptionHostView.center.x, self.descriptionView.descriptionHostView.center.y - halfHostViewSize.height - 5.0f);
////    UIAttachmentBehavior* attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.descriptionView.descriptionHostView attachedToAnchor:anchorPoint];
//    UIAttachmentBehavior *leftAttachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.descriptionView.descriptionHostView offsetFromCenter:UIOffsetMake(-(halfHostViewSize.width-20.0f), -(halfHostViewSize.height-20.0f)) attachedToAnchor:anchorPoint];
//    [leftAttachmentBehavior setFrequency:2.0];
//    [leftAttachmentBehavior setDamping:1.0];
//    leftAttachmentBehavior.length = 80.0f;
//
//    UIAttachmentBehavior *rightAttachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.descriptionView.descriptionHostView offsetFromCenter:UIOffsetMake(halfHostViewSize.width-20.0f, -(halfHostViewSize.height-20.0f)) attachedToAnchor:anchorPoint];
//    [rightAttachmentBehavior setFrequency:2.0];
//    [rightAttachmentBehavior setDamping:1.0];
//    rightAttachmentBehavior.length = 80.0f;
//
//    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.descriptionView.descriptionHostView] mode:UIPushBehaviorModeInstantaneous];
//    pushBehavior.angle = 0.0;
//    pushBehavior.magnitude = 1.0;
//
//    [animator addBehavior:leftAttachmentBehavior];
//    [animator addBehavior:rightAttachmentBehavior];
//    [animator addBehavior:gravityBeahvior];
//    [animator addBehavior:friction];
//    [animator addBehavior:pushBehavior];
////    self.animator = animator;
//
////    self.descriptionView.descriptionHostView.center = CGPointMake(self.descriptionView.descriptionHostView.center.x-50.0f, self.descriptionView.descriptionHostView.center.y);
//
//    self.descriptionView.alpha = 0.0f;
//    [UIView animateWithDuration:0.25f animations:^{
//        self.descriptionView.alpha = 1.0f;
//    } completion:^(BOOL finished) {
//
//    }];
    
    NSArray<OnBoardingItem *> *onBoardingItems = @[
                                                   [[OnBoardingItem alloc] initWithImage:[UIImage imageNamed:@"onboarding_icon"] title:NSLocalizedString(@"What is UntilOff?", nil) text:NSLocalizedString(@"UntilOff let's you figure out how long you can use your phone until it needs to be charged again.", nil)],
                                                   [[OnBoardingItem alloc] initWithImage:[UIImage imageNamed:@"startAppAfterUnplug"] title:NSLocalizedString(@"Help", nil) text:NSLocalizedString(@"This job is hard. But you can help! Start UntilOff after you have charged your phone.", nil)],
                                                   [[OnBoardingItem alloc] initWithImage:[UIImage imageNamed:@"residualTime"] title:NSLocalizedString(@"Residual Battery", nil) text:NSLocalizedString(@"Every time you need to know the residual battery duration, start UntilOff and it will tell you.", nil)],
                                                   [[OnBoardingItem alloc] initWithImage:[UIImage imageNamed:@"distributionIcon"] title:NSLocalizedString(@"Distribution", nil) text:NSLocalizedString(@"If UntilOff believes the calculation is reliable, it saves the predicted total battery duration.", nil)],
                                                   [[OnBoardingItem alloc] initWithImage:[UIImage imageNamed:@"addPrediction"] title:NSLocalizedString(@"Add Measurement", nil) text:NSLocalizedString(@"You can add a measurement to the distribution manually.", nil)],
                                                   [[OnBoardingItem alloc] initWithImage:[UIImage imageNamed:@"locationServiceIcon"] title:NSLocalizedString(@"Background", nil) text:NSLocalizedString(@"UntilOff can measure the battery in the background. To activate you have to add geo fences.", nil)],
                                                   [[OnBoardingItem alloc] initWithImage:[UIImage imageNamed:@"notificationIcon"] title:NSLocalizedString(@"Notifications", nil) text:NSLocalizedString(@"Add notifications if you want to be remebered to open UntilOff to add measurements in a regular manner.", nil)],
                                                   [[OnBoardingItem alloc] initWithImage:nil title:NSLocalizedString(@"How does it work?", nil) text:NSLocalizedString(@"UntilOff takes the duration between the highest and the actual battery level and interpolates to an empty battery. Therefore the values only take into account your prior usage.", nil)],
                                                   ];
    
    
    UINavigationController *navigationController = [UINavigationController new];
    navigationController.navigationBar.translucent = false;
    self.onBoardingCoordinator = [[OnBoardingCoordinator alloc] initWithNavigationController:navigationController onBoardingItems:onBoardingItems];
    
    [self.onBoardingCoordinator start];
    
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)hideDescription:(UIButton*)sender {
    [self.animator removeAllBehaviors];
    self.animator = nil;
    
    UIDynamicAnimator* animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.descriptionView];
    UIGravityBehavior* gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[self.descriptionView.descriptionHostView]];
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.descriptionView.descriptionHostView] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = M_PI_2;
    pushBehavior.magnitude = 60.0;
    [pushBehavior setTargetOffsetFromCenter:UIOffsetMake(30.0f, 0.0f) forItem:self.descriptionView.descriptionHostView];
    
    [animator addBehavior:gravityBeahvior];
    [animator addBehavior:pushBehavior];
    
    self.animator = animator;
    
//    [UIView animateWithDuration:0.25f animations:^{
//        sender.superview.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [sender.superview removeFromSuperview];
//    }];
    
    [UIView animateWithDuration:0.25f delay:0.5f options:kNilOptions animations:^{
        self.descriptionView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.descriptionView removeFromSuperview];
        self.descriptionView = nil;
        
        [self.animator removeAllBehaviors];
        self.animator = nil;
    }];
}

- (UIGravityBehavior*)gravity {
    if (!_gravity)
        _gravity = [[UIGravityBehavior alloc] initWithItems:@[self.descriptionView.descriptionHostView]];
    
    return _gravity;
}

- (UIDynamicAnimator*)animator {
    if (!_animator)
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.descriptionView];
    
    return _animator;
}

#pragma mark -

- (void)becameActive:(NSNotification*)notification {
    [self addMeasurement];
    
    self.measurementArray = [self.measurementManager measurements];
    
    self.stopIndex = 100;
    [self updateMainViewAndAddPrediction:YES];
}

- (void)addMeasurement {
    [self.measurementManager addMeasurement];
}

- (void)updateMainViewAndAddPrediction:(BOOL)addPrecition {
    self.mainView.measurementArray = self.measurementArray;

    BatteryCalculation *batteryCalculation = [[BatteryCalculation alloc] initWithMeasurementArray:self.measurementArray];
    
    NSUInteger stopIndex = [self currentStopIndexFromBatteryCalculation:batteryCalculation];
    NSUInteger stopIndexForDisplay = [batteryCalculation stopIndex];
    NSInteger predictionOfResitualSeconds = [batteryCalculation preditionOfResidualTimeWithStopIndex:stopIndex];
    self.predictionOfTotalSeconds = [batteryCalculation preditionOfTotalTimeWithStopIndex:stopIndex];

    self.timeDiff = [batteryCalculation timeDiffForStopIndex:stopIndex];

    self.levelDiff = [batteryCalculation levelDiffForStopIndex:stopIndex];
    NSLog(@"shouldAddPrediction: %@", [self shouldAddPrediction] ? @YES : @NO);
    if (self.levelDiff >= 0.4f && addPrecition && [self shouldAddPrediction]) {
        [self addPredictionTouched:nil];
    }
    
    self.mainView.stopCalcAtPointFromNow = stopIndex;
    NSString *residualTimeString = [Prediction timeStringFromSeconds:predictionOfResitualSeconds];
    NSString *totalTimeString = [Prediction timeStringFromSeconds:self.predictionOfTotalSeconds];
    NSDate *predictionDate = [NSDate dateWithTimeIntervalSinceNow:predictionOfResitualSeconds];
    if (!residualTimeString) {
        self.mainView.addPredictionButton.userInteractionEnabled = YES;
        self.mainView.addPredictionButton.alpha = 1.0f;
        NSInteger averageTotalTime = [[NSUserDefaults standardUserDefaults] integerForKey:kAverageTotalRuntimeKey];
        if (averageTotalTime > 0) {
            Measurement *firstMeasurement = [self.measurementArray firstObject];
            if ([firstMeasurement.batteryState integerValue] == UIDeviceBatteryStateUnplugged) {
                NSInteger residualTime = averageTotalTime*[firstMeasurement.level floatValue];
                residualTimeString = [NSString stringWithFormat:@"~%@", [Prediction timeStringFromSeconds:residualTime]];
                totalTimeString = [NSString stringWithFormat:@"~%@", [Prediction timeStringFromSeconds:averageTotalTime]];
            }
        }
    } else {
        self.mainView.addPredictionButton.userInteractionEnabled = YES;
        self.mainView.addPredictionButton.alpha = 1.0f;
    }
    
    self.timeDiff = [batteryCalculation timeDiffForStopIndex:stopIndexForDisplay];
    self.mainView.numberOfHours = (NSUInteger)((self.timeDiff/3600.0f > 6.0f) ? self.timeDiff/3600.0f : 6.0f);
    
    self.mainView.residualTimeString = residualTimeString ? : @"-:-";
    self.mainView.totalTimeString = totalTimeString ? : @"-:-";
    self.mainView.residualTime = (CGFloat)predictionOfResitualSeconds;
    self.mainView.timeOfOffString = [self.dateFormatter stringFromDate:predictionDate];
    
//    Measurement *firstMeasurement = [self.measurementArray firstObject];
//    if (!totalTimeString && [firstMeasurement.batteryState integerValue] == UIDeviceBatteryStateUnplugged) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No data", nil) message:NSLocalizedString(@"There are not enough measurements to estimate the residual battery duration. Add geo fences to allow automatic measurements or add reminders to remind you to open UntilOff during the day.", nil) preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            
//        }];
//        
//        [alertController addAction:okAction];
//        [self presentViewController:alertController animated:YES completion:nil];
//
//    }

    [self.mainView setNeedsDisplay];
}

- (BOOL)shouldAddPrediction {
    NSInteger savingFequency = [[NSUserDefaults standardUserDefaults] integerForKey:[SettingsTableViewController savingFrequencyIdentifer]];
    switch (savingFequency) {
        case 0:
            //Magic
            return YES;
            break;
        case 1:
            //Once per day
        {
            NSDate *lastPredictionDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastPredictionDate];
            NSInteger averageTotalTime = [[NSUserDefaults standardUserDefaults] integerForKey:kAverageTotalRuntimeKey];
            NSInteger timeThresholdInSeconds = 12 * 60 * 60;
            if (averageTotalTime > 0) {
                timeThresholdInSeconds = averageTotalTime/2;
            }
            if ([[NSDate date] timeIntervalSinceDate:lastPredictionDate] < timeThresholdInSeconds) {
                return NO;
            } else {
                return YES;
            }
            break;
        }
        case 2:
            //Manually
            return NO;
            break;
        default:
            break;
    }
    return YES;
}

//- (void)clearView:(NSNotification*)notification {
//    [self clearMainView];
//}
//
//- (void)clearMainView {
//    self.mainView.measurementArray = [NSArray array];
//    
//    [self.mainView setNeedsDisplay];
//}

- (void)addPredictionTouched:(UIButton*)sender
{
    if (sender) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSDate *lastPredictionDate = [userDefaults objectForKey:kLastPredictionDate];
        NSDate *nowDate = [NSDate date];
        
        if ([nowDate timeIntervalSinceDate:lastPredictionDate] < 60)
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add again", nil) message:NSLocalizedString(@"It looks like this predition has already been saved. Do you still want to save it?", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            
            UIAlertAction *addPredictionAction = [UIAlertAction actionWithTitle:@"Save Prediction" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self addPrediction];
            }];
            [alertController addAction:addPredictionAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            return;
        }
    }
    [self addPrediction];
}

- (void)addPrediction
{
    NSDate *nowDate = [NSDate date];
    Prediction *prediction = [NSEntityDescription insertNewObjectForEntityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
    prediction.timeBasis = @(self.timeDiff);
    prediction.levelBasis = @(self.levelDiff);
    prediction.date = nowDate;
    prediction.totalRuntime = @(self.predictionOfTotalSeconds);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nowDate forKey:kLastPredictionDate];
    [userDefaults synchronize];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    
    UILabel *predictionLabel = [[UILabel alloc] initWithFrame:self.mainView.totalLabel.frame];
    predictionLabel.textColor = [UIColor redColor];
    predictionLabel.text = self.mainView.totalLabel.text;
    predictionLabel.font = self.mainView.totalLabel.font;
    predictionLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainView addSubview:predictionLabel];
    
    [UIView animateWithDuration:0.6f delay:0.5f options:kNilOptions animations:^{
        predictionLabel.center = self.mainView.predictionOverviewButton.center;
        predictionLabel.alpha = 0.0f;
        predictionLabel.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
    } completion:^(BOOL finished) {
        [predictionLabel removeFromSuperview];
    }];
}

- (NSUInteger)currentStopIndexFromBatteryCalculation:(BatteryCalculation*)batteryCalculation
{
    return MIN(self.stopIndex, [batteryCalculation stopIndex]);
//    return [batteryCalculation stopIndex];
}

//- (NSString*)timeStringFromSeconds:(NSInteger)seconds
//{
//    NSLog(@"seconds: %ld", (long)seconds);
//    if (seconds < 1)
//    {
//        return nil;
//    }
//    NSInteger hours = seconds/3600;
//    NSNumber *minutes = @(seconds/60-hours*60);
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    [formatter setPositiveFormat: @"00"];
//    return [NSString stringWithFormat:@"%ld:%@", (long)hours, [formatter stringFromNumber:minutes]];
//}

#pragma mark - actions
- (void)showLocationServiceSettings:(UIButton*)sender
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager requestAlwaysAuthorization];
    } else {
        LocationServiceViewController *locationServiceViewController = [[LocationServiceViewController alloc] init];
        locationServiceViewController.managedObjectContext = self.managedObjectContext;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationServiceViewController];
        [self presentViewController:navigationController animated:YES completion:^{}];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BOOL alreadyInitialized = [[NSUserDefaults standardUserDefaults] boolForKey:@"alreadyInitialized"];
    if (status == kCLAuthorizationStatusAuthorizedAlways && !alreadyInitialized) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"alreadyInitialized"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        LocationServiceViewController *locationServiceViewController = [[LocationServiceViewController alloc] init];
        locationServiceViewController.managedObjectContext = self.managedObjectContext;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationServiceViewController];
        [self presentViewController:navigationController animated:YES completion:^{}];
    }
}

- (void)showPredictionOverview:(UIButton*)sender
{
    PredictionsOverviewViewController *predictionOverviewViewController = [[PredictionsOverviewViewController alloc] init];
    predictionOverviewViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:predictionOverviewViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

- (void)addNotification:(UIButton*)sender
{
    NSLog(@"0");
    NotificationViewController *notificationViewController = [[NotificationViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:notificationViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

- (void)showSettings:(UIButton*)sender {
    SettingsTableViewController *settingsViewController = [[SettingsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - resture action
- (void)dismissOverlay:(UITapGestureRecognizer*)sender
{
    [sender.view removeFromSuperview];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self.mainView] anyObject];
    CGPoint locationOfTouch = [touch locationInView:self.mainView];
    
    self.mainView.sliderConstraint.constant = locationOfTouch.x;
    [self.mainView updateConstraintsIfNeeded];
    
    NSUInteger indexFromLocation = [self.mainView indexForXPosition:locationOfTouch.x];
    if (self.stopIndex != indexFromLocation)
    {
        self.stopIndex = [self.mainView indexForXPosition:locationOfTouch.x];
        [self updateMainViewAndAddPrediction:NO];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self.mainView] anyObject];
    CGPoint locationOfTouch = [touch locationInView:self.mainView];
     
    self.mainView.sliderConstraint.constant = locationOfTouch.x;
    [self.mainView updateConstraintsIfNeeded];
    
    NSUInteger indexFromLocation = [self.mainView indexForXPosition:locationOfTouch.x];
    if (self.stopIndex != indexFromLocation)
    {
        self.stopIndex = [self.mainView indexForXPosition:locationOfTouch.x];
        [self updateMainViewAndAddPrediction:NO];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGFloat xPosition = [self.mainView xPositionForIndex:self.stopIndex];
    self.mainView.sliderConstraint.constant = xPosition;
    [UIView animateWithDuration:0.3f animations:^{
        [self.mainView updateConstraintsIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

@end
