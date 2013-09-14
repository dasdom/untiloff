//
//  MainView.h
//  Until Off
//
//  Created by dasdom on 29.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainView : UIView

@property (nonatomic, strong) NSArray *measurementArray;
@property (nonatomic) NSUInteger numberOfHours;
//@property (nonatomic) NSUInteger startCalcAtPointFromNow;
@property (nonatomic) NSUInteger stopCalcAtPointFromNow;
@property (nonatomic, strong) NSString *residualTimeString;
@property (nonatomic, strong) NSString *totalTimeString;
@property (nonatomic, strong) UIButton *locationServiceButton;
@property (nonatomic, strong) UIButton *predictionOverviewButton;
@property (nonatomic) CGFloat residualTime;

@end
