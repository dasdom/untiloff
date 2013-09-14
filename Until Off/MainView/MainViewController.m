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
#import <CoreLocation/CoreLocation.h>

#define kLevelDiff @"kLevelDiff"
#define kTimeDiff @"kTimeDiff"
#define kMaxPointsInTimeForCalculation @"kMaxPointsInTimeForCalculation"

@interface MainViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) MainView *mainView;
@property (nonatomic, strong) NSArray *measurementArray;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation MainViewController

- (id)init
{
    if ((self = [super init]))
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return self;
}

- (void)loadView
{
    _mainView = [[MainView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [_mainView.locationServiceButton addTarget:self action:@selector(showLocationServiceSettings:) forControlEvents:UIControlEventTouchUpInside];
    [_mainView.predictionOverviewButton addTarget:self action:@selector(showPredictionOverview:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view = _mainView;
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
    [self addMeasurement];
}

#pragma mark -

- (void)becameActive:(NSNotification*)notification {
    [self addMeasurement];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *fetchError;
    self.measurementArray = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&fetchError];
    
    if ([self.measurementArray count] > 50) {
        [self.managedObjectContext deleteObject:self.measurementArray[0]];
    }
    
//    NSLog(@"measurementArray %@", self.measurementArray);
//    
//    for (Measurement *measurement in self.measurementArray) {
//        NSLog(@"measurement.level: %@, date: %@", measurement.level, measurement.date);
//    }
    
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
    if (levelDiff > 0.1f)
    {
       Prediction *prediction = [NSEntityDescription insertNewObjectForEntityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
        prediction.timeBasis = @(timeDiff);
        prediction.levelBasis = @(levelDiff);
        prediction.date = [NSDate date];
        prediction.totalRuntime = @(predictionOfTotalSeconds);
        
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
    }
    
    self.mainView.stopCalcAtPointFromNow = stopIndex;
    self.mainView.residualTimeString = [self timeStringFromSeconds:predictionOfResitualSeconds];
    self.mainView.totalTimeString = [self timeStringFromSeconds:predictionOfTotalSeconds];
    self.mainView.residualTime = (CGFloat)predictionOfResitualSeconds;
    
    [self.mainView setNeedsDisplay];
}

- (NSString*)timeStringFromSeconds:(NSInteger)seconds
{
    NSLog(@"seconds: %d", seconds);
    if (seconds < 1)
    {
        return @"-:-";
    }
    NSInteger hours = seconds/3600;
    NSNumber *minutes = @(seconds/60-hours*60);
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat: @"00"];
    return [NSString stringWithFormat:@"%d:%@", hours, [formatter stringFromNumber:minutes]];
}

#pragma mark -

- (void)addMeasurement
{
    NSDate *date = [NSDate date];
    CGFloat currentLevel = [[UIDevice currentDevice] batteryLevel];
    NSNumber *currentLevelNumber = [NSNumber numberWithFloat:currentLevel];
    NSNumber *batteryState = [NSNumber numberWithInteger:[[UIDevice currentDevice] batteryState]];
    NSLog(@"batteryLevel: %f", [[UIDevice currentDevice] batteryLevel]);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CGFloat previousLevel = [userDefaults floatForKey:@"previousLevel"];
    
    if (currentLevel > previousLevel && currentLevel - previousLevel < 0.1f && [[UIDevice currentDevice] batteryState] != UIDeviceBatteryStateCharging)
    {
        return;
    }
    
    [userDefaults setFloat:currentLevel forKey:@"previousLevel"];
    [userDefaults synchronize];
    
    Measurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:[self managedObjectContext]];
    measurement.level = currentLevelNumber;
    measurement.date = date;
    measurement.batteryState = batteryState;
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
}

#pragma mark - actions
- (void)showLocationServiceSettings:(UIButton*)sender
{
    LocationServiceViewController *locationServiceViewController = [[LocationServiceViewController alloc] init];
    locationServiceViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:locationServiceViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

- (void)showPredictionOverview:(UIButton*)sender
{
    PredictionsOverviewViewController *predictionOverviewViewController = [[PredictionsOverviewViewController alloc] init];
    predictionOverviewViewController.managedObjectContext = self.managedObjectContext;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:predictionOverviewViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];

}

@end
