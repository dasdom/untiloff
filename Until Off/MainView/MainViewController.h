//
//  MainViewController.h
//  Until Off
//
//  Created by dasdom on 29.08.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (void)becameActive:(NSNotification*)notification;
//- (void)clearView:(NSNotification*)notification;
- (void)addMeasurement;

@end
