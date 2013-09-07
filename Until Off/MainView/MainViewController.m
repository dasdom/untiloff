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
#import "AppDelegate.h"
#import "BatteryCalculation.h"

#define kLevelDiff @"kLevelDiff"
#define kTimeDiff @"kTimeDiff"
#define kMaxPointsInTimeForCalculation @"kMaxPointsInTimeForCalculation"

@interface MainViewController ()
@property (nonatomic, strong) MainView *mainView;
@property (nonatomic, strong) NSArray *measurementArray;
@end

@implementation MainViewController

- (void)loadView
{
    _mainView = [[MainView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.view = _mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSLog(@"measurementArray %@", self.measurementArray);
    
    for (Measurement *measurement in self.measurementArray) {
        NSLog(@"measurement.level: %@, date: %@", measurement.level, measurement.date);
    }
//    [self calculateAveragePrediction];
    
    [self updateMainView];
    
//    self.mainView.stopCalcAtPointFromNow = [self.measurementArray count] - [calculationDictionary[kMaxPointsInTimeForCalculation] integerValue];
//	
//	self.mainView.numberOfHours = (timeDiff/3600.0f > 6.0f) ? timeDiff/3600.0f : 6.0f;
    
//    [[self predictionView] setNeedsDisplay];
//    
//    [[self diagramView] setNeedsDisplay];
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

    self.mainView.stopCalcAtPointFromNow = stopIndex;
    self.mainView.residualTimeString = [self timeStringFromSeconds:predictionOfResitualSeconds];
    self.mainView.totalTimeString = [self timeStringFromSeconds:predictionOfTotalSeconds];

    [self.mainView setNeedsDisplay];
}

- (NSString*)timeStringFromSeconds:(NSInteger)seconds
{
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
    NSNumber *currentLevelNumber = [NSNumber numberWithFloat: [[UIDevice currentDevice] batteryLevel]];
    NSLog(@"batteryLevel: %f", [[UIDevice currentDevice] batteryLevel]);
    
    Measurement *measurement = [NSEntityDescription insertNewObjectForEntityForName: @"Measurement" inManagedObjectContext: [self managedObjectContext]];
    [measurement setLevel: currentLevelNumber];
    [measurement setDate: date];
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];
}

//#pragma mark -
//
//- (NSDictionary*)computeLifeTimeWithMeasurements:(NSArray*)measurementArray andStopAtIndex:(NSInteger)stop {
//    Measurement *lastMeasurement = [measurementArray lastObject];
//    
//   	CGFloat previousLevel = 0.0;
//	CGFloat timeDiff;
//	CGFloat levelDiff;
//    NSInteger maxPointsInTimeForCalculation = 0;
//	NSDate *previousDate = [lastMeasurement date];
//	for (int i = [measurementArray count]-1; i >= stop; i--) {
//        Measurement *measurement = measurementArray[i];
//		timeDiff = [[lastMeasurement date] timeIntervalSinceDate:measurement.date];
//		levelDiff = [measurement.level floatValue] - [lastMeasurement.level floatValue];
//		float stepLevelDiff = [measurement.level floatValue] - previousLevel;
//		if (stepLevelDiff < 0) {
//			break;
//		}
//		if (timeDiff > 172800.0f) { //don't use timediffs larger than 48 h
//			break;
//		}
//        maxPointsInTimeForCalculation++;
//		previousLevel = [measurement.level floatValue];
//		previousDate = [measurement date];
//	}
//    
//	levelDiff = previousLevel - [lastMeasurement.level floatValue];
//	timeDiff = [[lastMeasurement date] timeIntervalSinceDate: previousDate];
//	NSLog(@"levelDiff: %f, timeDiff: %f", levelDiff, timeDiff);
//    
//    return @{kLevelDiff: @(levelDiff), kTimeDiff: @(timeDiff), kMaxPointsInTimeForCalculation: @(maxPointsInTimeForCalculation)};
//}

//#pragma mark -
//
//- (CGFloat)updateLabelsWithStart: (NSInteger)startInteger andStop: (NSInteger)stopInteger {
//    CGSize levelsAndTimes = [self computeLifeTimeWithMeasurements: [self measurementArray] fromInt: startInteger toInt: stopInteger];
//    float levelDiff = levelsAndTimes.width;
//    float timeDiff = levelsAndTimes.height;
//    
//	if (levelDiff > 0) {
//        CGFloat lastLevel = [[(Measurement*)[[self measurementArray] lastObject] level] floatValue];
//        int hours = timeDiff*lastLevel/(levelDiff*3600);
//        NSNumber *minutes = [NSNumber numberWithInt: ((timeDiff*lastLevel/(levelDiff*3600))-hours)*60];
//        int totalHours = timeDiff/(levelDiff*3600);
//        NSNumber *totalMinutes = [NSNumber numberWithInt: ((timeDiff/(levelDiff*3600))-totalHours)*60];
//        int usedHours = timeDiff/3600.0f;
//        NSNumber *usedMinutes = [NSNumber numberWithInt: (timeDiff/3600.0f-usedHours)*60];
//        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//        [formatter setPositiveFormat: @"00"];
//        [[self predictionLabel] setText: [NSString stringWithFormat: @"%d:%@ h", hours, [formatter stringFromNumber: minutes]]];
//        [[self totalLivetimeLabel] setText: [NSString stringWithFormat: @"%d:%@ h", totalHours, [formatter stringFromNumber: totalMinutes]]];
//        [self setTimeDiffNumber: [[NSNumber alloc] initWithDouble: timeDiff/(levelDiff*3600)]];
//        
//        [self setTotalLivetimeInMinutes: [NSNumber numberWithInteger: totalHours*60+[totalMinutes integerValue]]];
//        [self setTimeBasis: [NSNumber numberWithInteger: usedHours*60+[usedMinutes integerValue]]];
//        [self setLevelBasis: [NSNumber numberWithInteger: (int)levelDiff]];
//        [[self savePredictionButton] setEnabled: YES];
//        [[self savePredictionButton] setAlpha: 1.0f];
//    } else {
//        [[self predictionLabel] setText:@"-:- h"];
//        [[self totalLivetimeLabel] setText:@"-:- h"];
//        
//        [self setTotalLivetimeInMinutes: [NSNumber numberWithInteger: 0]];
//        [self setTimeBasis: [NSNumber numberWithInteger: 1]];
//        [self setLevelBasis: [NSNumber numberWithInteger: 1]];
//        [[self savePredictionButton] setEnabled: NO];
//        [[self savePredictionButton] setAlpha: 0.5f];
//	}
//    return timeDiff;
//}


@end
