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
    if (!self.measurementArray || [self.measurementArray count] < 1)
    {
        return 0;
    }
    
    NSUInteger stopIndex = 0;
    if ([[[self.measurementArray firstObject] valueForKey:@"batteryState"] integerValue] != UIDeviceBatteryStateUnplugged)
    {
        return stopIndex;
    }
    
    CGFloat previousLevel = [[[self.measurementArray firstObject] valueForKey:@"level"] floatValue];
    NSDate *firstDate = [[self.measurementArray firstObject] valueForKey:@"date"];
    for (int i = 1; i < [self.measurementArray count]; i++)
    {
        id measurement = self.measurementArray[i];
        CGFloat level = [[measurement valueForKey:@"level"] floatValue];
        if (level < previousLevel)
        {
            break;
        }
        if ([[measurement valueForKey:@"batteryState"] integerValue] == UIDeviceBatteryStateCharging)
        {
            break;
        }
        // Don't use measurements which are older than 48h
        if ([firstDate timeIntervalSinceDate:[measurement valueForKey:@"date"]] > 60.0f*60.0f*48.0f)
        {
            break;
        }
        previousLevel = level;
        stopIndex = i;
    }
    
    return stopIndex;
}

- (NSInteger)preditionOfResidualTimeWithStopIndex:(NSUInteger)stopIndex
{
    if (stopIndex >= [self.measurementArray count])
    {
        return 0;
    }
    id firstMeasurement = [self.measurementArray firstObject];
    id stopIndexMeasurement = self.measurementArray[stopIndex];
    
    CGFloat firstLevel = [[firstMeasurement valueForKey:@"level"] floatValue];
    CGFloat levelDiff = [[stopIndexMeasurement valueForKey:@"level"] floatValue] - firstLevel;
    CGFloat timeDiff = [[firstMeasurement valueForKey:@"date"] timeIntervalSinceDate:[stopIndexMeasurement valueForKey:@"date"]];
//    NSLog(@"firstLevel: %f, levelDiff: %f, timeDiff: %f", firstLevel, levelDiff, timeDiff);
    return (levelDiff > 0.0f) ? (NSInteger)(timeDiff*firstLevel/levelDiff) : 0;
}

- (NSInteger)preditionOfTotalTimeWithStopIndex:(NSUInteger)stopIndex
{
    if (stopIndex >= [self.measurementArray count])
    {
        return 0;
    }
    id firstMeasurement = [self.measurementArray firstObject];
    id stopIndexMeasurement = self.measurementArray[stopIndex];
    
    CGFloat firstLevel = [[firstMeasurement valueForKey:@"level"] floatValue];
    CGFloat levelDiff = [[stopIndexMeasurement valueForKey:@"level"] floatValue] - firstLevel;
    CGFloat timeDiff = [[firstMeasurement valueForKey:@"date"] timeIntervalSinceDate:[stopIndexMeasurement valueForKey:@"date"]];
    
    return (levelDiff > 0.0f) ? (NSInteger)(timeDiff/levelDiff) : 0;
}

- (CGFloat)timeDiffForStopIndex:(NSUInteger)stopIndex
{
    if (stopIndex >= [self.measurementArray count])
    {
        return 0;
    }
    id firstMeasurement = [self.measurementArray firstObject];
    id stopIndexMeasurement = self.measurementArray[stopIndex];

    return [[firstMeasurement valueForKey:@"date"] timeIntervalSinceDate:[stopIndexMeasurement valueForKey:@"date"]];
}

- (CGFloat)levelDiffForStopIndex:(NSUInteger)stopIndex
{
    if (stopIndex >= [self.measurementArray count])
    {
        return 0.0f;
    }
    id firstMeasurement = [self.measurementArray firstObject];
    id stopIndexMeasurement = self.measurementArray[stopIndex];
    
    CGFloat firstLevel = [[firstMeasurement valueForKey:@"level"] floatValue];
    return [[stopIndexMeasurement valueForKey:@"level"] floatValue] - firstLevel;
}


@end
