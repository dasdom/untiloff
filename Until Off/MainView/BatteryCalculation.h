//
//  BatteryCalculation.h
//  Until Off
//
//  Created by dasdom on 01.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BatteryCalculation : NSObject

- (id)initWithMeasurementArray:(NSArray*)measurementArray;
- (NSUInteger)stopIndex;
- (NSInteger)preditionOfResidualTimeWithStopIndex:(NSUInteger)stopIndex;
- (NSInteger)preditionOfTotalTimeWithStopIndex:(NSUInteger)stopIndex;
- (CGFloat)timeDiffForStopIndex:(NSUInteger)stopIndex;
- (CGFloat)levelDiffForStopIndex:(NSUInteger)stopIndex;

@end
