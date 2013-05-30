//
//  RangingViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RangingViewController.h"

@implementation RangingViewController
@synthesize targetSizeTextField = _targetSizeTextField;
@synthesize targetSizeUnitControl = _targetSizeUnitControl;
@synthesize targetSpansTextField = _targetSpansTextField;
@synthesize targetSpansUnitControl = _targetSpansUnitControl;
@synthesize angleTextField = _angleTextField;
@synthesize angleLiveUpdateControl = _angleLiveUpdateControl;
@synthesize resultLabel = _resultLabel;
@synthesize resultUnitControl = _resultUnitControl;
@synthesize resultView = _resultView;
@synthesize currentTextField = _currentTextField;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_background"]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 12, 14)];
    label.text = @"°";
    label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    _angleTextField.rightViewMode = UITextFieldViewModeAlways;
    _angleTextField.rightView = label;

    sizeUnits  = [NSArray arrayWithObjects:@"inches", @"feet", @"yards", @"meters", nil];
    spansUnits = [NSArray arrayWithObjects:@"MOA", @"Mils", nil];
    
    //Register self to recieve notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectSize:) name:@"didSelectSize" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectSpans:) name:@"didSelectSpans" object:nil];

    formFields = [NSArray arrayWithObjects:_targetSizeTextField, 
		                                   _targetSpansTextField, 
										   _angleTextField, 
										   nil];
	
    for(UITextField *field in formFields) {
        field.delegate = self;
        field.keyboardType = UIKeyboardTypeDecimalPad;
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
}

- (void)didSelectSize:(NSNotification*) notification  {
    NSString *value = [[notification object] objectAtIndex:0];
    NSString *unit = [[notification object] objectAtIndex:1];

    _targetSizeTextField.text = value;
    _targetSizeUnitControl.selectedSegmentIndex = [sizeUnits indexOfObject:unit];
    [self showRangeEstimate:nil];
}

- (void)didSelectSpans:(NSNotification*) notification  {
    NSString *value = [[notification object] objectAtIndex:0];
    NSString *unit = [[notification object] objectAtIndex:1];

    _targetSpansTextField.text = value;
    _targetSpansUnitControl.selectedSegmentIndex = [spansUnits indexOfObject:unit];
    [self showRangeEstimate:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark Actions
- (IBAction)showRangeEstimate:(id)sender {
    float angle = [_angleTextField.text floatValue];

    if (([_targetSizeTextField.text floatValue] > 0) && ([_targetSpansTextField.text floatValue] > 0) && (angle > -90) && (angle < 90)) {
        double range = 1000 *  [_targetSizeTextField.text floatValue] / [_targetSpansTextField.text floatValue];
        
        // adjust for target size units
        switch (_targetSizeUnitControl.selectedSegmentIndex) {
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
        if(_targetSpansUnitControl.selectedSegmentIndex == 0) range *= MOA_PER_MIL;
        
        // adjust for result in yards
        if(_resultUnitControl.selectedSegmentIndex == 0) range *= YARDS_PER_METER;
        
        // adjust for angle
        range *= cos(DEGREES_to_RAD(angle));
        
        _resultLabel.text = [NSString stringWithFormat:@"Range %.0f", range];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setRange" 
                                                            object:[NSArray arrayWithObjects:[NSNumber numberWithDouble:range], 
                                                                                             [_resultUnitControl titleForSegmentAtIndex:_resultUnitControl.selectedSegmentIndex], nil]];        
    } else {
        _resultLabel.text = @"Range n/a";
    }
}

- (IBAction)liveAngleUpdating:(id)sender {
    if(_angleLiveUpdateControl.selectedSegmentIndex) {
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
                                                                 _angleTextField.text = [NSString stringWithFormat:@"%d", abs(angleInDegrees)];                                                                 
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

#pragma mark TextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                             NSLocalizedString(@"Previous",@"Previous form field"),
                                                                             NSLocalizedString(@"Next",@"Next form field"),                                         
                                                                             nil]];
    control.segmentedControlStyle = UISegmentedControlStyleBar;
    control.tintColor = [UIColor darkGrayColor];
    control.momentary = YES;
    [control addTarget:self action:@selector(nextPreviousTapped:) forControlEvents:UIControlEventValueChanged];     
    
    UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:control];    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                           target:nil 
                                                                           action:nil];
    UIBarButtonItem *done  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                           target:self 
                                                                           action:@selector(doneTyping:)];
    
    if ([formFields indexOfObject:textField] == 0) {
        [control setEnabled:NO forSegmentAtIndex:0];
    } else if ([formFields lastObject] == textField) {
        [control setEnabled:NO forSegmentAtIndex:1];
    }
    
    UIToolbar* textFieldToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
    textFieldToolBar.barStyle = UIBarStyleBlackTranslucent;
    [textFieldToolBar setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBar;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentTextField = textField;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([_angleTextField.text isEqualToString:@""]) _angleTextField.text = @"0";
    _currentTextField = nil;
}

- (void)nextPreviousTapped:(id)sender {
    int index = [formFields indexOfObject:_currentTextField];
    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0: // previous
            if (index > 0) index--;
            break;
        case 1: //next
            if (index < ([formFields count] - 1)) index++;
            break;
    }
    
    _currentTextField = [formFields objectAtIndex:index];
    [_currentTextField becomeFirstResponder];
}

- (void)doneTyping:(id)sender {
    [_currentTextField resignFirstResponder];
}

#pragma mark Tableview
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _resultView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_header_background2"]];
    return _resultView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 46.f;
}

@end
