//
//  RangingViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RangingViewController.h"

@implementation RangingViewController
@synthesize targetSizeTextField, targetSizeUnitControl;
@synthesize targetSpansTextField, targetSpansUnitControl;
@synthesize angleTextField, angleLiveUpdateControl;
@synthesize resultLabel, resultUnitControl;
@synthesize currentTextField;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 12, 14)];
    label.text = @"°";
    label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    self.angleTextField.rightViewMode = UITextFieldViewModeAlways;
    self.angleTextField.rightView = label;

    sizeUnits  = [NSArray arrayWithObjects:@"inches", @"feet", @"yards", @"meters", nil];
    spansUnits = [NSArray arrayWithObjects:@"MOA", @"Mils", nil];
    
    //Register self to recieve notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectSize:) name:@"didSelectSize" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectSpans:) name:@"didSelectSpans" object:nil];

    formFields = [NSArray arrayWithObjects:self.targetSizeTextField, self.targetSpansTextField, self.angleTextField, nil];
    for(UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
    }
}

- (void)viewDidUnload {
    [self.motionManager stopAccelerometerUpdates];

    [self setTargetSizeTextField:nil];
    [self setTargetSizeUnitControl:nil];
    [self setTargetSpansTextField:nil];
    [self setTargetSpansUnitControl:nil];
    [self setAngleTextField:nil];
    [self setAngleLiveUpdateControl:nil];
    [self setResultLabel:nil];
    [self setResultUnitControl:nil];
    [super viewDidUnload];
}

- (void)didSelectSize:(NSNotification*) notification  {
    NSString *value = [[notification object] objectAtIndex:0];
    NSString *unit = [[notification object] objectAtIndex:1];

    self.targetSizeTextField.text = value;
    self.targetSizeUnitControl.selectedSegmentIndex = [sizeUnits indexOfObject:unit];
    [self showRangeEstimate:nil];
}

- (void)didSelectSpans:(NSNotification*) notification  {
    NSString *value = [[notification object] objectAtIndex:0];
    NSString *unit = [[notification object] objectAtIndex:1];

    self.targetSpansTextField.text = value;
    self.targetSpansUnitControl.selectedSegmentIndex = [spansUnits indexOfObject:unit];
    [self showRangeEstimate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark Actions
- (IBAction)showRangeEstimate:(id)sender {
    float angle = [self.angleTextField.text floatValue];

    if (([self.targetSizeTextField.text floatValue] > 0) && ([self.targetSpansTextField.text floatValue] > 0) && (angle > -90) && (angle < 90)) {
        double range = 1000 *  [self.targetSizeTextField.text floatValue] / [self.targetSpansTextField.text floatValue];
        
        // adjust for target size units
        switch (self.targetSizeUnitControl.selectedSegmentIndex) {
            case 0: // inches
                range /= INCHES_PER_METER;
                break;
            case 1: // feet
                range /= FEET_PER_METER;
                break;
            case 2: // yards
                range /= YARDS_PER_METER;
                break;
            default: // meters
                break;
        }
        
        // adjust for reading in MOA
        if(self.targetSpansUnitControl.selectedSegmentIndex == 0) range *= MOA_PER_MIL;
        
        // adjust for result in yards
        if(self.resultUnitControl.selectedSegmentIndex == 0) range *= YARDS_PER_METER;
        
        // adjust for angle
        range *= cos(DEGREES_to_RAD(angle));
        
        self.resultLabel.text = [NSString stringWithFormat:@"Range %.0f", range];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setRange" 
                                                            object:[NSArray arrayWithObjects:[NSNumber numberWithDouble:range], 
                                                                                             [resultUnitControl titleForSegmentAtIndex:resultUnitControl.selectedSegmentIndex], nil]];        
    } else {
        self.resultLabel.text = @"Range n/a";
    }
}

- (IBAction)liveAngleUpdating:(id)sender {
    if(self.angleLiveUpdateControl.selectedSegmentIndex) {
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
                                                             int angleInDegrees = RAD_to_DEGREES(angleInRadians);
                                                             if (((angleInDegrees % 5) == 0) && (angleInDegrees < 90)) {
                                                                 self.angleTextField.text = [NSString stringWithFormat:@"%d", abs(angleInDegrees)];                                                                 
                                                                 [self showRangeEstimate:nil];
                                                             }
                                                             
                                                         }
                                                     });
                                                 }
         ];
        
        
    } else {
        [self.motionManager stopAccelerometerUpdates];
    }  
}

- (CMMotionManager *)motionManager {
    CMMotionManager *motionManager = nil;
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    return motionManager;
}

#pragma mark TableView

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23.0f;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Table/tableView_header_background"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, headerView.frame.size.width - 20, tableView.sectionHeaderHeight)];
	label.text = sectionTitle;
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:20.0];
	label.shadowColor = [UIColor lightTextColor];
    label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor clearColor];    
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
}

#pragma mark TextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIToolbar* textFieldToolBarView = [[UIToolbar alloc] init];
    textFieldToolBarView.barStyle = UIBarStyleBlack;
    textFieldToolBarView.translucent = YES;
    textFieldToolBarView.tintColor = nil;
    [textFieldToolBarView sizeToFit];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                             NSLocalizedString(@"Previous",@"Previous form field"),
                                                                             NSLocalizedString(@"Next",@"Next form field"),                                         
                                                                             nil]];
    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.tintColor = [UIColor darkGrayColor];
    control.momentary = YES;
    [control addTarget:self action:@selector(nextPreviousTapped:) forControlEvents:UIControlEventValueChanged];     
    
    UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *done  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                           target:self action:@selector(doneTyping:)];
    
    if ([formFields indexOfObject:textField] == 0) {
        [control setEnabled:NO forSegmentAtIndex:0];
    } else if ([formFields lastObject]== textField) {
        [control setEnabled:NO forSegmentAtIndex:1];
    }
    
    [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBarView;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentTextField = textField;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.angleTextField.text isEqualToString:@""]) self.angleTextField.text = @"0";
    self.currentTextField = nil;
}

- (void) nextPreviousTapped:(id)sender {
    int index = [formFields indexOfObject:self.currentTextField];
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0: // previous
            if (index > 0) index--;
            break;
        case 1: //next
            if (index < ([formFields count] - 1)) index++;
            break;
    }
    
    self.currentTextField = [formFields objectAtIndex:index];
    [self.currentTextField becomeFirstResponder];
}

- (void) doneTyping:(id)sender {
    [self.currentTextField resignFirstResponder];
}


@end
