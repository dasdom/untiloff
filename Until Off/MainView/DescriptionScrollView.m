//
//  DescriptionScrollView.m
//  Until Off
//
//  Created by dasdom on 28.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DescriptionScrollView.h"

@interface DescriptionScrollView () <UIAccessibilityReadingContent>
@property (nonatomic, strong) NSArray *accessibilityContentStringArray;
@end

@implementation DescriptionScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isAccessibilityElement = YES;
        self.numberOfPages = 8;
        
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.contentSize = CGSizeMake(frame.size.width*self.numberOfPages, frame.size.height);
        self.layer.cornerRadius = 3.0f;
        self.showsHorizontalScrollIndicator = NO;
        
        NSMutableArray *mutableAccessibilityContentArray = [NSMutableArray array];
        for (int i = 0; i < self.numberOfPages; i++)
        {
            NSString *titleString;
            NSString *labelString;
            NSString *imageName;
            BOOL templateImage = NO;
            switch (i) {
                case 0:
                    titleString = NSLocalizedString(@"What is UntilOff?", nil);
                    labelString = NSLocalizedString(@"UntilOff let's you figure out how long you can use your phone until it needs to be charged again.", nil);
                    break;
                case 1:
                    titleString = NSLocalizedString(@"Help", nil);
                    labelString = NSLocalizedString(@"This job is hard. But you can help! Start UntilOff after you have charged your phone.", nil);
                    imageName = @"startAppAfterUnplug";
                    break;
                case 2:
                    titleString = NSLocalizedString(@"Residual Battery", nil);
                    labelString = NSLocalizedString(@"Every time you need to know the residual battery duration, start UntilOff and it will tell you.", nil);
                    imageName = @"residualTime";
                    break;
                case 3:
                    titleString = NSLocalizedString(@"Distribution", nil);
                    labelString = NSLocalizedString(@"If UntilOff believes the calculation is reliable, it saves the predicted total battery duration.", nil);
                    imageName = @"distributionIcon";
                    templateImage = YES;
                    break;
                case 4:
                    titleString = NSLocalizedString(@"Add Measurement", nil);
                    labelString = NSLocalizedString(@"You can add a measurement to the distribution manually.", nil);
                    imageName = @"addPrediction";
                    templateImage = YES;
                    break;
                case 5:
                    titleString = NSLocalizedString(@"Background", nil);
                    labelString = NSLocalizedString(@"UntilOff can measure the battery in the background. To activate you have to add geo fences.", nil);
                    imageName = @"locationServiceIcon";
                    templateImage = YES;
                    break;
                case 6:
                    titleString = NSLocalizedString(@"Notifications", nil);
                    labelString = NSLocalizedString(@"Add notifications if you want to be remebered to open UntilOff to add measurements in a regular manner.", nil);
                    imageName = @"notificationIcon";
                    templateImage = YES;
                    break;
                case 7:
                    titleString = NSLocalizedString(@"How does it work?", nil);
                    labelString = NSLocalizedString(@"UntilOff takes the duration between the highest and the actual battery level and interpolates to an empty battery. Therefore the values only take into account your prior usage.", nil);
                    break;
                default:
                    break;
            }
            
            [mutableAccessibilityContentArray addObject:labelString];
            
            CGRect pageFrame = self.bounds;
            pageFrame.origin.x = i*pageFrame.size.width;
            pageFrame.size.width = pageFrame.size.width;
            UIView *pageView = [[UIView alloc] initWithFrame:pageFrame];
            pageView.isAccessibilityElement = YES;
            //            pageView.accessibilityLabel = titleString;
            //            pageView.accessibilityHint = labelString;
//            UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern"]];
//            pageView.backgroundColor = backgroundColor;
            [self addSubview:pageView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, frame.size.width-40.0f, 30.0f)];
            titleLabel.text = titleString;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
            titleLabel.isAccessibilityElement = NO;
            [pageView addSubview:titleLabel];
            
            UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
            CGRect textFrame = [labelString boundingRectWithSize:CGSizeMake(frame.size.width-40.0f, frame.size.height-40.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : labelFont} context:nil];
            CGRect labelFrame = CGRectMake(20.0f, CGRectGetMaxY(titleLabel.frame)+5.0f, frame.size.width-40.0f, textFrame.size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            label.text = labelString;
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 0;
            label.font = labelFont;
            label.isAccessibilityElement = NO;
//                label.backgroundColor = [UIColor yellowColor];
            [pageView addSubview:label];
            
            if (imageName)
            {
                UIImage *image = [UIImage imageNamed:imageName];
                if (templateImage) {
                    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.tintColor = [UIColor whiteColor];
                CGRect imageViewFrame = imageView.frame;
                imageViewFrame.origin.x = ceilf((frame.size.width-imageViewFrame.size.width)/2.0f);
                imageViewFrame.origin.y = CGRectGetMaxY(label.frame) + 50.0f;
//                imageViewFrame.origin.y = pageFrame.size.height-imageViewFrame.size.height-35.0f;
                imageView.frame = imageViewFrame;
                [pageView addSubview:imageView];
            }
        }
        
        self.accessibilityContentStringArray = [mutableAccessibilityContentArray copy];

        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)accessibilityLineNumberForPoint:(CGPoint)point
{
    return (NSInteger)(6*point.y/self.frame.size.height);
}

- (NSString*)accessibilityContentForLineNumber:(NSInteger)lineNumber
{
    return self.accessibilityContentStringArray[lineNumber];
}

- (CGRect)accessibilityFrameForLineNumber:(NSInteger)lineNumber
{
    return CGRectMake(0.0f, lineNumber*self.frame.size.height/6, self.frame.size.width, self.frame.size.height/6);
}

- (NSString*)accessibilityPageContent
{
    NSMutableString *pageString = [NSMutableString stringWithString:@""];
    for (NSString *string in self.accessibilityContentStringArray)
    {
        [pageString appendString:string];
    }
    return pageString;
}

- (BOOL)accessibilityPerformMagicTap
{
    [self removeFromSuperview];
    return YES;
}


@end
