//
//  LocationCell.m
//  Until Off
//
//  Created by dasdom on 07.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect labelFrame = self.bounds;
        labelFrame.origin.x = 10.0f;
        labelFrame.size.width = labelFrame.size.width - 20.0f;
        _locationNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.contentView addSubview:_locationNameLabel];
        
        UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        selectedBackgroundView.backgroundColor = [UIColor redColor];
        self.selectedBackgroundView = selectedBackgroundView;
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
