//
//  DopeTableTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeTableTableViewController.h"

@implementation DopeTableTableViewController
@synthesize selectedProfile = _selectedProfile, currentWeather = _currentWeather;
@synthesize tempTextField = _tempTextField, tempUnitControl = _tempUnitControl;
@synthesize pressureTextField = _pressureTextField, pressureUnitControl = _pressureUnitControl;
@synthesize rhTextField = _rhTextField;
@synthesize altitudeTextField = _altitudeTextField, altitudeUnitControl = _altitudeUnitControl;
@synthesize windSpeedTextField = _windSpeedTextField, windSpeedUnitControl = _windSpeedUnitControl;
@synthesize windDirectionTextField = _windDirectionTextField, windDirectionTypeControl = _windDirectionTypeControl;
@synthesize targetSpeedTextField = _targetSpeedTextField, targetSpeedUnitControl = _targetSpeedUnitControl;
@synthesize targetDirectionTextField = _targetDirectionTextField, targetDirectionTypeControl = _targetDirectionTypeControl;
@synthesize rangeStartStepper = _rangeStartStepper, rangeEndStepper = _rangeEndStepper, rangeStepStepper = _rangeStepStepper;
@synthesize rangeUnitControl = _rangeUnitControl;
@synthesize dropDriftUnitcontrol = _dropDriftUnitcontrol;
@synthesize currentTextField = _currentTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_background"]];
    
    _rangeStartStepper.Current = 100.f;
    _rangeStartStepper.Minimum = 10.0f;
    
    _rangeEndStepper.Current = 500.f;
    _rangeEndStepper.Maximum = 3000.0f;

    _rangeStepStepper.Current = 100.f;
    _rangeStepStepper.Step = 5.0f;
    _rangeStepStepper.Minimum = 5.0f;
    
    [self setStepperRanges:nil];
    
    [self loadWeather];
    
    formFields = [[NSMutableArray alloc] initWithObjects:_tempTextField, 
                                                        _pressureTextField, 
                                                        _rhTextField, 
                                                        _altitudeTextField, 
                                                        _windDirectionTextField,
                                                        _windSpeedTextField, 
                                                        _targetDirectionTextField, 
                                                        _targetSpeedTextField, 
                                                        nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;
    _pressureTextField.keyboardType = UIKeyboardTypeDecimalPad;

}

-(void)loadWeather {
    if (_currentWeather) {
        _tempTextField.text          = [NSString stringWithFormat:@"%.0f", TEMP_C_to_TEMP_F(_currentWeather.tempC)];
        _pressureTextField.text      = [NSString stringWithFormat:@"%.2f", _currentWeather.altimInHg];
        _rhTextField.text            = [NSString stringWithFormat:@"%.0f", _currentWeather.relativeHumidity];
        _altitudeTextField.text      = [NSString stringWithFormat:@"%.0f", METERS_to_FEET(_currentWeather.altitudeMeters)];
        _windSpeedTextField.text     = [NSString stringWithFormat:@"%.0f", _currentWeather.windSpeedKnots];
        _windDirectionTextField.text = [NSString stringWithFormat:@"%.0f", _currentWeather.windDirectionDegrees];
    } else {
        _tempTextField.text          = @"59";
        _pressureTextField.text      = @"29.92";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = [segue identifier];
    if ([segueID isEqualToString:@"CalculateTrajectory"]) {
        DopeTableGeneratedTableViewController *dst =[[segue.destinationViewController viewControllers] objectAtIndex:0];

        Trajectory *trajectory = [[Trajectory alloc] init];
        
        // do all conversions for UnitControls
        trajectory.rangeUnit  = _rangeUnitControl.selectedSegmentIndex;
        trajectory.rangeStart = _rangeStartStepper.Current;
        trajectory.rangeEnd   = _rangeEndStepper.Current;
        trajectory.rangeStep  = _rangeStepStepper.Current;

        trajectory.tempC = (_tempUnitControl.selectedSegmentIndex == 0) ? TEMP_F_to_TEMP_C([_tempTextField.text doubleValue]) : [_tempTextField.text doubleValue];
        
        trajectory.relativeHumidity = [_rhTextField.text doubleValue];
        trajectory.pressureInhg = (_pressureUnitControl.selectedSegmentIndex == 0) ? [_pressureTextField.text doubleValue] : INHG_to_PA([_pressureTextField.text doubleValue]/100);
        trajectory.altitudeM = (_altitudeUnitControl.selectedSegmentIndex == 0) ? FEET_to_METERS([_altitudeTextField.text doubleValue]) : [_altitudeTextField.text doubleValue];

        trajectory.windSpeed = (_windSpeedUnitControl.selectedSegmentIndex == 0) ? KNOTS_to_MPH([_windSpeedTextField.text doubleValue]) : [_windSpeedTextField.text doubleValue];
        trajectory.windAngle = (_windDirectionTypeControl.selectedSegmentIndex == 0) ? [_windDirectionTextField.text doubleValue] : CLOCK_to_DEGREES([_windDirectionTextField.text doubleValue]);
        
        trajectory.targetSpeed = (_targetSpeedUnitControl.selectedSegmentIndex == 0) ? KPH_to_MPH([_targetSpeedTextField.text doubleValue]) : [_targetSpeedTextField.text doubleValue];
        trajectory.targetAngle = (_targetDirectionTypeControl.selectedSegmentIndex == 0) ? [_targetDirectionTextField.text doubleValue] : CLOCK_to_DEGREES([_targetDirectionTextField.text doubleValue]);
        
        trajectory.ballisticProfile = _selectedProfile;
        
        dst.rangeUnit = [[NSArray arrayWithObjects:@"Yards", @"Meters", nil] objectAtIndex:_rangeUnitControl.selectedSegmentIndex];;
        dst.dopeUnit = [[NSArray arrayWithObjects:@"Inches", @"MOA", @"Mils", @"Clicks", nil] objectAtIndex:_dropDriftUnitcontrol.selectedSegmentIndex];

        dst.tempString = [NSString stringWithFormat:@"%@º %@", _tempTextField.text, 
                          [[NSArray arrayWithObjects:@"F", @"C", nil] objectAtIndex:_tempUnitControl.selectedSegmentIndex]];
        
        dst.altitudeString = [NSString stringWithFormat:@"%@ %@", _altitudeTextField.text, 
                              [[NSArray arrayWithObjects:@"ft", @"m", nil] objectAtIndex:_altitudeUnitControl.selectedSegmentIndex]];
        
        dst.pressureString = [NSString stringWithFormat:@"%@ %@", _pressureTextField.text,
                              [[NSArray arrayWithObjects:@"inHg", @"mb", nil] objectAtIndex:_pressureUnitControl.selectedSegmentIndex]];

        dst.windInfoString = [NSString stringWithFormat:@"%@ %@ from %@%@", _windSpeedTextField.text, 
                              [[NSArray arrayWithObjects:@"Knots", @"MPH", nil] objectAtIndex:_windSpeedUnitControl.selectedSegmentIndex], 
                              _windDirectionTextField.text,
                              [[NSArray arrayWithObjects:@"º", @" o'clock", nil] objectAtIndex:_windDirectionTypeControl.selectedSegmentIndex]];
        
        dst.targetInfoString = [NSString stringWithFormat:@"%@ %@ from %@%@", _targetSpeedTextField.text, 
                              [[NSArray arrayWithObjects:@"Knots", @"MPH", nil] objectAtIndex:_targetSpeedUnitControl.selectedSegmentIndex], 
                              _targetDirectionTextField.text, 
                              [[NSArray arrayWithObjects:@"º", @" o'clock", nil] objectAtIndex:_targetDirectionTypeControl.selectedSegmentIndex]];
        
        dst.passedTrajectory = trajectory;
//        [TestFlight passCheckpoint:@"Dope Table Calculated"];
    } else if ([segueID isEqualToString:@"WindModal"]) {
        [TestFlight passCheckpoint:@"Direction/Speed Modal Viewed"];
        DirectionSpeedViewController *dst = segue.destinationViewController;
        dst.resultType = @"Wind";
        dst.speedUnit  = _windSpeedUnitControl.selectedSegmentIndex;
        dst.speedValue = [_windSpeedTextField.text intValue];
        dst.directionType = _windDirectionTypeControl.selectedSegmentIndex;
        dst.directionValue = [_windDirectionTextField.text intValue];
        dst.delegate = self;
    } else if ([segueID isEqualToString:@"LeadModal"]) {
        [TestFlight passCheckpoint:@"Direction/Speed Modal Viewed"];
        DirectionSpeedViewController *dst = segue.destinationViewController;
        dst.resultType = @"Target";
        dst.speedUnit  = _targetSpeedUnitControl.selectedSegmentIndex;
        dst.speedValue = [_targetSpeedTextField.text intValue];
        dst.directionType = _targetDirectionTypeControl.selectedSegmentIndex;
        dst.directionValue = [_targetDirectionTextField.text intValue];
        dst.delegate = self;
    }
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
    } else if ([formFields lastObject] == textField) {
        [control setEnabled:NO forSegmentAtIndex:1];
    }
    
    [textFieldToolBarView setItems:[NSArray arrayWithObjects:controlItem, space, done, nil]];
    textField.inputAccessoryView = textFieldToolBarView;
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _currentTextField = textField;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) textField.text = @"0";

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

# pragma mark Actions
- (IBAction)calculate:(id)sender {
    [self performSegueWithIdentifier:@"CalculateTrajectory" sender:self];
}

- (IBAction)setToDefaultEnvironmentTapped:(id)sender {
    _tempTextField.text = @"59";
    _tempUnitControl.selectedSegmentIndex = 0;
    _pressureTextField.text = @"29.92";
    _pressureUnitControl.selectedSegmentIndex = 0;
    _rhTextField.text = @"0";
    _altitudeTextField.text = @"0";
    _windSpeedTextField.text = @"0";
    _windDirectionTextField.text = @"0";
}

- (IBAction)setStepperRanges:(id)sender {
    _rangeStartStepper.Maximum = _rangeEndStepper.Current - _rangeStepStepper.Current;
    _rangeStartStepper.Step    = _rangeStepStepper.Current;
    _rangeEndStepper.Minimum   = _rangeStartStepper.Current + _rangeStepStepper.Current;
    _rangeStepStepper.Maximum  = _rangeEndStepper.Current - _rangeStartStepper.Current;
    _rangeEndStepper.Step      = _rangeStepStepper.Current;
}

#pragma mark Table delegates
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" owner:self options:nil] 
                                              objectAtIndex:0];
    
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

#pragma mark DirectionSpeedProtocol Delegate methods

-(void)windSetWithDirectionType:(int)directionType andDirection:(int)direction andSpeedType:(int)speedType andSpeed:(int)speed {
    _windDirectionTypeControl.selectedSegmentIndex = directionType;
    _windDirectionTextField.text = [NSString stringWithFormat:@"%d", direction];
    _windSpeedUnitControl.selectedSegmentIndex = speedType;
    _windSpeedTextField.text = [NSString stringWithFormat:@"%d", speed];
}

-(void)targetSetWithDirectionType:(int)directionType andDirection:(int)direction andSpeedType:(int)speedType andSpeed:(int)speed {
    _targetDirectionTypeControl.selectedSegmentIndex = directionType;
    _targetDirectionTextField.text = [NSString stringWithFormat:@"%d", direction];
    _targetSpeedUnitControl.selectedSegmentIndex = speedType;
    _targetSpeedTextField.text = [NSString stringWithFormat:@"%d", speed];    
}

@end
