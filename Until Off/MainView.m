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

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
 
    UIColor *textColor = [UIColor blackColor];
    
	UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(30, 5, rect.size.width-20, 20)];
	titleLabel.text = NSLocalizedString(@"diagram_title", nil);
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.textColor = textColor;
	titleLabel.backgroundColor = [UIColor whiteColor];
	[self addSubview: titleLabel];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
	NSDate *date;
	CGFloat tNorm = self.numberOfHours*kSecondsPerHour+7000;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
    CGRect frameOfRect = CGRectMake(20.0f, 40.0f, width-40.0f, height-115.0f);
    CGFloat stopPosistion = frameOfRect.size.width;
    NSUInteger indexOfLastElement = [[self measurementArray] count]-1;
	for (int i = indexOfLastElement; i >= 0; i--) {
        Measurement *measurement = self.measurementArray[i];
		if (i == indexOfLastElement) {
			CGFloat levelFloat = [measurement.level floatValue];
			CGContextMoveToPoint(context, frameOfRect.size.width+30.0f, 40+(1-levelFloat)*(frameOfRect.size.height));
			date = [measurement date];
            if (i == self.stopCalcAtPointFromNow) {
                stopPosistion = frameOfRect.size.width+30.0f;
            }
		} else {
			CGFloat level = [measurement.level floatValue];
			CGFloat tDiff = [measurement.date timeIntervalSinceDate:date];
            CGFloat pointX = frameOfRect.size.width+30.0f+tDiff*(frameOfRect.size.width+20.0f)/tNorm;
			CGContextAddLineToPoint(context, pointX, 40+(1-level)*(frameOfRect.size.height));
            
            if (i == self.startCalcAtPointFromNow) {
                frameOfRect.origin.x = pointX;
            } else if (i == self.stopCalcAtPointFromNow) {
                stopPosistion = frameOfRect.size.width+30.0f+tDiff*(frameOfRect.size.width+20.0f)/tNorm;
            }
            
		}
		
	}
    stopPosistion = width-30;
    frameOfRect.size.width = stopPosistion-frameOfRect.origin.x;
    
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextStrokePath(context);

}


@end
