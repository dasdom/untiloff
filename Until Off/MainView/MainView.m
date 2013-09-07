//
//  MainView.m
//  Until Off
//
//  Created by dasdom on 29.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "MainView.h"
#import "Measurement.h"

#define kSecondsPerHour 3600.0f
#define kXPositionOfZero 233.0f

@interface MainView ()
@property (nonatomic, strong) NSMutableArray *pointsArray;
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
        [self addSubview: titleLabel];
        
        _locationServiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *locationServiceImage = [UIImage imageNamed:@"locationServiceIcon"];
        [_locationServiceButton setImage:locationServiceImage forState:UIControlStateNormal];
        _locationServiceButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_locationServiceButton];
        
        NSArray *titleVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)];
        [self addConstraints:titleVerticalConstraints];
        
        NSArray *titleHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)];
        [self addConstraints:titleHorizontalConstraints];
        
        NSArray *locationServiceVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_locationServiceButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_locationServiceButton)];
        [self addConstraints:locationServiceVerticalConstraints];
        
        NSArray *locationServiceHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_locationServiceButton]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_locationServiceButton)];
        [self addConstraints:locationServiceHorizontalConstraints];
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
    
	NSDate *lastDate = ((Measurement*)[self.measurementArray firstObject]).date;
	CGFloat timeNorm = self.numberOfHours*kSecondsPerHour+7000;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
    CGRect diagramFrame = CGRectMake(20.0f, 72.0f, kXPositionOfZero-20.0f, 270.0f);
    CGRect residualFrame = CGRectMake(20.0f, 72.0f, kXPositionOfZero-20.0f, 270.0f);
    
	for (int i = 0; i <= self.numberOfHours/2; i++)
    {
        CGFloat xPos = diagramFrame.size.width+20-i*2*60*60*(diagramFrame.size.width+20)/timeNorm;
        NSLog(@"xPos: %f", xPos);
		CGContextMoveToPoint(context, xPos, CGRectGetMinY(diagramFrame));
		CGContextAddLineToPoint(context, xPos, CGRectGetMaxY(diagramFrame));
        CGContextSetRGBStrokeColor(context, 0.66, 0.66, 0.66, 1.0);
        CGContextSetLineWidth(context, 0.5f);
		CGContextStrokePath(context);
        if (self.numberOfHours < 20 || i%2 == 0)
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
    for (int i = 0; i < [self.measurementArray count]; i++)
    {
        Measurement *measurement = self.measurementArray[i];
        
        CGFloat timeDiff = [measurement.date timeIntervalSinceDate:lastDate];
        CGFloat pointX = diagramFrame.size.width+20.0f+timeDiff*(diagramFrame.size.width+20.0f)/timeNorm;
        CGFloat pointY = diagramFrame.origin.y+(1-[measurement.level floatValue])*(diagramFrame.size.height);
        
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
    
    CGFloat stopPosistion = width-30.0f;
    diagramFrame.size.width = stopPosistion-diagramFrame.origin.x;
    
//	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
//    CGContextSetLineWidth(context, 2.0f);
//	CGContextStrokePath(context);

    CGContextSetRGBFillColor(context, 102.0f/255.0f, 157.0f/255.0f, 107.0f/255.0f, 1.0f);
    CGContextFillRect(context, residualFrame);
    CGContextStrokePath(context);
    
    CGContextSaveGState(context);
    
    [[UIColor blackColor] setStroke];
    bezierPath.lineWidth = 2.0f;
    [bezierPath stroke];
    
    CGContextRestoreGState(context);
    
    CGContextMoveToPoint(context, kXPositionOfZero, CGRectGetMinY(diagramFrame)-15.0f);
	CGContextAddLineToPoint(context, kXPositionOfZero, CGRectGetMaxY(diagramFrame));
	CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 2.0f);
	CGContextStrokePath(context);
    
    for (NSValue *value in self.pointsArray) {
        CGPoint point = [value CGPointValue];
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
    CGSize residualStringSize = [residualString sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0f]}];
    [residualString drawAtPoint:CGPointMake(residualFrame.origin.x+(residualFrame.size.width-residualStringSize.width)/2.0f, residualFrame.origin.y+(residualFrame.size.height-residualStringSize.height)/2.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:25.0f], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSString *totalTimeString = [NSString stringWithFormat:@"Total Battery Duration %@h", self.totalTimeString];
    CGSize totalTimeStringSize = [totalTimeString sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];
    [totalTimeString drawAtPoint:CGPointMake(width-totalTimeStringSize.width-20.0f, height-105.0f) withAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0f]}];

}


@end
