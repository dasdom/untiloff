//
//  MeasurementsManager.m
//  Until Off
//
//  Created by dasdom on 18.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MeasurementsManager.h"
#import "Measurement.h"

@interface MeasurementsManager ()
@end

@implementation MeasurementsManager

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    if ((self = [super init]))
    {
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)addMeasurement
{
    NSDate *date = [NSDate date];
    CGFloat currentLevel = [[UIDevice currentDevice] batteryLevel];
    NSNumber *currentLevelNumber = [NSNumber numberWithFloat:currentLevel];
    NSNumber *batteryState = [NSNumber numberWithInteger:[[UIDevice currentDevice] batteryState]];
    
    Measurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    measurement.date = date;
    measurement.level = currentLevelNumber;
    measurement.batteryState = batteryState;
    
    NSArray *measurementsArray = [self measurements];
    if ([measurementsArray count] > 50)
    {
        [self.managedObjectContext deleteObject:[measurementsArray lastObject]];
    }
    
    [self saveContext];
}

- (NSArray*)measurements
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Measurement" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end