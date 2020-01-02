//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import "OnBoardingInfoViewController.h"

#import "OnBoardingItem.h"
#import "OnBoardingInfoView.h"

@interface OnBoardingInfoViewController ()
@property OnBoardingItem *onBoardingItem;
@end

@implementation OnBoardingInfoViewController

- (instancetype)initWithOnBoardingItem:(OnBoardingItem *)onBoardingItem {
    self = [super init];
    if (self) {
        _onBoardingItem = onBoardingItem;
    }
    return self;
}

- (void)loadView {
    OnBoardingInfoView *contentView = [OnBoardingInfoView new];
    [contentView updateWithItem:self.onBoardingItem];
    
    self.view = contentView;
}

- (OnBoardingInfoView *)contentView {
    return (OnBoardingInfoView *)self.view;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        
    } else {
        [[[self contentView] topView].topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = true;
    }
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next)];
//    self.navigationItem.rightBarButtonItem = skipButton;
//}

@end
