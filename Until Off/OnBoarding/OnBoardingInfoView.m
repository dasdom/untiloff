//  Created by dasdom on 15.11.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

#import "OnBoardingInfoView.h"

#import "OnBoardingItem.h"

@interface OnBoardingInfoView ()
@property UIImageView *imageView;
@property UILabel *titleLabel;
@property UILabel *textLabel;
@end

@implementation OnBoardingInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = false;
//        _imageView.backgroundColor = [UIColor yellowColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _titleLabel = [UILabel new];
//        _titleLabel.backgroundColor = [UIColor brownColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:25];
        
        _textLabel = [UILabel new];
//        _textLabel.backgroundColor = [UIColor redColor];
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont systemFontOfSize:20];
        
        UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _textLabel]];
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        stackView.axis = UILayoutConstraintAxisVertical;
        stackView.spacing = 10;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:_imageView];
        [self addSubview:stackView];
        
        NSArray *layoutConstraints = @[
                                       [_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
                                       [_imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
                                       [_imageView.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.3],
                                       [stackView.topAnchor constraintEqualToAnchor:_imageView.bottomAnchor constant:20],
                                       [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
                                       [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-20],
                                       ];
        
        if (@available(iOS 11.0, *)) {
            layoutConstraints = [layoutConstraints arrayByAddingObject:[_imageView.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor]];
//        } else {
//            _topConstraint = [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor];
//            layoutConstraints = [layoutConstraints arrayByAddingObject:_topConstraint];
        }
        
        [NSLayoutConstraint activateConstraints:layoutConstraints];
    }
    return self;
}

- (void)updateWithItem:(OnBoardingItem *)item {
    self.imageView.image = item.image;
    self.titleLabel.text = item.title;
    self.textLabel.text = item.text;
}

- (UIView *)topView {
    return self.imageView;
}

@end
