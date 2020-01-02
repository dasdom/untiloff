//  Created by dasdom on 29.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MainView.h"
#import "ElementFactory.h"
#import "Measurement.h"
#import "Utilities.h"
#import "UntilOffStyleKit.h"
#import <QuartzCore/QuartzCore.h>
#import "Until_Off-Swift.h"

#define kSecondsPerHour 3600.0f
#define kXPositionOfZero self.frame.size.width-160.0f

@interface MainView ()
@property (nonatomic, strong) NSMutableArray *pointsArray;
@property (nonatomic) BOOL showTimes;
@property (nonatomic, strong) UILabel *residualLabel;
@end

@implementation MainView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pointsArray = [[NSMutableArray alloc] init];
        _residualTimeString = [NSString string];
        _totalTimeString = [NSString string];
        
        _addPredictionButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"addPrediction"]];
        _addPredictionButton.accessibilityLabel = NSLocalizedString(@"Add prediction", nil);
        _addPredictionButton.accessibilityHint = NSLocalizedString(@"Adds the prediction to the distribution.", nil);

        _predictionOverviewButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"distributionIcon"]];
        _predictionOverviewButton.accessibilityLabel = NSLocalizedString(@"Distribution", nil);
        _predictionOverviewButton.accessibilityHint = NSLocalizedString(@"Opens disctibution screen.", nil);

        _locationServiceButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"locationServiceIcon"]];
        _locationServiceButton.accessibilityLabel = NSLocalizedString(@"Location service", nil);
        _locationServiceButton.accessibilityHint = NSLocalizedString(@"Opens location service screen.", nil);
        
        _addNotificationButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"notificationIcon"]];
        _addNotificationButton.accessibilityLabel = NSLocalizedString(@"Notification", nil);
        _addNotificationButton.accessibilityHint = NSLocalizedString(@"Lets you add notifications that you don't forget to open the app.", nil);
        
        UIStackView *buttonStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_addPredictionButton, _predictionOverviewButton, _locationServiceButton, _addNotificationButton]];
        buttonStackView.spacing = 10;
        buttonStackView.distribution = UIStackViewDistributionFillEqually;
        
        _residualLabel = [[UILabel alloc] init];
        _residualLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _residualLabel.textColor = [UIColor colorWithWhite:0.225 alpha:1.000];
        _residualLabel.backgroundColor = [UIColor clearColor];
        _residualLabel.textAlignment = NSTextAlignmentCenter;
        _residualLabel.numberOfLines = 0;
        _residualLabel.font = [UIFont systemFontOfSize:20];
        
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.textColor = [UIColor colorWithWhite:0.225 alpha:1.000];
        _totalLabel.backgroundColor = [UIColor clearColor];
        _totalLabel.font = [UIFont systemFontOfSize:14];
        _totalLabel.adjustsFontSizeToFitWidth = YES;
        _totalLabel.minimumScaleFactor = 0.7f;
        _totalLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        
        UIStackView *labelStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_residualLabel, _totalLabel]];
        labelStackView.spacing = 10;
        labelStackView.axis = NSTextLayoutOrientationVertical;
        
        UIStackView *mainStackView = [[UIStackView alloc] initWithArrangedSubviews:@[labelStackView, buttonStackView]];
        mainStackView.translatesAutoresizingMaskIntoConstraints = false;
        mainStackView.spacing = 55;
        mainStackView.axis = NSTextLayoutOrientationVertical;
        [self addSubview:mainStackView];
        
        _sliderView = [[UIView alloc] init];
        _sliderView.translatesAutoresizingMaskIntoConstraints = NO;
        _sliderView.backgroundColor = [Utilities globalTintColor];
        _sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
        
        _sliderConstraint = [_sliderView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:20];
    
        NSArray *layoutConstraints = @[
                                       [mainStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
                                       [mainStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
                                       [_addNotificationButton.heightAnchor constraintEqualToConstant:40],
                                       [_sliderView.widthAnchor constraintEqualToConstant:1],
                                       [_sliderView.heightAnchor constraintEqualToConstant:frame.size.height-310.0f],
                                       [_sliderView.topAnchor constraintEqualToAnchor:self.topAnchor constant:60],
                                       _sliderConstraint,
                                       ];

        if (@available(iOS 11.0, *)) {
            layoutConstraints = [layoutConstraints arrayByAddingObjectsFromArray:@[
                                                                                   [mainStackView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:-16],
                                                                                   ]];
        } else {
            layoutConstraints = [layoutConstraints arrayByAddingObjectsFromArray:@[
                                                                                   [mainStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-16],
                                                                                   ]];
        }
        
        [NSLayoutConstraint activateConstraints:layoutConstraints];
        
        _shapeLayer = [CAShapeLayer layer];
        _dashedLineShapeLayer = [CAShapeLayer layer];
    }
    return self;
}


- (void)drawPastTimesIn:(CGRect)diagramFrame timeNorm:(CGFloat)timeNorm {
    for (int i = 0; i <= self.numberOfHours/2; i++) {
        CGFloat xPos = diagramFrame.size.width+20-i*2*60*60*(diagramFrame.size.width+20)/timeNorm;
        //        NSLog(@"xPos: %f", xPos);
        
        if (self.numberOfHours < 14 || (self.numberOfHours < 20  && i%2 == 0) || i%4 == 0) {
            NSString *labelText;
            if (i == 0) {
                labelText = NSLocalizedString(@"now", nil);
            } else {
                labelText = [NSString stringWithFormat: @"-%dh", i*2];
            }
            CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
            [labelText drawAtPoint:CGPointMake(xPos-labelSize.width/2.0f, CGRectGetMaxY(diagramFrame)+5.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor blackColor]}];
        }
    }
}

- (void)addYAxisLabels:(CGRect)diagramFrame {
    for (int i = 1; i < 11; i++) {
        CGFloat yPos = diagramFrame.origin.y+(1-i*0.1)*(diagramFrame.size.height);
        if (i == 5 || i == 10)
        {
            NSString *labelText = [NSString stringWithFormat:@"%d%%", i*10];
            CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
            [labelText drawAtPoint:CGPointMake(kXPositionOfZero+5.0f, yPos-labelSize.height) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor blackColor]}];
        }
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    
    CGContextClearRect(context, rect);
    [[UIColor colorWithWhite:0.9f alpha:1.0f] setFill];
//    [[UIColor colorWithRed:0.141 green:0.149 blue:0.204 alpha:1.0] setFill];

    CGContextFillRect(context, rect);
    
    if (self.numberOfHours < 1) {
        return;
    }

    [self.layer addSublayer:self.shapeLayer];
    [self.layer addSublayer:self.dashedLineShapeLayer];

	CGFloat timeNorm = self.numberOfHours*kSecondsPerHour+7000;
	CGFloat width = self.frame.size.width;
    CGFloat diagramHeight = self.frame.size.height - 350;
    CGFloat diagramY = 100;
    if (@available(iOS 11.0, *)) {
        diagramHeight -= self.safeAreaInsets.bottom;
        diagramY += 20;
    }
//    NSLog(@"ratio: %lf, %lf", self.frame.size.height, self.frame.size.height/350.0);
    CGRect diagramFrame = CGRectMake(20.0f, diagramY, kXPositionOfZero-20.0f, diagramHeight);
    CGRect residualFrame = CGRectMake(20.0f, diagramY, kXPositionOfZero-20.0f, diagramHeight);
    
    [self drawPastTimesIn:diagramFrame timeNorm:timeNorm];
  
    [self addYAxisLabels:diagramFrame];

    [self.pointsArray removeAllObjects];
    
    CGFloat firstYPoint;
    CGFloat firstLevel;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    Measurement *firstMeasurement = [self.measurementArray firstObject];
    NSDate *lastDate = [firstMeasurement.date copy];
    for (int i = 0; i < [self.measurementArray count]; i++) {
        Measurement *measurement = self.measurementArray[i];

        double timeDiff = [measurement.date timeIntervalSinceDate:lastDate];
        double pointX = diagramFrame.size.width+20.0f+timeDiff*(diagramFrame.size.width+20.0f)/timeNorm;
        double pointY = diagramFrame.origin.y+(1-[measurement.level floatValue])*(diagramFrame.size.height);

        CGPoint point = CGPointMake(pointX, pointY);
        [self.pointsArray addObject:[NSValue valueWithCGPoint:point]];

        if (i == 0) {
            [bezierPath moveToPoint:CGPointMake(pointX, pointY)];
            firstYPoint = pointY;
            firstLevel = [measurement.level floatValue];
        } else {
            [bezierPath addLineToPoint:CGPointMake(pointX, pointY)];
            if (i == self.stopCalcAtPointFromNow) {
                diagramFrame.origin.x = pointX;
            }
        }

        if (pointX < 0) {
            break;
        }
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    [self.pointsArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        CGPoint point = [value CGPointValue];
        if (idx == [self.pointsArray count]-1) {
            CGPathMoveToPoint(path, NULL, point.x, point.y);
        } else {
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
        }
    }];
    
    residualFrame.origin.y = firstYPoint;
    residualFrame.size.height = CGRectGetMaxY(diagramFrame)-firstYPoint;
    
    self.sliderConstraint.constant = diagramFrame.origin.x;
//    [self updateConstraintsIfNeeded];
    
    CGFloat stopPosistion = kXPositionOfZero;
    diagramFrame.size.width = stopPosistion-diagramFrame.origin.x;

    CGContextSetRGBFillColor(context, 0.0, 0.5, 1.0, 0.1);
//
//    if (firstLevel > 0.2f) {
//        CGContextSetRGBFillColor(context, 102.0f/255.0f, 157.0f/255.0f, 107.0f/255.0f, 1.0f);
//    } else {
//        CGContextSetRGBFillColor(context, 210.0f/255.0f, 102.0f/255.0f, 107.0f/255.0f, 1.0f);
//    }
//
    CGContextSaveGState(context);
    
    [[UIColor colorWithWhite:0.225 alpha:1.000] setStroke];
    bezierPath.lineWidth = 2.0f;
//    [bezierPath stroke];
    
    self.shapeLayer.path = path;
    CGPathRelease(path);
    
    if (!self.showTimes) {
        self.shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        self.shapeLayer.strokeColor = [UIColor colorWithWhite:0.225 alpha:1.000].CGColor;

        self.shapeLayer.lineWidth = 2.0f;
        self.shapeLayer.strokeEnd = 1.0f;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @0.0;
        animation.toValue = @1.0;
        animation.duration = 0.5f;
        [self.shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    }
    
    NSString *residualString = @"Not enough data.\nCome back later again.";
//    self.residualLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
//    self.residualLabel.frame = residualFrame;
    self.residualLabel.clipsToBounds = YES;
    self.residualLabel.accessibilityLabel = NSLocalizedString(@"Not enough data to calculate residual battery duration.", nil);
    self.residualLabel.accessibilityHint = NSLocalizedString(@"To collect data, open the app from time to time.", nil);
    if (![self.residualTimeString isEqualToString:@"-:-"])
    {
//        BOOL showTimeOfOff = [[NSUserDefaults standardUserDefaults] boolForKey:[SettingsTableViewController showTimeOfOffKey]];
//        if (showTimeOfOff) {
//            residualString = [NSString stringWithFormat:@"%.0f%% ➔ 0%% : %@h (%@)", firstLevel*100, self.residualTimeString, self.timeOfOffString];
//            residualString = [NSString stringWithFormat:@"Remaining : %@h\n(until %@)", self.residualTimeString, self.timeOfOffString];
//        } else {
//            residualString = [NSString stringWithFormat:@"%.0f%% ➔ 0%% : %@h", firstLevel*100, self.residualTimeString];
            residualString = [NSString stringWithFormat:@"Remaining : %@h", self.residualTimeString];
//        }
        NSArray *componentsArray = [self.totalTimeString componentsSeparatedByString:@":"];
        if ([componentsArray count] > 1)
        {
            self.residualLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Residual battery %@ hours and %@ minutes", nil), componentsArray[0], componentsArray[1]];
            self.residualLabel.accessibilityHint = nil;
        }
    }
    
    self.residualLabel.text = residualString;
//    self.residualLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0f];
  
    [self.dashedLineShapeLayer removeAllAnimations];
    CGMutablePathRef dashedPath = CGPathCreateMutable();
    CGPathMoveToPoint(dashedPath, NULL, CGRectGetMaxX(residualFrame), CGRectGetMinY(residualFrame));
    CGPathAddLineToPoint(dashedPath, NULL, CGRectGetMaxX(residualFrame), CGRectGetMaxY(diagramFrame));
    self.dashedLineShapeLayer.path = dashedPath;
    self.dashedLineShapeLayer.strokeColor = [[UIColor clearColor] CGColor];
    CGPathRelease(dashedPath);
    
    self.residualLabel.alpha = 0;
  
    CGPoint residualPoint = CGPointMake(kXPositionOfZero+self.residualTime*(kXPositionOfZero)/timeNorm, CGRectGetMaxY(diagramFrame));
    if (!self.showTimes) {
      [UIView animateWithDuration:0.5f delay:0.0f options:kNilOptions animations:^{
        self.residualLabel.alpha = 1.0;
      } completion:^(BOOL finished) {
        
        if (self.residualTime > 0)
        {
            if (finished) {
                CGMutablePathRef dashedPath = CGPathCreateMutable();
                CGPoint startPoint = CGPointMake(CGRectGetMaxX(residualFrame), CGRectGetMinY(residualFrame));
                CGPathMoveToPoint(dashedPath, NULL, startPoint.x, startPoint.y);
                
                CGPoint endPoint = CGPointMake(kXPositionOfZero+self.residualTime*(kXPositionOfZero)/timeNorm, CGRectGetMaxY(diagramFrame));
                CGPathAddLineToPoint(dashedPath, NULL, endPoint.x, endPoint.y);
                
                CGFloat diffX = endPoint.x-startPoint.x;
                CGFloat diffY = endPoint.y-startPoint.y;
                
                CGFloat pathLength = sqrtf(diffX*diffX + diffY*diffY);
                
                self.dashedLineShapeLayer.path = dashedPath;
                CGPathRelease(dashedPath);
                
                self.dashedLineShapeLayer.fillColor = [[UIColor clearColor] CGColor];
                self.dashedLineShapeLayer.strokeColor = [UIColor colorWithWhite:0.225 alpha:1.000].CGColor;
                self.dashedLineShapeLayer.lineWidth = 2.0f;
                self.dashedLineShapeLayer.strokeEnd = 1.0f;
                self.dashedLineShapeLayer.lineDashPattern = @[@3, @3, @3, @3];
                
                CABasicAnimation *dashedAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                dashedAnimation.fromValue = @0.0;
                dashedAnimation.toValue = @1.0;
                dashedAnimation.duration = pathLength/240;
              
                [self.dashedLineShapeLayer addAnimation:dashedAnimation forKey:@"strokeEnd"];
                
            }
        }
    }];
    }
    
    CGContextRestoreGState(context);
    
    CGContextMoveToPoint(context, kXPositionOfZero, CGRectGetMinY(diagramFrame)-15.0f);
	CGContextAddLineToPoint(context, kXPositionOfZero, CGRectGetMaxY(diagramFrame));
	CGContextSetRGBStrokeColor(context, 0.225, 0.225, 0.225, 1.0);
    CGContextSetLineWidth(context, 2.0f);
	CGContextStrokePath(context);
    
    NSString *residualStringWithSymbol = [NSString stringWithFormat:@"%@h", self.residualTimeString];
    CGSize labelSize = [residualStringWithSymbol sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
    [residualStringWithSymbol drawAtPoint:CGPointMake(residualPoint.x-labelSize.width/2.0f, CGRectGetMaxY(diagramFrame)+5.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor blackColor]}];

    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSValue *value = self.pointsArray[i];
        
        Measurement *measurement = self.measurementArray[i];
        CGPoint point = [value CGPointValue];
        
        if (self.showTimes)
        {
            NSString *timeString = [NSString stringWithFormat:@" %@ ", [dateFormatter stringFromDate:measurement.date]];
            UIFont *font = [UIFont systemFontOfSize:9];
            [timeString drawAtPoint:CGPointMake(point.x-10.0f, point.y-18.0f) withAttributes:@{NSFontAttributeName : font, NSBackgroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.8f], NSForegroundColorAttributeName : [UIColor blackColor]}];
        }
//        if (i == 0) {
            CGContextAddArc(context, point.x, point.y, 3, 0, 2*M_PI, NO);
//        } else {
//            CGContextAddArc(context, point.x, point.y, 3, 0, 2*M_PI, NO);
//        }
        CGContextSetRGBFillColor(context, 0.225, 0.225, 0.225, 1.0f);
        CGContextFillPath(context);
		CGContextStrokePath(context);
    }
  
    CGContextMoveToPoint(context, 20, CGRectGetMaxY(diagramFrame));
	CGContextAddLineToPoint(context, width-20, CGRectGetMaxY(diagramFrame));
    CGContextSetLineWidth(context, 1.0f);
    CGContextStrokePath(context);
    
    NSString *totalTimeString;
    if (firstLevel < 1.0f) {
        totalTimeString = [NSString stringWithFormat:NSLocalizedString(@"100%% ➔ 0%% : %@h", nil), self.totalTimeString];
    } else {
        totalTimeString = @"";
    }
    
    self.totalLabel.text = totalTimeString;
    self.totalLabel.accessibilityLabel = NSLocalizedString(@"Not enough data to calculate total battery duration.", nil);
    if (![self.totalTimeString isEqualToString:@"-:-"])
    {
        NSArray *componentsArray = [self.totalTimeString componentsSeparatedByString:@":"];
        if ([componentsArray count] > 1)
        {
            self.totalLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Total battery duration %@ hours and %@ minutes.", nil), componentsArray[0], componentsArray[1]];
            self.residualLabel.accessibilityHint = nil;
        }
    }

}

- (NSUInteger)indexForXPosition:(CGFloat)xPosition
{
    NSUInteger index = self.stopCalcAtPointFromNow;
    for (int i = 0; i < [self.pointsArray count]; i++)
    {
        CGPoint point = [self.pointsArray[i] CGPointValue];
        if (fabs(point.x - xPosition) < 5)
        {
            index = i;
            self.stopCalcAtPointFromNow = index;
            break;
        }
    }
    return index;
}

- (CGFloat)xPositionForIndex:(NSUInteger)index
{
    CGPoint point = [self.pointsArray[index] CGPointValue];
    return point.x;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 1) {
        self.showTimes = YES;
        [self setNeedsDisplay];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 1) {
        self.showTimes = NO;
        [self setNeedsDisplay];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 1) {
        self.showTimes = NO;
        [self setNeedsDisplay];
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}


@end
