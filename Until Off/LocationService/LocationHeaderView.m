//
//  LocationHeaderView.m
//  Until Off
//
//  Created by dasdom on 19.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "LocationHeaderView.h"

@implementation LocationHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        
        self.backgroundColor = backgroundColor;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, frame.size.width-20.0f, frame.size.height)];
        label.text = NSLocalizedString(@"Geofence Locations", nil);
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        [self addSubview:label];
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
