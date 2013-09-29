//
//  MainView.m
//  Until Off
//
//  Created by dasdom on 29.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MainView.h"
#import "Measurement.h"
#import <QuartzCore/QuartzCore.h>

#define kSecondsPerHour 3600.0f
#define kXPositionOfZero self.frame.size.width-87.0f

@interface MainView ()
@property (nonatomic, strong) NSMutableArray *pointsArray;
@property (nonatomic) BOOL showTimes;
@property (nonatomic, strong) UILabel *residualLabel;
@property (nonatomic, strong) UILabel *totalLabel;
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
        titleLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        _infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        _infoButton.translatesAutoresizingMaskIntoConstraints = NO;
        _infoButton.accessibilityLabel = NSLocalizedString(@"Info", nil);
        _infoButton.accessibilityHint = NSLocalizedString(@"Shows the walkthrough again.", nil);
        [self addSubview:_infoButton];
        
        _locationServiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationServiceButton setImage:[[UIImage imageNamed:@"locationServiceIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _locationServiceButton.translatesAutoresizingMaskIntoConstraints = NO;
        _locationServiceButton.contentMode = UIViewContentModeCenter;
        _locationServiceButton.layer.borderWidth = 0.5f;
        _locationServiceButton.layer.borderColor = [[UIColor colorWithHue:357.0f/360.0f saturation:1.0f brightness:0.80f alpha:1.0f] CGColor];
        _locationServiceButton.layer.cornerRadius = 3.0f;
        _locationServiceButton.accessibilityLabel = NSLocalizedString(@"Location service", nil);
        _locationServiceButton.accessibilityHint = NSLocalizedString(@"Opens location service screen.", nil);
        [self addSubview:_locationServiceButton];
        
        _predictionOverviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_predictionOverviewButton setImage:[[UIImage imageNamed:@"distributionIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _predictionOverviewButton.translatesAutoresizingMaskIntoConstraints = NO;
//        _predictionOverviewButton.backgroundColor = [UIColor yellowColor];
        _predictionOverviewButton.layer.borderWidth = 0.5f;
        _predictionOverviewButton.layer.borderColor = [[UIColor colorWithHue:357.0f/360.0f saturation:1.0f brightness:0.80f alpha:1.0f] CGColor];
        _predictionOverviewButton.layer.cornerRadius = 3.0f;
        _predictionOverviewButton.accessibilityLabel = NSLocalizedString(@"Distribution", nil);
        _predictionOverviewButton.accessibilityHint = NSLocalizedString(@"Opens disctibution screen.", nil);
        [self addSubview:_predictionOverviewButton];
        
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
        [self addSubview:_totalLabel];
        
        NSArray *titleVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)];
        [self addConstraints:titleVerticalConstraints];
        
        NSArray *titleHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-[_infoButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel, _infoButton)];
        [self addConstraints:titleHorizontalConstraints];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_infoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        NSArray *locationServiceVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_totalLabel]-15-[_locationServiceButton(==40,==_predictionOverviewButton)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_totalLabel,_locationServiceButton, _predictionOverviewButton)];
        [self addConstraints:locationServiceVerticalConstraints];
        
        NSArray *locationServiceHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_predictionOverviewButton(==_locationServiceButton)]-[_locationServiceButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_locationServiceButton, _predictionOverviewButton)];
        [self addConstraints:locationServiceHorizontalConstraints];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_totalLabel]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_totalLabel)]];
        
        [self addConstraint: [NSLayoutConstraint constraintWithItem:_predictionOverviewButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_locationServiceButton attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, rect);
    
	CGFloat timeNorm = self.numberOfHours*kSecondsPerHour+7000;
	CGFloat width = self.frame.size.width;
//	CGFloat height = self.frame.size.height;
    CGRect diagramFrame = CGRectMake(20.0f, 72.0f, kXPositionOfZero-20.0f, self.frame.size.height-210.0f);
    CGRect residualFrame = CGRectMake(20.0f, 72.0f, kXPositionOfZero-20.0f, self.frame.size.height-210.0f);
    
	for (int i = 0; i <= self.numberOfHours/2; i++)
    {
        CGFloat xPos = diagramFrame.size.width+20-i*2*60*60*(diagramFrame.size.width+20)/timeNorm;
        NSLog(@"xPos: %f", xPos);
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
        NSLog(@"i: %d, measurement.date: %@, lastDate: %@", i, measurement.date, lastDate);
        
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
	}
    
    residualFrame.origin.y = firstYPoint;
    residualFrame.size.height = CGRectGetMaxY(diagramFrame)-firstYPoint;
    
//    self.residualFrame = residualFrame;
    
    CGFloat stopPosistion = kXPositionOfZero;
    diagramFrame.size.width = stopPosistion-diagramFrame.origin.x;
    
//	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
//    CGContextSetLineWidth(context, 2.0f);
//	CGContextStrokePath(context);

    CGContextSetRGBFillColor(context, 0.0, 0.5, 1.0, 0.1);
    CGContextFillRect(context, diagramFrame);
    
    CGContextSetRGBFillColor(context, 102.0f/255.0f, 157.0f/255.0f, 107.0f/255.0f, 1.0f);
    CGContextFillRect(context, residualFrame);
    
    CGContextSaveGState(context);
    
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 2.0f;
    [bezierPath stroke];
    
    if (self.residualTime > 0)
    {
        UIBezierPath *dashedLine = [[UIBezierPath alloc] init];
        [dashedLine moveToPoint:CGPointMake(CGRectGetMaxX(residualFrame), CGRectGetMinY(residualFrame))];
        [dashedLine addLineToPoint:CGPointMake(kXPositionOfZero+self.residualTime*(kXPositionOfZero)/timeNorm, CGRectGetMaxY(diagramFrame))];
        dashedLine.lineWidth = 2;
        CGFloat dashedLinePattern[] = {3, 3, 3, 3};
        [dashedLine setLineDash: dashedLinePattern count: 4 phase: 0];
        [dashedLine stroke];
    }
    
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
    
    NSString *residualString = [NSString stringWithFormat:@"%.0f%% ➞ %@h", firstLevel*100, self.residualTimeString];
    self.residualLabel.frame = residualFrame;
    self.residualLabel.text = residualString;
    if ([self.residualTimeString isEqualToString:@"-:-"])
    {
        self.residualLabel.accessibilityLabel = NSLocalizedString(@"Not enough data to calculate residual battery duration.", nil);
        self.residualLabel.accessibilityHint = NSLocalizedString(@"To collect data, open the app from time to time.", nil);
    }
    else
    {
        NSArray *componentsArray = [self.totalTimeString componentsSeparatedByString:@":"];
        self.residualLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Residual battery %@ hours and %@ minutes", nil), componentsArray[0], componentsArray[1]];
    }
//    CGSize residualStringSize = [residualString sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0f]}];
//    [residualString drawAtPoint:CGPointMake(residualFrame.origin.x+(residualFrame.size.width-residualStringSize.width)/2.0f, residualFrame.origin.y+(residualFrame.size.height-residualStringSize.height)/2.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0f], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSString *totalTimeString = [NSString stringWithFormat:NSLocalizedString(@"Total Battery Duration %@h", nil), self.totalTimeString];
    self.totalLabel.text = totalTimeString;
    if ([self.totalTimeString isEqualToString:@"-:-"])
    {
        self.totalLabel.accessibilityLabel = NSLocalizedString(@"Not enough data to calculate total battery duration.", nil);
    }
    else
    {
        NSArray *componentsArray = [self.totalTimeString componentsSeparatedByString:@":"];
        self.totalLabel.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Total battery duration %@ hours and %@ minutes.", nil), componentsArray[0], componentsArray[1]];
    }
//    CGSize totalTimeStringSize = [totalTimeString sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];
//    [totalTimeString drawAtPoint:CGPointMake(width-totalTimeStringSize.width-20.0f, height-105.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.showTimes = YES;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.showTimes = NO;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.showTimes = NO;
    [self setNeedsDisplay];
}


@end
