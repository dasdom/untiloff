//
//  PredictionsOverviewViewController.m
//  Until Off
//
//  Created by dasdom on 12.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PredictionsOverviewViewController.h"
#import "PredictionOverviewView.h"
#import "Until_Off-Swift.h"
#import "Prediction.h"
#import "Utilities.h"

NSString * const kLastPredictionDate = @"lastPredictionDate";

@interface PredictionsOverviewViewController ()
@property (nonatomic, strong) NSArray *predictionArray;
@end

@implementation PredictionsOverviewViewController

- (void)loadView
{
//    CGRect frame = [[UIScreen mainScreen] applicationFrame];
//    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
//    PredictionOverviewView *predictionOverviewView = [[PredictionOverviewView alloc] initWithFrame:frame];
    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity: entity];
//    
//    NSError *fetchError;
//    _predictionArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    PredictionOverView *predictionOverviewView = [[PredictionOverView alloc] initWithPredictionsArray:@[]];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    UIBarButtonItem *resetBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetPredictions:)];
    self.navigationItem.leftBarButtonItem = resetBarButton;
    
    self.title = NSLocalizedString(@"Distribution", nil);
    
    self.view = predictionOverviewView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSError *fetchError;
    self.predictionArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];

    ((PredictionOverView *)self.view).predictionsArray = self.predictionArray;
    [self.view setNeedsDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    if ([self.predictionArray count] < 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No data", nil) message:NSLocalizedString(@"There aren't any predicted battery durations stored yet. The predicted values are stored when the measurement range is larger than or equal to 40%. You can also add predictions with the + button.", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - bar button actions
- (void)doneButtonTouched:(UIBarButtonItem*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetPredictions:(UIBarButtonItem*)sender
{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", nil) message:NSLocalizedString(@"Do you really want delete the stored predictions?", nil) preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
//        for (Prediction *prediction in self.predictionArray)
//        {
//            [self.managedObjectContext deleteObject:prediction];
//        }
//        [self.managedObjectContext save:nil];
//        PredictionOverView *predictionOverView = (PredictionOverView*)self.view;
//        [predictionOverView deletePredictions];
//        [predictionOverView setNeedsDisplay];
//        
//        [self dismissViewControllerAnimated:YES completion:nil];
//        
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAverageTotalRuntimeKey];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastPredictionDate];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }];
//    [alertController addAction:deleteAction];
//    
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        
//    }];
//    [alertController addAction:cancelAction];
//    
//    [self presentViewController:alertController animated:YES completion:^{}];
    
    PredictionsTableViewController *predictionsTableViewController = [[PredictionsTableViewController alloc] init];
    predictionsTableViewController.predictionsArray = self.predictionArray;
    predictionsTableViewController.managedObjectContext = self.managedObjectContext;
    
//    [self presentViewController:predictionsTableViewController animated:YES completion:nil];
    [self.navigationController pushViewController:predictionsTableViewController animated:YES];
}

@end
