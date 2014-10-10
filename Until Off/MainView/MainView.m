//
//  MainView.m
//  Until Off
//
//  Created by dasdom on 29.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MainView.h"
#import "ElementFactory.h"
#import "Measurement.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

#define kSecondsPerHour 3600.0f
#define kXPositionOfZero self.frame.size.width-87.0f

@interface MainView ()
@property (nonatomic, strong) NSMutableArray *pointsArray;
@property (nonatomic) BOOL showTimes;
@property (nonatomic, strong) UILabel *residualLabel;
@end

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pointsArray = [[NSMutableArray alloc] init];
        _residualTimeString = [NSString string];
        _totalTimeString = [NSString string];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = NSLocalizedString(@"Lapse", nil);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        _infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        _infoButton.translatesAutoresizingMaskIntoConstraints = NO;
        _infoButton.accessibilityLabel = NSLocalizedString(@"Info", nil);
        _infoButton.accessibilityHint = NSLocalizedString(@"Shows the walkthrough again.", nil);
        [self addSubview:_infoButton];
        
        _locationServiceButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"locationServiceIcon"]];
        _locationServiceButton.accessibilityLabel = NSLocalizedString(@"Location service", nil);
        _locationServiceButton.accessibilityHint = NSLocalizedString(@"Opens location service screen.", nil);
        [self addSubview:_locationServiceButton];
        
        _predictionOverviewButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"distributionIcon"]];
        _predictionOverviewButton.accessibilityLabel = NSLocalizedString(@"Distribution", nil);
        _predictionOverviewButton.accessibilityHint = NSLocalizedString(@"Opens disctibution screen.", nil);
        [self addSubview:_predictionOverviewButton];
        
        _addPredictionButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"addPrediction"]];
        _addPredictionButton.accessibilityLabel = NSLocalizedString(@"Add prediction", nil);
        _addPredictionButton.accessibilityHint = NSLocalizedString(@"Adds the prediction to the distribution.", nil);
        [self addSubview:_addPredictionButton];
        
        _addNotificationButton = [ElementFactory mainScreenButtonWithImage:[UIImage imageNamed:@"notificationIcon"]];
        _addNotificationButton.accessibilityLabel = NSLocalizedString(@"Notification", nil);
        _addNotificationButton.accessibilityHint = NSLocalizedString(@"Lets you add notifications that you don't forget to open the app.", nil);
        [self addSubview:_addNotificationButton];
        
        _residualLabel = [[UILabel alloc] init];
        _residualLabel.textColor = [UIColor whiteColor];
//        _residualLabel.backgroundColor = [UIColor colorWithRed:102.0f/255.0f green:157.0f/255.0f blue:107.0f/255.0f alpha:1.0f];
        _residualLabel.backgroundColor = [UIColor clearColor];
        _residualLabel.textAlignment = NSTextAlignmentCenter;
        _residualLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f];
        [self addSubview:_residualLabel];
        
        _totalLabel = [[UILabel alloc] init];
        _totalLabel.textColor = [UIColor blackColor];
        _totalLabel.backgroundColor = [UIColor clearColor];
        _totalLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f];
        _totalLabel.adjustsFontSizeToFitWidth = YES;
        _totalLabel.minimumScaleFactor = 0.7f;
        _totalLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_totalLabel];
        
        _sliderView = [[UIView alloc] init];
        _sliderView.translatesAutoresizingMaskIntoConstraints = NO;
        _sliderView.backgroundColor = [Utilities globalTintColor];
        _sliderView.userInteractionEnabled = NO;
        [self addSubview:_sliderView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(titleLabel, _infoButton, _sliderView, _totalLabel, _locationServiceButton, _predictionOverviewButton, _addPredictionButton, _addNotificationButton);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel(40)]-10-[_sliderView(sliderHeight)]" options:0 metrics:@{@"sliderHeight" : @(frame.size.height-210.0f)} views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-[_infoButton]-|" options:0 metrics:nil views:viewsDictionary]];
        
        [_sliderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_sliderView(1)]" options:0 metrics:nil views:viewsDictionary]];
        
        _sliderConstraint = [NSLayoutConstraint constraintWithItem:_sliderView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:20.0f];
        [self addConstraint: _sliderConstraint];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_infoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_totalLabel]-15-[_addPredictionButton(==40,==_predictionOverviewButton,==_locationServiceButton,==_addNotificationButton)]-20-|" options:0 metrics:nil views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_addPredictionButton(==_locationServiceButton,==_predictionOverviewButton,==_addNotificationButton)]-[_predictionOverviewButton]-[_locationServiceButton]-[_addNotificationButton]-|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDictionary]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_totalLabel]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_totalLabel)]];
    
        self.shapeLayer = [CAShapeLayer layer];
        self.dashedLineShapeLayer = [CAShapeLayer layer];
    }
    return self;
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
//	CGFloat height = self.frame.size.height;
    CGRect diagramFrame = CGRectMake(20.0f, 72.0f, kXPositionOfZero-20.0f, self.frame.size.height-210.0f);
    CGRect residualFrame = CGRectMake(20.0f, 72.0f, kXPositionOfZero-20.0f, self.frame.size.height-210.0f);
    
	for (int i = 0; i <= self.numberOfHours/2; i++)
    {
        CGFloat xPos = diagramFrame.size.width+20-i*2*60*60*(diagramFrame.size.width+20)/timeNorm;
//        NSLog(@"xPos: %f", xPos);
		CGContextMoveToPoint(context, xPos, CGRectGetMinY(diagramFrame));
		CGContextAddLineToPoint(context, xPos, CGRectGetMaxY(diagramFrame));
        CGContextSetRGBStrokeColor(context, 0.66, 0.66, 0.66, 1.0);
        CGContextSetLineWidth(context, 0.5f);
		CGContextStrokePath(context);
        if (self.numberOfHours < 14 || (self.numberOfHours < 20  && i%2 == 0) || i%4 == 0)
        {
            NSString *labelText;
            if (i == 0)
            {
                labelText = NSLocalizedString(@"now", nil);
            }
            else
            {
                labelText = [NSString stringWithFormat: @"-%dh", i*2];
            }
            CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
            [labelText drawAtPoint:CGPointMake(xPos-labelSize.width/2.0f, CGRectGetMaxY(diagramFrame)+5.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor blackColor]}];
		}
	}
    CGFloat xPos = diagramFrame.size.width+20+2*60*60*(diagramFrame.size.width+20)/timeNorm;
    CGContextMoveToPoint(context, xPos, CGRectGetMinY(diagramFrame));
    CGContextAddLineToPoint(context, xPos, CGRectGetMaxY(diagramFrame));
    CGContextSetRGBStrokeColor(context, 0.66, 0.66, 0.66, 1.0);
    CGContextSetLineWidth(context, 0.5f);
    CGContextStrokePath(context);
    NSString *labelText = @"2h";
    CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
    [labelText drawAtPoint:CGPointMake(xPos-labelSize.width/2.0f, CGRectGetMaxY(diagramFrame)+5.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    for (int i = 1; i < 11; i++)
    {
        CGFloat yPos = diagramFrame.origin.y+(1-i*0.1)*(diagramFrame.size.height);
        CGContextMoveToPoint(context, 20, yPos);
        CGContextAddLineToPoint(context, width-20, yPos);
        CGContextSetRGBStrokeColor(context, 0.66, 0.66, 0.66, 1.0);
        CGContextSetLineWidth(context, 0.5f);
		CGContextStrokePath(context);
        if (i == 5 || i == 10)
        {
            NSString *labelText = [NSString stringWithFormat:@"%d %%", i*10];
            CGSize labelSize = [labelText sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
            [labelText drawAtPoint:CGPointMake(kXPositionOfZero+5.0f, yPos-labelSize.height) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f], NSForegroundColorAttributeName : [UIColor blackColor]}];
        }
    }

    [self.pointsArray removeAllObjects];
    
    CGFloat firstYPoint;
    CGFloat firstLevel;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSDate *lastDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:((Measurement*)[self.measurementArray firstObject]).date];
    for (int i = 0; i < [self.measurementArray count]; i++)
    {
        Measurement *measurement = self.measurementArray[i];
//        NSLog(@"i: %d, measurement.date: %@, lastDate: %@", i, measurement.date, lastDate);
        
        double timeDiff = [measurement.date timeIntervalSinceDate:lastDate];
        double pointX = diagramFrame.size.width+20.0f+timeDiff*(diagramFrame.size.width+20.0f)/timeNorm;
        double pointY = diagramFrame.origin.y+(1-[measurement.level floatValue])*(diagramFrame.size.height);
        
//        [[dateFormatter stringFromDate:measurement.date] drawAtPoint:CGPointMake(pointX-5.0f, pointY-15.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f], NSBackgroundColorAttributeName : [UIColor whiteColor]}];
        
        CGPoint point = CGPointMake(pointX, pointY);
        [self.pointsArray addObject:[NSValue valueWithCGPoint:point]];
        
        if (i == 0) {
//			CGContextMoveToPoint(context, pointX, pointY);
            [bezierPath moveToPoint:CGPointMake(pointX, pointY)];
            firstYPoint = pointY;
            firstLevel = [measurement.level floatValue];
		} else {
//			CGContextAddLineToPoint(context, pointX, pointY);
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
    [self updateConstraintsIfNeeded];
//    self.residualFrame = residualFrame;
    
    CGFloat stopPosistion = kXPositionOfZero;
    diagramFrame.size.width = stopPosistion-diagramFrame.origin.x;
    
//	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
//    CGContextSetLineWidth(context, 2.0f);
//	CGContextStrokePath(context);

    CGContextSetRGBFillColor(context, 0.0, 0.5, 1.0, 0.1);
    CGContextFillRect(context, diagramFrame);
    
    if (firstLevel > 0.2f)
    {
        CGContextSetRGBFillColor(context, 102.0f/255.0f, 157.0f/255.0f, 107.0f/255.0f, 1.0f);
    }
    else
    {
        CGContextSetRGBFillColor(context, 210.0f/255.0f, 102.0f/255.0f, 107.0f/255.0f, 1.0f);
    }
    CGContextFillRect(context, residualFrame);
    
    CGContextSaveGState(context);
    
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 2.0f;
//    [bezierPath stroke];
    
    self.shapeLayer.path = path;
    CGPathRelease(path);
    
    self.shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    self.shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
    self.shapeLayer.lineWidth = 2.0f;
    self.shapeLayer.strokeEnd = 1.0f;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0.0;
    animation.toValue = @1.0;
    animation.duration = 1.5f;
    [self.shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    
    NSString *residualString = [NSString stringWithFormat:@"%.0f%% ➞ %@h", firstLevel*100, self.residualTimeString];
    self.residualLabel.frame = residualFrame;
    self.residualLabel.text = residualString;
    self.residualLabel.clipsToBounds = YES;
    self.residualLabel.accessibilityLabel = NSLocalizedString(@"Not enough data to calculate residual battery duration.", nil);
    self.residualLabel.accessibilityHint = NSLocalizedString(@"To collect data, open the app from time to time.", nil);
    if (![self.residualTimeString isEqualToString:@"-:-"])
    {
        NSArray *componentsArray = [self.totalTimeString componentsSeparatedByString:@":"];
        if ([componentsArray count] > 1)
        {
            self.residualLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Residual battery %@ hours and %@ minutes", nil), componentsArray[0], componentsArray[1]];
            self.residualLabel.accessibilityHint = nil;
        }
    }
    
    [self.dashedLineShapeLayer removeAllAnimations];
    CGMutablePathRef dashedPath = CGPathCreateMutable();
    CGPathMoveToPoint(dashedPath, NULL, CGRectGetMaxX(residualFrame), CGRectGetMinY(residualFrame));
    CGPathAddLineToPoint(dashedPath, NULL, CGRectGetMaxX(residualFrame), CGRectGetMaxY(diagramFrame));
    self.dashedLineShapeLayer.path = dashedPath;
    self.dashedLineShapeLayer.strokeColor = [[UIColor clearColor] CGColor];
    CGPathRelease(dashedPath);
    
    CGRect labelFrame = self.residualLabel.frame;
    self.residualLabel.frame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y, 0.0f, labelFrame.size.height);
    [UIView animateWithDuration:1.5f animations:^{
        self.residualLabel.frame = labelFrame;
    } completion:^(BOOL finished) {
        if (self.residualTime > 0)
        {
            NSLog(@"finished: %@", finished?@YES:@NO);
//            UIBezierPath *dashedLine = [[UIBezierPath alloc] init];
//            [dashedLine moveToPoint:CGPointMake(CGRectGetMaxX(residualFrame), CGRectGetMinY(residualFrame))];
//            [dashedLine addLineToPoint:CGPointMake(kXPositionOfZero+self.residualTime*(kXPositionOfZero)/timeNorm, CGRectGetMaxY(diagramFrame))];
//            dashedLine.lineWidth = 2;
//            CGFloat dashedLinePattern[] = {3, 3, 3, 3};
//            [dashedLine setLineDash: dashedLinePattern count: 4 phase: 0];
//            [dashedLine stroke];
            
            CGMutablePathRef dashedPath = CGPathCreateMutable();
            CGPathMoveToPoint(dashedPath, NULL, CGRectGetMaxX(residualFrame), CGRectGetMinY(residualFrame));
            CGPathAddLineToPoint(dashedPath, NULL, kXPositionOfZero+self.residualTime*(kXPositionOfZero)/timeNorm, CGRectGetMaxY(diagramFrame));
            self.dashedLineShapeLayer.path = dashedPath;
            CGPathRelease(dashedPath);
            
            self.dashedLineShapeLayer.fillColor = [[UIColor clearColor] CGColor];
            self.dashedLineShapeLayer.strokeColor = [[UIColor blackColor] CGColor];
            self.dashedLineShapeLayer.lineWidth = 2.0f;
            self.dashedLineShapeLayer.strokeEnd = 1.0f;
            self.dashedLineShapeLayer.lineDashPattern = @[@3, @3, @3, @3];
            
            CABasicAnimation *dashedAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            dashedAnimation.fromValue = @0.0;
            dashedAnimation.toValue = @1.0;
            dashedAnimation.duration = 2.0f;
            [self.dashedLineShapeLayer addAnimation:dashedAnimation forKey:@"strokeEnd"];

        }
    }];
    
    
    CGContextRestoreGState(context);
    
    CGContextMoveToPoint(context, kXPositionOfZero, CGRectGetMinY(diagramFrame)-15.0f);
	CGContextAddLineToPoint(context, kXPositionOfZero, CGRectGetMaxY(diagramFrame));
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 2.0f);
	CGContextStrokePath(context);
    
    for (int i = 0; i < [self.pointsArray count]; i++) {
        NSValue *value = self.pointsArray[i];
        
        Measurement *measurement = self.measurementArray[i];
        CGPoint point = [value CGPointValue];
        
        if (self.showTimes)
        {
            NSString *timeString = [NSString stringWithFormat:@" %@ ", [dateFormatter stringFromDate:measurement.date]];
            [timeString drawAtPoint:CGPointMake(point.x-10.0f, point.y-18.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f], NSBackgroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.8f], NSForegroundColorAttributeName : [UIColor blackColor]}];
        }
		CGContextAddArc(context, point.x, point.y, 3, 0, 2*M_PI, NO);
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
        CGContextFillPath(context);
//		CGContextStrokePath(context);
    }
    
    CGContextMoveToPoint(context, 20, CGRectGetMaxY(diagramFrame));
	CGContextAddLineToPoint(context, width-20, CGRectGetMaxY(diagramFrame));
    CGContextSetLineWidth(context, 1.0f);
    CGContextStrokePath(context);
    
//    NSString *residualString = [NSString stringWithFormat:@"%.0f%% ➞ %@h", firstLevel*100, self.residualTimeString];
//    self.residualLabel.frame = residualFrame;
//    self.residualLabel.text = residualString;
//    self.residualLabel.clipsToBounds = YES;
//    self.residualLabel.accessibilityLabel = NSLocalizedString(@"Not enough data to calculate residual battery duration.", nil);
//    self.residualLabel.accessibilityHint = NSLocalizedString(@"To collect data, open the app from time to time.", nil);
//    if (![self.residualTimeString isEqualToString:@"-:-"])
//    {
//        NSArray *componentsArray = [self.totalTimeString componentsSeparatedByString:@":"];
//        if ([componentsArray count] > 1)
//        {
//            self.residualLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Residual battery %@ hours and %@ minutes", nil), componentsArray[0], componentsArray[1]];
//            self.residualLabel.accessibilityHint = nil;
//        }
//    }
//    
//    CGRect labelFrame = self.residualLabel.frame;
//    self.residualLabel.frame = CGRectMake(labelFrame.origin.x, labelFrame.origin.y, 0.0f, labelFrame.size.height);
//    [UIView animateWithDuration:1.5f animations:^{
//        self.residualLabel.frame = labelFrame;
//    } completion:^(BOOL finished) {
//        
//    }];

//    CGSize residualStringSize = [residualString sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0f]}];
//    [residualString drawAtPoint:CGPointMake(residualFrame.origin.x+(residualFrame.size.width-residualStringSize.width)/2.0f, residualFrame.origin.y+(residualFrame.size.height-residualStringSize.height)/2.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0f], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSString *totalTimeString;
    if (firstLevel < 1.0f)
    {
        totalTimeString = [NSString stringWithFormat:NSLocalizedString(@"100%% ➞ %@h", nil), self.totalTimeString];
    }
    else
    {
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
    
//    CGSize totalTimeStringSize = [totalTimeString sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];
//    [totalTimeString drawAtPoint:CGPointMake(width-totalTimeStringSize.width-20.0f, height-105.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];

}

- (NSUInteger)indexForXPosition:(CGFloat)xPosition
{
    NSUInteger index = self.stopCalcAtPointFromNow;
    for (int i = 0; i < [self.pointsArray count]; i++)
    {
        CGPoint point = [self.pointsArray[i] CGPointValue];
        if (fabsf(point.x - xPosition) < 5)
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


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    self.showTimes = YES;
//    [self setNeedsDisplay];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    self.showTimes = NO;
//    [self setNeedsDisplay];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    self.showTimes = NO;
//    [self setNeedsDisplay];
//}


@end
