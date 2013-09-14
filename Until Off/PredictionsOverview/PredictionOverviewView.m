//
//  PredictionOverviewView.m
//  Until Off
//
//  Created by dasdom on 12.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PredictionOverviewView.h"
#import "Prediction.h"

@implementation PredictionOverviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, rect);
    
    for (Prediction *prediction in self.predictionsArray)
    {
        NSLog(@"totalRuntime: %@", prediction.totalRuntime);
    }
    
    NSNumber *minimum = [self.predictionsArray valueForKeyPath:@"@min.totalRuntime"];
    NSNumber *maximum = [self.predictionsArray valueForKeyPath:@"@max.totalRuntime"];
    NSNumber *average = [self.predictionsArray valueForKeyPath:@"@avg.totalRuntime"];

    NSString *minimumString = [NSString stringWithFormat:@"minimum %@", minimum];
    [minimumString drawAtPoint:CGPointMake(20.0f, 80.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}];
                                                                          
    NSString *maximumString = [NSString stringWithFormat:@"maximum %@", maximum];
    [maximumString drawAtPoint:CGPointMake(20.0f, 110.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}];
    
    NSString *averageString = [NSString stringWithFormat:@"average %@", average];
    [averageString drawAtPoint:CGPointMake(20.0f, 140.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f]}];
    
}


@end
