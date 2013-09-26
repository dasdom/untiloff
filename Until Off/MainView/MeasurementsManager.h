//
//  MeasurementsManager.h
//  Until Off
//
//  Created by dasdom on 18.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeasurementsManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (void)addMeasurement;
- (NSArray*)measurements;

@end
