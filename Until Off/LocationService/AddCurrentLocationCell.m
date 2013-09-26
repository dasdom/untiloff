//
//  AddCurrentLocationCell.m
//  Until Off
//
//  Created by dasdom on 07.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "AddCurrentLocationCell.h"

@implementation AddCurrentLocationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect labelFrame = self.bounds;
        _titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
        _titleLabel.textColor = [UIColor colorWithHue:357.0f/360.0f saturation:1.0f brightness:0.80f alpha:1.0f];
        [self.contentView addSubview:_titleLabel];
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

@end
