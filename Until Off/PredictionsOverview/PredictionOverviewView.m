//
//  PredictionOverviewView.m
//  Until Off
//
//  Created by dasdom on 12.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PredictionOverviewView.h"
#import "Prediction.h"
#import "Utilities.h"

@interface PredictionOverviewView ()
//@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSNumber *minimum;
@property (nonatomic, strong) NSNumber *maximum;
@property (nonatomic, strong) NSNumber *average;
@end

@implementation PredictionOverviewView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        _label = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, frame.size.height-40.0f, frame.size.width-40.0f, 20.0f)];
//        [self addSubview:_label];
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
    
    self.minimum = [self.predictionsArray valueForKeyPath:@"@min.totalRuntime"];
    self.maximum = [self.predictionsArray valueForKeyPath:@"@max.totalRuntime"];
    self.average = [self.predictionsArray valueForKeyPath:@"@avg.totalRuntime"];
//    NSString *count = [self.predictionsArray valueForKeyPath:@"@count"];

    if ([self.average compare:@(0)] == NSOrderedDescending)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[self.average integerValue] forKey:kAverageTotalRuntimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    CGFloat minimalHour = floorf([self.minimum floatValue]/3600.0f-1.5f);
    CGFloat maximalHour = ceilf([self.maximum floatValue]/3600.f+0.5f);
    
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
    
    CGFloat rectHeight = rect.size.height;

    NSInteger numberOfChannels = [numberOfPredictionsForHours count];
    CGFloat normX = (self.frame.size.width-40.0f)/(float)numberOfChannels;
    CGFloat normY = (rectHeight-190.0f)/(float)maximalNumberOfValues;
    NSDictionary *attributeDictionary = @{NSFontAttributeName : [UIFont systemFontOfSize:10.0f]};
    for (int i = 0; i < [numberOfPredictionsForHours count]; i++)
    {
        NSNumber *number = numberOfPredictionsForHours[i];
        CGContextSetRGBFillColor(context, 0.6, 0.6, 0.6, 1.0);
        CGRect channelRect = CGRectMake(20.0f+i*normX, rectHeight-100.0f-MAX([number floatValue]*normY,2.0f), normX-1.0f, MAX([number floatValue]*normY,2.0f));
        CGContextFillRect(context, channelRect);
        
        if (numberOfChannels > 10)
        {
            if ((i-1)%10 == 0)
            {
                NSString *labelString = [NSString stringWithFormat:@"%.0fh", minimalHour+i+1];
                CGSize labelSize = [labelString sizeWithAttributes:attributeDictionary];
                [labelString drawAtPoint:CGPointMake(20.0f+(i+0.5f)*normX-labelSize.width/2.0f, rectHeight-95.0f) withAttributes:attributeDictionary];
            }
        }
        else if (numberOfChannels > 5)
        {
            if ((i-1)%5 == 0)
            {
                NSString *labelString = [NSString stringWithFormat:@"%.0fh", minimalHour+i+1];
                CGSize labelSize = [labelString sizeWithAttributes:attributeDictionary];
                [labelString drawAtPoint:CGPointMake(20.0f+(i+0.5f)*normX-labelSize.width/2.0f, rectHeight-95.0f) withAttributes:attributeDictionary];
            }
        }
        else
        {
            NSString *labelString = [NSString stringWithFormat:@"%.0fh", minimalHour+i+1];
            CGSize labelSize = [labelString sizeWithAttributes:attributeDictionary];
            [labelString drawAtPoint:CGPointMake(20.0f+(i+0.5f)*normX-labelSize.width/2.0f, rectHeight-95.0f) withAttributes:attributeDictionary];
        }
    }
    
    for (int i = 5; i < maximalNumberOfValues; i+=5)
    {
        CGRect lineRect = CGRectMake(10.0f, rectHeight-100.0f-i*normY, rect.size.width-20.0f, 1.0f);
        CGContextFillRect(context, lineRect);
        
        NSString *numberString = [NSString stringWithFormat:@"%d", i];
        [numberString drawAtPoint:CGPointMake(10.0f, CGRectGetMaxY(lineRect)-15.0f) withAttributes:attributeDictionary];
    }
    
    NSString *conclusionString = [NSString stringWithFormat:@"Minimum %.2f, Maximum %.2f, Average %.2f", [self.minimum floatValue]/3600, [self.maximum floatValue]/3600, [self.average floatValue]/3600];
    [conclusionString drawAtPoint:CGPointMake(20.0f, rectHeight-20.0f) withAttributes:attributeDictionary];
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString*)accessibilityLabel
{
    NSInteger seconds = [self.average integerValue];
    NSInteger hours = seconds/3600;
    NSInteger minutes = seconds/60-hours*60;
    
    NSMutableString *mutableString = [NSMutableString stringWithString:@""];
    [mutableString appendFormat:@"The average total battery duration is %d hours and %d minutes.", hours, minutes];
    
    seconds = [self.minimum integerValue];
    hours = seconds/3600;
    minutes = seconds/60-hours*60;
    
    [mutableString appendFormat:@"The minimal total battery duration is %d hours and %d minutes.", hours, minutes];

    seconds = [self.maximum integerValue];
    hours = seconds/3600;
    minutes = seconds/60-hours*60;
    
    [mutableString appendFormat:@"The maximum total battery duration is %d hours and %d minutes.", hours, minutes];

    return mutableString;
}


@end
