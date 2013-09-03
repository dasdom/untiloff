//
//  BatteryCalculation.m
//  Until Off
//
//  Created by dasdom on 01.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "BatteryCalculation.h"

@implementation BatteryCalculation

- (NSUInteger)stopIndexForMeasurements:(NSArray*)measurementArray
{
    if (!measurementArray || [measurementArray count] < 1) {
        return 0;
    }
    
    NSUInteger stopIndex = 0;
    CGFloat previousLevel = [[[measurementArray firstObject] valueForKey:@"level"] floatValue];
    for (int i = 1; i < [measurementArray count]; i++) {
        id measurement = [measurementArray objectAtIndex:i];
        CGFloat level = [[measurement valueForKey:@"level"] floatValue];
        NSLog(@"level: %f previousLevel: %f", level, previousLevel);
        if (level < previousLevel) {
            break;
        }
        previousLevel = level;
        stopIndex = i;
    }
    
    return stopIndex;
}

@end
