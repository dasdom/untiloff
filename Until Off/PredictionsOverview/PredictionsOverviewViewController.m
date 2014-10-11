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

@interface PredictionsOverviewViewController ()
@property (nonatomic, strong) NSArray *predictionArray;
@end

@implementation PredictionsOverviewViewController

- (void)loadView
{
//    CGRect frame = [[UIScreen mainScreen] applicationFrame];
//    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
//    PredictionOverviewView *predictionOverviewView = [[PredictionOverviewView alloc] initWithFrame:frame];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSError *fetchError;
    _predictionArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
//    predictionOverviewView.predictionsArray = _predictionArray;
    
    PredictionOverView *predictionOverviewView = [[PredictionOverView alloc] initWithPredictionsArray:_predictionArray];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.rightBarButtonItem = closeButton;
    
    UIBarButtonItem *resetBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetPredictions:)];
    self.navigationItem.leftBarButtonItem = resetBarButton;
    
    self.title = NSLocalizedString(@"Distribution", nil);
    
    self.view = predictionOverviewView;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - bar button actions
- (void)doneButtonTouched:(UIBarButtonItem*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetPredictions:(UIBarButtonItem*)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete", nil) message:NSLocalizedString(@"Do you really want delete the stored predictions?", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        for (Prediction *prediction in self.predictionArray)
        {
            [self.managedObjectContext deleteObject:prediction];
        }
        [self.managedObjectContext save:nil];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAverageTotalRuntimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertController addAction:deleteAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

@end
