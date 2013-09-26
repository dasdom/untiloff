//
//  MeasurementsManagerTests.m
//  Until Off
//
//  Created by dasdom on 18.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MeasurementsManager.h"
#import "Measurement.h"

@interface MeasurementsManagerTests : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) MeasurementsManager *measurementsManager;
@end

@implementation MeasurementsManagerTests

- (void)setUp
{
    [super setUp];
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]];
    NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    XCTAssertTrue([storeCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL] ? YES : NO, @"Should be able to add in-memory store");
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    _managedObjectContext.persistentStoreCoordinator = storeCoordinator;
    
    _measurementsManager = [[MeasurementsManager alloc] initWithManagedObjectContext:_managedObjectContext];
}

- (void)tearDown
{
    self.managedObjectContext = nil;
    [super tearDown];
}

- (void)testManagerHasManagedObjectContext
{
    XCTAssertNotNil(self.measurementsManager.managedObjectContext);
}

- (void)testAdditionOfMeasurement
{
    [self.measurementsManager addMeasurement];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSError *fetchError;
    NSArray *measurementArray = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&fetchError];
    
    XCTAssertEqual([measurementArray count], (NSUInteger)1);
}

- (void)testThatAddedMeasurementHasValues
{
    [self.measurementsManager addMeasurement];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSError *fetchError;
    NSArray *measurementArray = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&fetchError];
    
    Measurement *measurement = [measurementArray lastObject];
    XCTAssertNotNil(measurement.date);
    XCTAssertNotNil(measurement.level);
    XCTAssertNotNil(measurement.batteryState);
}

- (void)testMeasurementsCanBeFetched
{
    [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];

    NSArray *measurementsArray = [self.measurementsManager measurements];
    
    XCTAssertEqual([measurementsArray count], (NSUInteger)2);
}

- (void)testMeasurementsAreFetchedInDecendingOrder
{
    Measurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    measurement.date = [NSDate distantFuture];
    
    measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    measurement.date = [NSDate distantPast];

    NSArray *measurementsArray = [self.measurementsManager measurements];
    Measurement *firstMeasurement = [measurementsArray firstObject];
    Measurement *lastMeasurement = [measurementsArray lastObject];
    
    XCTAssertTrue([firstMeasurement.date compare:lastMeasurement.date] == NSOrderedDescending);
    
    measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    measurement.date = [NSDate distantPast];
    
    measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    measurement.date = [NSDate distantFuture];
    
    measurementsArray = [self.measurementsManager measurements];
    firstMeasurement = [measurementsArray firstObject];
    lastMeasurement = [measurementsArray lastObject];
    
    XCTAssertTrue([firstMeasurement.date compare:lastMeasurement.date] == NSOrderedDescending);
}

- (void)testThatMaximal50MeasurementsAreStored
{
    for (int i = 0; i < 52; i++)
    {
        [self.measurementsManager addMeasurement];
    }

    NSArray *measurementsArray = [self.measurementsManager measurements];
    XCTAssertEqual([measurementsArray count], (NSUInteger)50);
}

- (void)testThatTheOldestMeasurementIsDeletedIfMoreThan50MeasurementsAreTaken
{
    for (int i = 0; i < 49; i++) {
        [self.measurementsManager addMeasurement];
    }
    Measurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    measurement.date = [NSDate distantPast];
    measurement.level = @(0.0f);
    measurement.batteryState = @(UIDeviceBatteryStateUnplugged);
    
    NSArray *measurementsArray = [self.measurementsManager measurements];
    Measurement *lastMeasurement = [measurementsArray lastObject];
    XCTAssertEqual([lastMeasurement.batteryState integerValue], (NSInteger)UIDeviceBatteryStateUnplugged);
    
    [self.measurementsManager addMeasurement];
    
    measurementsArray = [self.measurementsManager measurements];
    lastMeasurement = [measurementsArray lastObject];
    XCTAssertNotEqual([lastMeasurement.batteryState integerValue], (NSInteger)UIDeviceBatteryStateUnplugged);
}

@end
