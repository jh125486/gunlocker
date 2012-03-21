//
//  DistanceCalculationsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DistanceCalculationsViewController.h"
#include <CoreMotion/CoreMotion.h>


@implementation DistanceCalculationsViewController
@synthesize targetSizeTextField;
@synthesize targetSizeUnitControl;
@synthesize targetReadingTextField;
@synthesize targetReadingUnitControl;
@synthesize resultRangeLabel;
@synthesize resultRangeUnitControl;

@synthesize targetDistanceTextField;
@synthesize targetDistanceUnitLabel;
@synthesize shootingAngleTextField;
@synthesize resultHorizontalRangeLabel;
@synthesize liveAngleUpdatingSegment;
@synthesize resultHorizontalRangeUnitLabel;

@synthesize passedResult;
@synthesize passedResultUnits;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // show keyboard on load
    [self.targetSizeTextField becomeFirstResponder];

    if(self.passedResult) {
        self.targetDistanceTextField.text = passedResult;
        self.targetDistanceUnitLabel.text = passedResultUnits;
        self.resultHorizontalRangeUnitLabel.text = passedResultUnits;
        [self.shootingAngleTextField becomeFirstResponder];
    } else {
        [self.targetDistanceTextField becomeFirstResponder];
        
    }

    // set up proper keyboards for fields
    self.targetSizeTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.targetReadingTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.targetDistanceTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.shootingAngleTextField.keyboardType = UIKeyboardTypeDecimalPad;    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    label.text = @"°";
    label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.shootingAngleTextField.rightViewMode = UITextFieldViewModeAlways;
    self.shootingAngleTextField.rightView = label;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController.topViewController.navigationItem.title isEqualToString:@"Ballistic Profiles"]) {
        BallisticsViewController *controller = (BallisticsViewController*)self.navigationController.topViewController;
        controller.passedRangeResult = self.passedResult;
        controller.passedRangeResultUnits = self.passedResultUnits;
    }    
}

- (void)viewDidUnload
{
    [self.motionManager stopAccelerometerUpdates];

    [self setTargetSizeTextField:nil];
    [self setTargetSizeUnitControl:nil];
    [self setTargetReadingTextField:nil];
    [self setTargetReadingUnitControl:nil];
    [self setResultRangeLabel:nil];
    [self setResultRangeUnitControl:nil];
    [self setTargetDistanceTextField:nil];
    [self setShootingAngleTextField:nil];
    [self setResultHorizontalRangeLabel:nil];
    [self setTargetDistanceUnitLabel:nil];
    [self setResultHorizontalRangeUnitLabel:nil];
    [self setLiveAngleUpdatingSegment:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)showRangeEstimate:(id)sender
{
    if (([self.targetSizeTextField.text floatValue] > 0) && ([self.targetReadingTextField.text floatValue] > 0)) {
        float range = 1000 *  [self.targetSizeTextField.text floatValue] / [self.targetReadingTextField.text floatValue];
        
        // adjust for target size units
        switch (self.targetSizeUnitControl.selectedSegmentIndex) {
            case 0:
                range /= 39.3700787401575;
                break;
            case 1:
                range /= 3.28083989501312;
                break;
            case 2:
                range /= 1.0936132983377078;
                break;
            default:
                break;
        }
        
        // adjust for reading in MOA
        if(self.targetReadingUnitControl.selectedSegmentIndex == 0) {
            range *= ((360*60)/(2000*M_PI));
        }
        // adjust for result in yards
        if(self.resultRangeUnitControl.selectedSegmentIndex == 0) {
            range *= 1.0936132983377078;
        }
        
        self.resultRangeLabel.text = [NSString stringWithFormat:@"%.0f", range];

    } else {
        self.resultRangeLabel.text = @"?";
    }
}

- (IBAction)showHorizontalSolution:(id)sender
{
    float angle = [self.shootingAngleTextField.text floatValue];

    if (([self.shootingAngleTextField.text length] >0) && ([self.targetDistanceTextField.text length] >0) && (angle > -90) && (angle < 90)) {
        float distance = [self.targetDistanceTextField.text floatValue];
        self.resultHorizontalRangeLabel.text = [NSString stringWithFormat:@"%0.f", distance * cos(angle* M_PI / 180)];
    } else {
        self.resultHorizontalRangeLabel.text = @"?";
    }
}


- (IBAction)liveAngleUpdating:(id)sender {

    if(self.liveAngleUpdatingSegment.selectedSegmentIndex) {
        // if iphone 4 do 
        // CMAttitude* currentAttitude = currentMotion.attitude;
        // angleInRadians = currentAttitude.roll;
        
        
        self.motionManager.accelerometerUpdateInterval = 1.0f/60.0f; // 60Hz
        
        [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                                 withHandler:^(CMAccelerometerData *data, NSError *error) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         double angleInRadians;
                                                         if(data != NULL) {
                                                             angleInRadians = atan2(-data.acceleration.z, data.acceleration.y);
                                                             if (angleInRadians < 0.0)
                                                                 angleInRadians += (2.0 * M_PI);
                                                             angleInRadians -= M_PI;
                                                             int angleInDegrees = angleInRadians * (180/M_PI);
                                                             if ((angleInDegrees % 5) == 0) {
                                                                 self.shootingAngleTextField.text = [NSString stringWithFormat:@"%d", angleInDegrees]; 
                                                                 [self showHorizontalSolution:nil];
//                                                                 self.resultHorizontalRangeLabel.text = [NSString stringWithFormat:@"%0.f", [self.targetDistanceTextField.text floatValue] * cos(angleInDegrees * M_PI / 180)];
                                                             }

                                                         }
                                                     });
                                                 }
         ];
        

    } else {
        [self.motionManager stopAccelerometerUpdates];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"HorizontalRange"]) {
        DistanceCalculationsViewController *horizontalRangeController = segue.destinationViewController;
        horizontalRangeController.passedResult = self.resultRangeLabel.text;
        horizontalRangeController.passedResultUnits = [self.resultRangeUnitControl titleForSegmentAtIndex:[self.resultRangeUnitControl selectedSegmentIndex]];
    }
}


- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}


@end
