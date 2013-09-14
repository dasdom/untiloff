//
//  Measurement.h
//  Until Off
//
//  Created by dasdom on 10.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Measurement : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * batteryState;

@end
