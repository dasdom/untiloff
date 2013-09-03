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

@interface MainView ()
@property (nonatomic, strong) NSMutableArray *pointsArray;
@end

@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.pointsArray = [[NSMutableArray alloc] init];
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
    
	NSDate *lastDate;
	CGFloat timeNorm = self.numberOfHours*kSecondsPerHour+7000;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;
    CGRect diagramFrame = CGRectMake(20.0f, 40.0f, width-40.0f, height-115.0f);
    
    NSUInteger indexOfLastElement = [self.measurementArray count]-1;
    [self.pointsArray removeAllObjects];
    for (int i = indexOfLastElement; i >= 0; i--) {
        Measurement *measurement = self.measurementArray[i];
        
        CGFloat timeDiff = [measurement.date timeIntervalSinceDate:lastDate];
        CGFloat pointX = diagramFrame.size.width+30.0f+timeDiff*(diagramFrame.size.width+20.0f)/timeNorm;
		CGFloat pointY = 40+(1-[measurement.level floatValue])*(diagramFrame.size.height);
        
        CGPoint point = CGPointMake(pointX, pointY);
        [self.pointsArray addObject:[NSValue valueWithCGPoint:point]];
        
        if (i == indexOfLastElement) {
			CGContextMoveToPoint(context, pointX, pointY);
            lastDate = measurement.date;
		} else {
			CGContextAddLineToPoint(context, pointX, pointY);
            
            if (i == self.stopCalcAtPointFromNow) {
                diagramFrame.origin.x = pointX;
            }
		}
	}
    CGFloat stopPosistion = width-30.0f;
    diagramFrame.size.width = stopPosistion-diagramFrame.origin.x;
    
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextStrokePath(context);

    
	for (NSValue *value in self.pointsArray) {
        CGPoint point = [value CGPointValue];
		CGContextAddArc(context, point.x, point.y, 3, 0, 2*M_PI, NO);
		CGContextStrokePath(context);
    }
}


@end
