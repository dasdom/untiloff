//
//  LocationServiceViewController.m
//  Until Off
//
//  Created by dasdom on 07.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "LocationServiceViewController.h"
#import "LocationServiceLookAndFeel.h"
#import "LocationCell.h"
#import "AddCurrentLocationCell.h"
#import "Geofence.h"
#import "AppDelegate.h"

@interface LocationServiceViewController ()
@property (nonatomic, strong) LocationServiceLookAndFeel *locationServiceLookAndFeel;
@end

@implementation LocationServiceViewController

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout.minimumInteritemSpacing = 0.0f;
    collectionViewFlowLayout.minimumLineSpacing = 1.0f;
    collectionViewFlowLayout.headerReferenceSize = CGSizeMake(0.0f, 2.0f);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewFlowLayout];
    
    _locationServiceLookAndFeel = [[LocationServiceLookAndFeel alloc] init];
    _locationServiceLookAndFeel.viewWidth = frame.size.width;
    
    collectionView.delegate = _locationServiceLookAndFeel;
    collectionView.dataSource = _locationServiceLookAndFeel;
    
    [collectionView registerClass:([LocationCell class]) forCellWithReuseIdentifier:kLocationCell];
    [collectionView registerClass:([AddCurrentLocationCell class]) forCellWithReuseIdentifier:kAddCurrentLocationCell];

    collectionView.allowsMultipleSelection = YES;
    
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeLocation:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Geofence" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSError *fetchError;
    NSArray *geofenceArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    NSMutableArray *mutableGeofenceArray = [NSMutableArray array];
    for (Geofence *geofence in geofenceArray)
    {
        NSDictionary *geofenceDictionary = @{@"name": geofence.name, @"longitude" : geofence.longitude, @"latitude" : geofence.latitude};
        [mutableGeofenceArray addObject:geofenceDictionary];
        
        [self.managedObjectContext deleteObject:geofence];
    }
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];

    self.locationServiceLookAndFeel.placeMarkArray = [mutableGeofenceArray copy];
    
    self.collectionView = collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationServiceLookAndFeel.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationServiceLookAndFeel.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeLocation:(UIBarButtonItem*)sender
{
    NSArray *indexPathOfSelectedItems = [self.collectionView indexPathsForSelectedItems];
    if ([indexPathOfSelectedItems count] < 1)
    {
        
    }
    else
    {
        [self.collectionView performBatchUpdates:^{
            [self.locationServiceLookAndFeel deleteObjectsAtIndexPaths:indexPathOfSelectedItems];
            [self.collectionView deleteItemsAtIndexPaths:indexPathOfSelectedItems];
        } completion:^(BOOL finished){}];
    }
}

- (void)doneButtonTouched:(UIBarButtonItem*)sender
{
    for (NSDictionary *geofenceDictionary in self.locationServiceLookAndFeel.placeMarkArray)
    {
        Geofence *geofence = [NSEntityDescription insertNewObjectForEntityForName:@"Geofence" inManagedObjectContext:self.managedObjectContext];
        geofence.name = [geofenceDictionary objectForKey:@"name"];
        geofence.longitude = [geofenceDictionary objectForKey:@"longitude"];
        geofence.latitude = [geofenceDictionary objectForKey:@"latitude"];
        geofence.radius = @(100.0f);
    }
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] saveContext];

    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end