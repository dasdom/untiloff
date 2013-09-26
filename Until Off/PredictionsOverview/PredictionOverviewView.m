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
    NSString *count = [self.predictionsArray valueForKeyPath:@"@count"];

    CGFloat minimalHour = floorf([minimum floatValue]/3600.0f-1.5f);
    CGFloat maximalHour = ceilf([maximum floatValue]/3600.f+0.5f);
    
//    NSArray *sortedPredictionsArray = [self.predictionsArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [((Prediction*)obj1).totalRuntime compare:((Prediction*)obj2).totalRuntime];
//    }];
    
    NSMutableArray *numberOfPredictionsForHours = [NSMutableArray array];
    for (int i = (int)minimalHour; i <= maximalHour; i++)
    {
        [numberOfPredictionsForHours addObject:@(0)];
    }
    
    NSInteger maximalNumberOfValues = 1;
    for (Prediction *prediction in self.predictionsArray)
    {
        NSInteger index = (NSInteger)([prediction.totalRuntime floatValue]/3600.0f-minimalHour-0.5f);
        NSInteger numberOfPredictions = [numberOfPredictionsForHours[index] integerValue]+1;
        numberOfPredictionsForHours[index] = @(numberOfPredictions);
        if (numberOfPredictions > maximalNumberOfValues)
        {
            maximalNumberOfValues = numberOfPredictions;
        }
    }
    
    NSInteger numberOfChannels = [numberOfPredictionsForHours count];
    CGFloat normX = (self.frame.size.width-40.0f)/(float)numberOfChannels;
    CGFloat normY = 290.0f/(float)maximalNumberOfValues;
    NSDictionary *attributeDictionary = @{NSFontAttributeName : [UIFont systemFontOfSize:10.0f]};
    for (int i = 0; i < [numberOfPredictionsForHours count]; i++)
    {
        NSNumber *number = numberOfPredictionsForHours[i];
        CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1.0);
        CGRect channelRect = CGRectMake(20.0f+i*normX, 380.0f-MAX([number floatValue]*normY,2.0f), normX-1.0f, MAX([number floatValue]*normY,2.0f));
        CGContextFillRect(context, channelRect);
        
        if (numberOfChannels > 10)
        {
            if ((i-1)%10 == 0)
            {
                NSString *labelString = [NSString stringWithFormat:@"%.0fh", minimalHour+i+1];
                CGSize labelSize = [labelString sizeWithAttributes:attributeDictionary];
                [labelString drawAtPoint:CGPointMake(20.0f+(i+0.5f)*normX-labelSize.width/2.0f, 385.0f) withAttributes:attributeDictionary];
            }
        }
        else if (numberOfChannels > 5)
        {
            if ((i-1)%5 == 0)
            {
                NSString *labelString = [NSString stringWithFormat:@"%.0fh", minimalHour+i+1];
                CGSize labelSize = [labelString sizeWithAttributes:attributeDictionary];
                [labelString drawAtPoint:CGPointMake(20.0f+(i+0.5f)*normX-labelSize.width/2.0f, 385.0f) withAttributes:attributeDictionary];
            }
        }
        else
        {
            NSString *labelString = [NSString stringWithFormat:@"%.0fh", minimalHour+i+1];
            CGSize labelSize = [labelString sizeWithAttributes:attributeDictionary];
            [labelString drawAtPoint:CGPointMake(20.0f+(i+0.5f)*normX-labelSize.width/2.0f, 385.0f) withAttributes:attributeDictionary];
        }
    }
    
    NSString *minimumString = [NSString stringWithFormat:@"Min %.2f, Max %.2f, # %d", [minimum floatValue]/3600, [maximum floatValue]/3600, [count integerValue]];
    [minimumString drawAtPoint:CGPointMake(20.0f, 450.0f) withAttributes:attributeDictionary];
                                                                          
//    NSString *maximumString = [NSString stringWithFormat:@"Max %.2f", [maximum floatValue]/3600];
//    [maximumString drawAtPoint:CGPointMake(20.0f, 430.0f) withAttributes:attributeDictionary];
//    
//    NSString *countString = [NSString stringWithFormat:@"# %d", [count integerValue]];
//    [countString drawAtPoint:CGPointMake(20.0f, 440.0f) withAttributes:attributeDictionary];
//    
//    NSString *maxNumberString = [NSString stringWithFormat:@"max %d", maximalNumberOfValues];
//    [maxNumberString drawAtPoint:CGPointMake(20.0f, 450.0f) withAttributes:attributeDictionary];


}


@end
