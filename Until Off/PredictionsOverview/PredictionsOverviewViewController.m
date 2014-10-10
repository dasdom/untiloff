//
//  PredictionsOverviewViewController.m
//  Until Off
//
//  Created by dasdom on 12.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PredictionsOverviewViewController.h"
#import "PredictionOverviewView.h"
#import "Prediction.h"
#import "Utilities.h"

@interface PredictionsOverviewViewController ()
@property (nonatomic, strong) NSArray *predictionArray;
@end

@implementation PredictionsOverviewViewController

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
//    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
    PredictionOverviewView *predictionOverviewView = [[PredictionOverviewView alloc] initWithFrame:frame];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSError *fetchError;
    _predictionArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    predictionOverviewView.predictionsArray = _predictionArray;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    UIBarButtonItem *resetBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetPredictions:)];
    self.navigationItem.rightBarButtonItem = resetBarButton;
    
    self.title = NSLocalizedString(@"Distribution", nil);
    
    self.view = predictionOverviewView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    for (Prediction *prediction in self.predictionArray)
    {
        [self.managedObjectContext deleteObject:prediction];
    }
    [self.managedObjectContext save:nil];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAverageTotalRuntimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
