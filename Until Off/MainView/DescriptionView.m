//
//  DescriptionView.m
//  Until Off
//
//  Created by dasdom on 23.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DescriptionView.h"

@interface DescriptionView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation DescriptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
        
        CGSize scrollViewSize = CGSizeMake(240.0f, 300.0f);
        CGRect scrollViewFrame = CGRectMake(ceilf((frame.size.width-scrollViewSize.width)/2.0f), ceilf((frame.size.height-scrollViewSize.height)/2.0f), scrollViewSize.width, scrollViewSize.height);
        UIScrollView *descriptionScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        descriptionScrollView.backgroundColor = [UIColor whiteColor];
        descriptionScrollView.contentSize = CGSizeMake(scrollViewFrame.size.width*6.0f, scrollViewFrame.size.height);
        descriptionScrollView.pagingEnabled = YES;
        descriptionScrollView.layer.cornerRadius = 3.0f;
        descriptionScrollView.delegate = self;
        descriptionScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:descriptionScrollView];
        
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
        _dismissButton.frame = CGRectMake(CGRectGetMaxX(scrollViewFrame)-20.0f, CGRectGetMinY(scrollViewFrame)-20.0f, 40.0f, 40.0f);
        _dismissButton.accessibilityLabel = @"Close";
        _dismissButton.accessibilityHint = @"Closes the description.";
        [self addSubview:_dismissButton];
        
        for (int i = 0; i < 6; i++)
        {
            NSString *titleString;
            NSString *labelString;
            NSString *imageName;
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
                    titleString = NSLocalizedString(@"Charging is bad. ;)", nil);
                    labelString = NSLocalizedString(@"Note: If you charge your phone in the meantime the prediction can't be done.", nil);
                    break;
                case 4:
                    titleString = NSLocalizedString(@"Distribution", nil);
                    labelString = NSLocalizedString(@"If UntilOff believes the calculation is reliable, it saves the predicted total battery duration.", nil);
                    break;
                case 5:
                    titleString = NSLocalizedString(@"Background", nil);
                    labelString = NSLocalizedString(@"UntiOff can measure the battery in the background. To activate you have to add geo fences.", nil);
                    break;
                default:
                    break;
            }
            
            CGRect pageFrame = descriptionScrollView.bounds;
            pageFrame.origin.x = i*pageFrame.size.width;
            UIView *pageView = [[UIView alloc] initWithFrame:pageFrame];
            UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundPattern"]];
            pageView.backgroundColor = backgroundColor;
            [descriptionScrollView addSubview:pageView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, scrollViewFrame.size.width-40.0f, 30.0f)];
            titleLabel.text = titleString;
            titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f];
            [pageView addSubview:titleLabel];
            
            UIFont *labelFont = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
            CGRect textFrame = [labelString boundingRectWithSize:CGSizeMake(scrollViewFrame.size.width-40.0f, scrollViewFrame.size.height-40.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : labelFont} context:nil];
            CGRect labelFrame = CGRectMake(20.0f, CGRectGetMaxY(titleLabel.frame)+5.0f, scrollViewFrame.size.width-40.0f, textFrame.size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            label.text = labelString;
            label.numberOfLines = 0;
            label.font = labelFont;
            //    label1.backgroundColor = [UIColor yellowColor];
            [pageView addSubview:label];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            CGRect imageViewFrame = imageView.frame;
            imageViewFrame.origin.x = ceilf((scrollViewSize.width-imageViewFrame.size.width)/2.0f);
            imageViewFrame.origin.y = pageFrame.size.height-imageViewFrame.size.height-35.0f;
            imageView.frame = imageViewFrame;
            [pageView addSubview:imageView];
            
        }
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(CGRectGetMinX(scrollViewFrame), CGRectGetMaxY(scrollViewFrame)-20.0f, scrollViewFrame.size.width, 10.0f)];
        _pageControl.numberOfPages = 6;
        _pageControl.currentPage = 0;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
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

@end
