//
//  PredictionsOverviewViewController.m
//  Until Off
//
//  Created by dasdom on 12.09.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PredictionsOverviewViewController.h"
#import "PredictionOverviewView.h"

@interface PredictionsOverviewViewController ()
@property (nonatomic, strong) NSArray *predictionArray;
@end

@implementation PredictionsOverviewViewController

- (void)loadView
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
    PredictionOverviewView *predictionOverviewView = [[PredictionOverviewView alloc] initWithFrame:frame];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Prediction" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity: entity];
    
    NSError *fetchError;
    _predictionArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    predictionOverviewView.predictionsArray = _predictionArray;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTouched:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    self.view = predictionOverviewView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonTouched:(UIBarButtonItem*)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
