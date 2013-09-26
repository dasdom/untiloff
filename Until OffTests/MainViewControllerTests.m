//
//  MainViewControllerTests.m
//  Until Off
//
//  Created by dasdom on 16.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MainViewController.h"
#import "MainView.h"

@interface MainViewController ()
- (NSString*)timeStringFromSeconds:(NSInteger)seconds;
@end

@interface MainViewControllerTests : XCTestCase
@property (nonatomic, strong) MainViewController *mainViewController;
@end

@implementation MainViewControllerTests

- (void)setUp
{
    [super setUp];
    _mainViewController = [[MainViewController alloc] init];
}

- (void)tearDown
{
    self.mainViewController = nil;
    [super tearDown];
}

- (void)testThatMainViewControllerHasAMainView
{
    XCTAssertTrue([self.mainViewController.view isMemberOfClass:[MainView class]]);
}

- (void)testCreationOfTimeStringFromSeconds
{
    NSInteger seconds = 3660;
    NSString *timeString = [self.mainViewController timeStringFromSeconds:seconds];
    XCTAssertEqualObjects(timeString, @"1:01");
}


@end
