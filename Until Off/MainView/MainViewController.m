//
//  MainViewController.m
//  Until Off
//
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
#import "MeasurementsManager.h"
#import "DescriptionView.h"
#import "Utilities.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#define kLevelDiff @"kLevelDiff"
#define kTimeDiff @"kTimeDiff"
#define kMaxPointsInTimeForCalculation @"kMaxPointsInTimeForCalculation"

@interface MainViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) MainView *mainView;
@property (nonatomic, strong) NSArray *measurementArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MeasurementsManager *measurementManager;
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
        [_mainView.infoButton addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
        
        _measurementManager = [[MeasurementsManager alloc] initWithManagedObjectContext:managedObjectContext];
        
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)loadView
{
    self.view = _mainView;

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"appAlreadyStarted"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"appAlreadyStarted"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        DescriptionView *descriptionView = [[DescriptionView alloc] initWithFrame:bounds];
//        [descriptionView.dismissButton addTarget:descriptionView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:descriptionView];
        
        [self showDescription];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    for (Geofence *geofence in geofenceArray)
    {
        NSLog(@"geofence.name: %@", geofence.name);
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([geofence.latitude doubleValue], [geofence.longitude doubleValue]);
        CLCircularRegion *circularRegion = [[CLCircularRegion alloc] initWithCenter:coordinate radius:[geofence.radius floatValue] identifier:geofence.name];;
        [self.locationManager startMonitoringForRegion:circularRegion];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self.measurementManager addMeasurement];
}

#pragma mark -
- (void)showDescription
{
    DescriptionView *descriptionView = [[DescriptionView alloc] initWithFrame:self.view.bounds];
    [descriptionView.dismissButton addTarget:descriptionView action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:descriptionView];
}

#pragma mark -

- (void)becameActive:(NSNotification*)notification
{
    [self.measurementManager addMeasurement];
    
    self.measurementArray = [self.measurementManager measurements];
    
    [self updateMainView];
}

- (void)updateMainView
{
    self.mainView.measurementArray = self.measurementArray;

    BatteryCalculation *batteryCalculation = [[BatteryCalculation alloc] initWithMeasurementArray:self.measurementArray];
    
    NSUInteger stopIndex = [batteryCalculation stopIndex];
    NSInteger predictionOfResitualSeconds = [batteryCalculation preditionOfResidualTimeWithStopIndex:stopIndex];
    NSInteger predictionOfTotalSeconds = [batteryCalculation preditionOfTotalTimeWithStopIndex:stopIndex];
    
    CGFloat timeDiff = [batteryCalculation timeDiffForStopIndex:stopIndex];
    self.mainView.numberOfHours = (NSUInteger)((timeDiff/3600.0f > 6.0f) ? timeDiff/3600.0f : 6.0f);

    CGFloat levelDiff = [batteryCalculation levelDiffForStopIndex:stopIndex];
    if (levelDiff >= 0.7f)
    {
       Prediction *prediction = [NSEntityDescription insertNewObjectForEntityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
        prediction.timeBasis = @(timeDiff);
        prediction.levelBasis = @(levelDiff);
        prediction.date = [NSDate date];
        prediction.totalRuntime = @(predictionOfTotalSeconds);
        
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    }
    
    self.mainView.stopCalcAtPointFromNow = stopIndex;
    NSString *residualTimeString = [self timeStringFromSeconds:predictionOfResitualSeconds];
    NSString *totalTimeString = [self timeStringFromSeconds:predictionOfTotalSeconds];
    if (!residualTimeString)
    {
        NSInteger averageTotalTime = [[NSUserDefaults standardUserDefaults] integerForKey:kAverageTotalRuntimeKey];
        if (averageTotalTime > 0)
        {
            Measurement *firstMeasurement = [self.measurementArray firstObject];
            if ([firstMeasurement.batteryState integerValue] == UIDeviceBatteryStateUnplugged)
            {
                NSInteger residualTime = averageTotalTime*[firstMeasurement.level floatValue];
                residualTimeString = [NSString stringWithFormat:@"~%@", [self timeStringFromSeconds:residualTime]];
                totalTimeString = [NSString stringWithFormat:@"~%@", [self timeStringFromSeconds:averageTotalTime]];
            }
        }
    }
    
    self.mainView.residualTimeString = residualTimeString ? : @"-:-";
    self.mainView.totalTimeString = totalTimeString ? : @"-:-";
    self.mainView.residualTime = (CGFloat)predictionOfResitualSeconds;
    
    [self.mainView setNeedsDisplay];
}

- (NSString*)timeStringFromSeconds:(NSInteger)seconds
{
    NSLog(@"seconds: %d", seconds);
    if (seconds < 1)
    {
        return nil;
    }
    NSInteger hours = seconds/3600;
    NSNumber *minutes = @(seconds/60-hours*60);
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat: @"00"];
    return [NSString stringWithFormat:@"%d:%@", hours, [formatter stringFromNumber:minutes]];
}

#pragma mark - actions
- (void)showLocationServiceSettings:(UIButton*)sender
{
    LocationServiceViewController *locationServiceViewController = [[LocationServiceViewController alloc] init];
    locationServiceViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationServiceViewController];
//    navigationController.view.tintColor = [UIColor colorWithHue:357.0f/360.0f saturation:1.0f brightness:0.80f alpha:1.0f];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

- (void)showPredictionOverview:(UIButton*)sender
{
    PredictionsOverviewViewController *predictionOverviewViewController = [[PredictionsOverviewViewController alloc] init];
    predictionOverviewViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:predictionOverviewViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];

}

#pragma mark - resture action
- (void)dismissOverlay:(UITapGestureRecognizer*)sender
{
    [sender.view removeFromSuperview];
}

@end
