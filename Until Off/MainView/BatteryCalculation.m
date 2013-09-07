//
//  BatteryCalculation.m
//  Until Off
//
//  Created by dasdom on 01.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "BatteryCalculation.h"

@interface BatteryCalculation ()
@property (nonatomic, strong) NSArray *measurementArray;
@end

@implementation BatteryCalculation

- (id)initWithMeasurementArray:(NSArray*)measurementArray
{
    if ((self = [super init]))
    {
        _measurementArray = [measurementArray copy];
    }
    return self;
}

- (NSUInteger)stopIndex
{
    if (!self.measurementArray || [self.measurementArray count] < 1) {
        return 0;
    }
    
    NSUInteger stopIndex = 0;
    CGFloat previousLevel = [[[self.measurementArray firstObject] valueForKey:@"level"] floatValue];
    NSDate *firstDate = [[self.measurementArray firstObject] valueForKey:@"date"];
    for (int i = 1; i < [self.measurementArray count]; i++) {
        id measurement = self.measurementArray[i];
        CGFloat level = [[measurement valueForKey:@"level"] floatValue];
        if (level < previousLevel) {
            break;
        }
        // Don't use measurements which are older than 48h
        if ([firstDate timeIntervalSinceDate:[measurement valueForKey:@"date"]] > 60.0f*60.0f*48.0f) {
            break;
        }
        previousLevel = level;
        stopIndex = i;
    }
    
    return stopIndex;
}

- (NSInteger)preditionOfResidualTimeWithStopIndex:(NSUInteger)stopIndex
{
    id firstMeasurement = [self.measurementArray firstObject];
    id stopIndexMeasurement = self.measurementArray[stopIndex];
    
    CGFloat firstLevel = [[firstMeasurement valueForKey:@"level"] floatValue];
    CGFloat levelDiff = [[stopIndexMeasurement valueForKey:@"level"] floatValue] - firstLevel;
    CGFloat timeDiff = [[firstMeasurement valueForKey:@"date"] timeIntervalSinceDate:[stopIndexMeasurement valueForKey:@"date"]];
    NSLog(@"firstLevel: %f, levelDiff: %f, timeDiff: %f", firstLevel, levelDiff, timeDiff);
    return (levelDiff > 0.1f) ? (NSInteger)(timeDiff*firstLevel/levelDiff) : 0;
}

- (NSInteger)preditionOfTotalTimeWithStopIndex:(NSUInteger)stopIndex
{
    id firstMeasurement = [self.measurementArray firstObject];
    id stopIndexMeasurement = self.measurementArray[stopIndex];
    
    CGFloat firstLevel = [[firstMeasurement valueForKey:@"level"] floatValue];
    CGFloat levelDiff = [[stopIndexMeasurement valueForKey:@"level"] floatValue] - firstLevel;
    CGFloat timeDiff = [[firstMeasurement valueForKey:@"date"] timeIntervalSinceDate:[stopIndexMeasurement valueForKey:@"date"]];
    
    return (levelDiff > 0.1f) ? (NSInteger)(timeDiff/levelDiff) : 0;
}

- (CGFloat)timeDiffForStopIndex:(NSUInteger)stopIndex
{
    id firstMeasurement = [self.measurementArray firstObject];
    id stopIndexMeasurement = self.measurementArray[stopIndex];

    return [[firstMeasurement valueForKey:@"date"] timeIntervalSinceDate:[stopIndexMeasurement valueForKey:@"date"]];

}


@end
