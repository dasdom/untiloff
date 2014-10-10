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
@property (nonatomic, strong) UIButton *addPredictionButton;
@property (nonatomic, strong) UIButton *addNotificationButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic) CGFloat residualTime;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) NSLayoutConstraint *sliderConstraint;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *dashedLineShapeLayer;
@property (nonatomic, strong) UILabel *totalLabel;

- (NSUInteger)indexForXPosition:(CGFloat)xPosition;
- (CGFloat)xPositionForIndex:(NSUInteger)index;

@end
