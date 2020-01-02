//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import "OnBoardingCoordinator.h"

#import "OnBoardingItem.h"
#import "OnBoardingInfoViewController.h"

@interface OnBoardingCoordinator () <UIPageViewControllerDataSource>
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) NSArray<OnBoardingItem *> *items;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property NSInteger index;
@end

@implementation OnBoardingCoordinator

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController onBoardingItems:(NSArray<OnBoardingItem *> *)items {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
        _items = items;
    }
    return self;
}

- (void)start {
    [[UIPageControl appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UIPageControl appearance] setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    [self.pageViewController setViewControllers:@[[self viewControllerForIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:nil];
    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(skip)];
    self.pageViewController.navigationItem.rightBarButtonItem = skipButton;
    self.pageViewController.title = @"About UntilOff";
    
    [self.navigationController pushViewController:self.pageViewController animated:true];
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    
    OnBoardingInfoViewController *currentViewController = (OnBoardingInfoViewController *)viewController;
    NSInteger nextIndex = currentViewController.index + 1;
    if (nextIndex > [self.items count]-1) {
        return nil;
    }
    
    return [self viewControllerForIndex:nextIndex];

}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    
    OnBoardingInfoViewController *currentViewController = (OnBoardingInfoViewController *)viewController;
    NSInteger nextIndex = currentViewController.index - 1;
    if (nextIndex < 0) {
        return nil;
    }
    
    return [self viewControllerForIndex:nextIndex];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.items count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return self.index;
}

- (OnBoardingInfoViewController *)viewControllerForIndex:(NSInteger)index {
    OnBoardingInfoViewController *viewController = [[OnBoardingInfoViewController alloc] initWithOnBoardingItem:self.items[index]];
    self.index = index;
    viewController.index = index;
    return viewController;
}

- (void)skip {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

@end
