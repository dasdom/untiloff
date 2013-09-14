//
//  LocationServiceLookAndFeel.m
//  Until Off
//
//  Created by dasdom on 07.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "LocationServiceLookAndFeel.h"
#import "LocationCell.h"
#import "AddCurrentLocationCell.h"

@interface LocationServiceLookAndFeel () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLPlacemark *currentPlaceMark;
@end

@implementation LocationServiceLookAndFeel

- (id)init
{
    if ((self = [super init]))
    {
        _locationManager = [[CLLocationManager alloc] init];
        _placeMarkArray = [NSArray array];
    }
    return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return 1;
            break;
        }
        case 1:
        {
            return [self.placeMarkArray  count];
            break;
        }
        default:
            return 0;
            break;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            AddCurrentLocationCell *addCurrentLocationCell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddCurrentLocationCell forIndexPath:indexPath];
            addCurrentLocationCell.titleLabel.text = NSLocalizedString(@"Add Current Location", nil);
            return addCurrentLocationCell;
            break;
        }
        case 1:
        {
            LocationCell *locationCell = [collectionView dequeueReusableCellWithReuseIdentifier:kLocationCell forIndexPath:indexPath];
            NSDictionary *geofenceDictionary = [self.placeMarkArray objectAtIndex:indexPath.row];
            locationCell.locationNameLabel.text = [geofenceDictionary objectForKey:@"name"];
            return locationCell;
            break;
        }
        default:
        {
            AddCurrentLocationCell *addCurrentLocationCell = [collectionView dequeueReusableCellWithReuseIdentifier:kAddCurrentLocationCell forIndexPath:indexPath];
            addCurrentLocationCell.titleLabel.text = NSLocalizedString(@"Add Current Location", nil);
            return addCurrentLocationCell;
            break;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.viewWidth, 50.0f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSLog(@"locationManager: %lf %lf", _locationManager.location.coordinate.longitude, _locationManager.location.coordinate.latitude);
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        __weak LocationServiceLookAndFeel *weakSelf = self;
        [geocoder reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks firstObject];
            if (placemark)
            {
                weakSelf.placeMarkArray = [weakSelf.placeMarkArray arrayByAddingObject:@{@"name": [placemark.addressDictionary objectForKey:@"Name"], @"longitude" : @(placemark.location.coordinate.longitude), @"latitude" : @(placemark.location.coordinate.latitude)}];
            }
            [collectionView reloadData];
        }];
    }
}

- (void)deleteObjectsAtIndexPaths:(NSArray*)indexPaths
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (NSIndexPath *indexPath in indexPaths)
    {
        if (indexPath.section == 1)
        {
            [indexSet addIndex:indexPath.row];
        }
    }
    NSMutableArray *mutablePlacemarkArray = [self.placeMarkArray mutableCopy];
    [mutablePlacemarkArray removeObjectsAtIndexes:indexSet];
    self.placeMarkArray = [mutablePlacemarkArray copy];
}


@end
