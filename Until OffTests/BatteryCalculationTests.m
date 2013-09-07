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
@property (nonatomic, strong) BatteryCalculation *batteryCalculation;

@end

@implementation BatteryCalculationTests

- (void)setUp
{
    [super setUp];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSDate *nowDate = [NSDate date];

    MockMeasurement *mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.1f);
    mockMeasurement.date = nowDate;
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.4f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*2.0f) sinceDate:nowDate];
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.5f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*3.0f) sinceDate:nowDate];
    [mutableArray addObject:mockMeasurement];
 
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.7f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*3.5f) sinceDate:nowDate];
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.6f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*4.0f) sinceDate:nowDate];
    [mutableArray addObject:mockMeasurement];
    
    mockMeasurement = [[MockMeasurement alloc] init];
    mockMeasurement.level = @(0.8f);
    mockMeasurement.date = [NSDate dateWithTimeInterval:(-60.0f*60.0f*5.0f) sinceDate:nowDate];
    [mutableArray addObject:mockMeasurement];
    
    self.measurementArray = [mutableArray copy];
    
    _batteryCalculation = [[BatteryCalculation alloc] initWithMeasurementArray:self.measurementArray];
}

- (void)tearDown
{
    self.measurementArray = nil;
    [super tearDown];
}

- (void)testSearchOfStopIndexForCalculation
{
    NSUInteger stopIndex = [_batteryCalculation stopIndex];
    
    XCTAssertEqual(stopIndex, (NSUInteger)3);
}

- (void)testCalculationOfPredictionOfLeftTime
{
    NSUInteger stopIndex = [_batteryCalculation stopIndex];
    
    NSInteger predictionOfLeftTime = [_batteryCalculation preditionOfResidualTimeWithStopIndex:stopIndex];
    
    XCTAssertEqual(predictionOfLeftTime, (NSInteger)((60.0f*60.0f*3.5f)*0.1f/0.6f));
}

- (void)testCalculationOfPredictionOfTotalTime
{
    NSUInteger stopIndex = [_batteryCalculation stopIndex];

    NSInteger predictionOfTotalTime = [_batteryCalculation preditionOfTotalTimeWithStopIndex:stopIndex];

    XCTAssertEqual(predictionOfTotalTime, (NSInteger)((60.0f*60.0f*3.5f)/0.6f));
}


@end
