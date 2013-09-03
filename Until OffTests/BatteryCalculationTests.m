//
//  BatteryCalculationTests.m
//  Until Off
//
//  Created by dasdom on 01.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MockMeasurement.h"
#import "BatteryCalculation.h"

@interface BatteryCalculationTests : XCTestCase

@property (nonatomic, strong) NSArray *measurementArray;

@end

@implementation BatteryCalculationTests

- (void)setUp
{
    [super setUp];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSDate *nowDate = [NSDate date];

    MockMeasurement *mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.1f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f) sinceDate:nowDate];;
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.4f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*2.0f) sinceDate:nowDate];;
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.5f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*3.0f) sinceDate:nowDate];;
    [mutableArray addObject:mockMeasurement];
 
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.7f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*3.5f) sinceDate:nowDate];;
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.6f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*4.0f) sinceDate:nowDate];;
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.8f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*5.0f) sinceDate:nowDate];;
    [mutableArray addObject:mockMeasurement];
    
    self.measurementArray = [mutableArray copy];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSearchOfStopIndexForCalculation
{
    BatteryCalculation *batteryCalculation = [[BatteryCalculation alloc] init];
    NSUInteger stopIndex = [batteryCalculation stopIndexForMeasurements:(NSArray*)self.measurementArray];
    
    XCTAssertEqual(stopIndex, (NSUInteger)3);
}



@end
