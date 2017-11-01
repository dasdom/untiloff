//
//  PredictionsOverviewViewController.h
//  Until Off
//
//  Created by dasdom on 12.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kLastPredictionDate;

@interface PredictionsOverviewViewController : UIViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
