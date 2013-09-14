//
//  Prediction.h
//  Until Off
//
//  Created by dasdom on 12.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Prediction : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * levelBasis;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * timeBasis;
@property (nonatomic, retain) NSNumber * totalRuntime;

@end
