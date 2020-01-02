//
//  DescriptionView.m
//  Until Off
//
//  Created by dasdom on 23.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DescriptionView.h"
#import "DescriptionScrollView.h"

@interface DescriptionView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
//@property (nonatomic, strong) NSArray *accessibilityContentStringArray;
@end

@implementation DescriptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
        self.accessibilityViewIsModal = YES;
        
//        CGSize scrollViewSize = CGSizeMake(280.0f, 320.0f);
//        CGRect scrollViewHostFrame = CGRectMake(ceilf((frame.size.width-scrollViewSize.width)/2.0f)+10.0f, ceilf((frame.size.height-scrollViewSize.height)/2.0f)-10.0f, scrollViewSize.width, scrollViewSize.height);
        CGRect scrollViewHostFrame = CGRectInset(frame, 10.0f, 10.0f);
        self.descriptionHostView = [[UIView alloc] initWithFrame:scrollViewHostFrame];
//        self.descriptionHostView.backgroundColor = [UIColor redColor];
        [self addSubview:self.descriptionHostView];
        
        CGRect scrollViewFrame = CGRectMake(20.0f, 50.0f, scrollViewHostFrame.size.width-40.0f, scrollViewHostFrame.size.height-20.0f);
        DescriptionScrollView *descriptionScrollView = [[DescriptionScrollView alloc] initWithFrame:scrollViewFrame];
        descriptionScrollView.delegate = self;
        [self.descriptionHostView addSubview:descriptionScrollView];
        
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
//        _dismissButton.frame = CGRectMake(CGRectGetMaxX(scrollViewFrame)-20.0f, CGRectGetMaxY(scrollViewFrame)-20.0f, 40.0f, 40.0f);
        
        _dismissButton.frame = CGRectMake(CGRectGetWidth(scrollViewFrame), CGRectGetMinY(scrollViewFrame), 40.0f, 40.0f);
        _dismissButton.accessibilityLabel = @"Close";
        _dismissButton.accessibilityHint = @"Closes the description.";
        [self.descriptionHostView addSubview:_dismissButton];
        
//        NSMutableArray *mutableAccessibilityContentArray = [NSMutableArray array];
//        for (int i = 0; i < numberOfPages; i++)
//        {
//            NSString *titleString;
//            NSString *labelString;
//            NSString *imageName;
//            switch (i) {
//                case 0:
//                    titleString = NSLocalizedString(@"What is UntilOff?", nil);
//                    labelString = NSLocalizedString(@"UntilOff let's you figure out how long you can use your phone until it needs to be charged again.", nil);
//                    break;
//                case 1:
//                    titleString = NSLocalizedString(@"Help", nil);
//                    labelString = NSLocalizedString(@"This job is hard. But you can help! Start UntilOff after you have charged your phone.", nil);
//                    imageName = @"startAppAfterUnplug";
//                    break;
//                case 2:
//                    titleString = NSLocalizedString(@"Residual Battery", nil);
//                    labelString = NSLocalizedString(@"Every time you need to know the residual battery duration, start UntilOff and it will tell you.", nil);
//                    imageName = @"residualTime";
//                    break;
//                case 3:
//                    titleString = NSLocalizedString(@"Distribution", nil);
//                    labelString = NSLocalizedString(@"If UntilOff believes the calculation is reliable, it saves the predicted total battery duration.", nil);
//                    break;
//                case 4:
//                    titleString = NSLocalizedString(@"Background", nil);
//                    labelString = NSLocalizedString(@"UntilOff can measure the battery in the background. To activate you have to add geo fences.", nil);
//                    break;
//                case 5:
//                    titleString = NSLocalizedString(@"How does it work?", nil);
//                    labelString = NSLocalizedString(@"UntilOff takes the duration between the highest and the actual battery level and interpolates to an empty battery. Therefore the values only take into account your prior usage.", nil);
//                    break;
//                default:
//                    break;
//            }
//            
//            [mutableAccessibilityContentArray addObject:labelString];
//            
//            CGRect pageFrame = descriptionScrollView.bounds;
//            pageFrame.origin.x = i*pageFrame.size.width;
//            pageFrame.size.width = pageFrame.size.width;
//            UIView *pageView = [[UIView alloc] initWithFrame:pageFrame];
//            pageView.isAccessibilityElement = YES;
////            pageView.accessibilityLabel = titleString;
////            pageView.accessibilityHint = labelString;
//            UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern"]];
//            pageView.backgroundColor = backgroundColor;
//            [descriptionScrollView addSubview:pageView];
//            
//            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, scrollViewFrame.size.width-40.0f, 30.0f)];
//            titleLabel.text = titleString;
//            titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f];
//            titleLabel.isAccessibilityElement = NO;
//            [pageView addSubview:titleLabel];
//            
//            UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
//            CGRect textFrame = [labelString boundingRectWithSize:CGSizeMake(scrollViewFrame.size.width-40.0f, scrollViewFrame.size.height-40.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : labelFont} context:nil];
//            CGRect labelFrame = CGRectMake(20.0f, CGRectGetMaxY(titleLabel.frame)+5.0f, scrollViewFrame.size.width-40.0f, textFrame.size.height);
//            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
//            label.text = labelString;
//            label.numberOfLines = 0;
//            label.font = labelFont;
//            label.isAccessibilityElement = NO;
//            //    label1.backgroundColor = [UIColor yellowColor];
//            [pageView addSubview:label];
//            
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
//            CGRect imageViewFrame = imageView.frame;
//            imageViewFrame.origin.x = ceilf((scrollViewSize.width-imageViewFrame.size.width)/2.0f);
//            imageViewFrame.origin.y = pageFrame.size.height-imageViewFrame.size.height-35.0f;
//            imageView.frame = imageViewFrame;
//            [pageView addSubview:imageView];
//            
//        }
//        
//        self.accessibilityContentStringArray = [mutableAccessibilityContentArray copy];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(CGRectGetMinX(scrollViewFrame), CGRectGetHeight(scrollViewFrame), scrollViewHostFrame.size.width-20.0f, 10.0f)];
        _pageControl.numberOfPages = descriptionScrollView.numberOfPages;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.isAccessibilityElement = NO;
        [self.descriptionHostView addSubview:_pageControl];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x/scrollView.frame.size.width);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _pageControl.currentPage = (NSInteger)(scrollView.contentOffset.x/scrollView.frame.size.width);
}

//- (NSInteger)accessibilityLineNumberForPoint:(CGPoint)point
//{
//    return (NSInteger)(6*point.y/self.frame.size.height);
//}
//
//- (NSString*)accessibilityContentForLineNumber:(NSInteger)lineNumber
//{
//    return self.accessibilityContentStringArray[lineNumber];
//}
//
//- (CGRect)accessibilityFrameForLineNumber:(NSInteger)lineNumber
//{
//    return CGRectMake(0.0f, lineNumber*self.frame.size.height/6, self.frame.size.width-50.0f, self.frame.size.height/6);
//}
//
//- (NSString*)accessibilityPageContent
//{
//    NSMutableString *pageString = [NSMutableString stringWithString:@""];
//    for (NSString *string in self.accessibilityContentStringArray)
//    {
//        [pageString appendString:string];
//    }
//    return pageString;
//}
//
//- (BOOL)accessibilityPerformMagicTap
//{
//    [self removeFromSuperview];
//    return YES;
//}

@end
