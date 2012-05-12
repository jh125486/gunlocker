//
//  DopeTableTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeTableTableViewController.h"

@implementation DopeTableTableViewController
@synthesize selectedProfile, currentWeather;
@synthesize tempTextField, tempUnitControl;
@synthesize pressureTextField, pressureUnitControl;
@synthesize rhTextField;
@synthesize altitudeTextField, altitudeUnitControl;
@synthesize windSpeedTextField, windSpeedUnitControl, windDirectionTextField, windDirectionUnitControl;
@synthesize leadingSpeedTextField, leadingSpeedUnitControl, leadingDirectionTextField, leadingDirectionUnitControl;
@synthesize rangeStartStepper, rangeEndStepper, rangeStepStepper;
@synthesize rangeUnitControl;
@synthesize dropDriftUnitcontrol;
@synthesize currentTextField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];

    NSLog(@"profile %@", selectedProfile.name);
    
    self.rangeStartStepper.Current = 100.f;
    self.rangeStartStepper.Minimum = 0.0f;
    self.rangeStartStepper.Maximum = 1000.0f;
    
    self.rangeEndStepper.Current = 500.f;
    self.rangeEndStepper.Minimum = 100.0f;
    self.rangeEndStepper.Maximum = 2000.0f;

    self.rangeStepStepper.Current = 100.f;
    self.rangeStepStepper.Minimum = 1.0f;
    self.rangeStepStepper.Maximum = 250.0f;
    
    [self loadWeather];
    
    formFields = [[NSMutableArray alloc] initWithObjects:self.tempTextField, 
                                                        self.pressureTextField, 
                                                        self.rhTextField, 
                                                        self.altitudeTextField, 
                                                        self.windSpeedTextField, 
                                                        self.windDirectionTextField, 
                                                        self.leadingSpeedTextField, 
                                                        self.leadingDirectionTextField, 
                                                        nil];
    
    for(UITextField *field in formFields)
        field.delegate = self;
    self.pressureTextField.keyboardType = UIKeyboardTypeDecimalPad;

}

-(void)loadWeather {
    if (self.currentWeather.goodData) {
        self.tempTextField.text          = [NSString stringWithFormat:@"%.0f", self.currentWeather.temp_f];
        self.pressureTextField.text      = [NSString stringWithFormat:@"%.2f", self.currentWeather.altim_in_hg];
        self.rhTextField.text            = [NSString stringWithFormat:@"%.0f", self.currentWeather.relativeHumidity];
        self.altitudeTextField.text      = [NSString stringWithFormat:@"%.0f", METERS_to_FEET(self.currentWeather.altitude_m)];
        self.windSpeedTextField.text     = [NSString stringWithFormat:@"%.0f", self.currentWeather.wind_speed_kt];
        self.windDirectionTextField.text = [NSString stringWithFormat:@"%.0f", self.currentWeather.wind_dir_degrees];
    } else {
        self.tempTextField.text          = @"59";
        self.pressureTextField.text      = @"29.92";
    }
}

- (void)viewDidUnload {
    [self setTempTextField:nil];
    [self setTempUnitControl:nil];
    [self setPressureTextField:nil];
    [self setPressureUnitControl:nil];
    [self setRhTextField:nil];
    [self setAltitudeTextField:nil];
    [self setAltitudeUnitControl:nil];
    [self setRangeUnitControl:nil];
    [self setRangeStartStepper:nil];
    [self setRangeEndStepper:nil];
    [self setRangeStepStepper:nil];
    [self setWindSpeedTextField:nil];
    [self setWindSpeedUnitControl:nil];
    [self setWindDirectionTextField:nil];
    [self setWindDirectionUnitControl:nil];
    [self setLeadingSpeedTextField:nil];
    [self setLeadingSpeedUnitControl:nil];
    [self setLeadingDirectionTextField:nil];
    [self setLeadingDirectionUnitControl:nil];
    [self setDropDriftUnitcontrol:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DopeTableGeneratedTableViewController *dst =[[segue.destinationViewController viewControllers] objectAtIndex:0];

    Trajectory *trajectory = [[Trajectory alloc] init];
    
    // XXX do all conversions for UnitControls
    trajectory.rangeMin = self.rangeStartStepper.Current;
    trajectory.rangeMax =  self.rangeEndStepper.Current;
    trajectory.rangeIncrement = self.rangeStepStepper.Current;

    trajectory.tempC = (self.tempUnitControl.selectedSegmentIndex == 0) ? TEMP_F_to_TEMP_C([self.tempTextField.text doubleValue]) : [self.tempTextField.text doubleValue];
    
    trajectory.relativeHumidity = [self.rhTextField.text doubleValue];
    trajectory.pressureInhg = (self.pressureUnitControl.selectedSegmentIndex == 0) ? [self.pressureTextField.text doubleValue] : INHG_to_PA([self.pressureTextField.text doubleValue]/100);
    trajectory.altitudeM = (self.altitudeUnitControl.selectedSegmentIndex == 0) ? FEET_to_METERS([self.altitudeTextField.text doubleValue]) : [self.altitudeTextField.text doubleValue];

    trajectory.windSpeed = (self.windSpeedUnitControl.selectedSegmentIndex == 0) ? KNOTS_to_MPH([self.windSpeedTextField.text doubleValue]) : [self.windSpeedTextField.text doubleValue];
    trajectory.windAngle = (self.windDirectionUnitControl.selectedSegmentIndex == 0) ? [self.windDirectionTextField.text doubleValue] : CLOCK_to_DEGREES([self.windDirectionTextField.text doubleValue]);
    
    trajectory.leadSpeed = (self.leadingSpeedUnitControl.selectedSegmentIndex == 0) ? KNOTS_to_MPH([self.leadingSpeedTextField.text doubleValue]) : [self.leadingSpeedTextField.text doubleValue];
    trajectory.leadAngle = (self.leadingDirectionUnitControl.selectedSegmentIndex == 0) ? [self.leadingDirectionTextField.text doubleValue] : CLOCK_to_DEGREES([self.leadingDirectionTextField.text doubleValue]);
    
    trajectory.ballisticProfile = selectedProfile;
    
    dst.rangeUnit = [[NSArray arrayWithObjects:@"Yards", @"Meters", nil] objectAtIndex:self.rangeUnitControl.selectedSegmentIndex];;
    dst.dropDriftUnit = [[NSArray arrayWithObjects:@"Inches", @"MOA", @"Mils", nil] objectAtIndex:self.dropDriftUnitcontrol.selectedSegmentIndex];

    dst.tempString = [NSString stringWithFormat:@"%@º %@", self.tempTextField.text, 
                      [[NSArray arrayWithObjects:@"F", @"C", nil] objectAtIndex:self.tempUnitControl.selectedSegmentIndex]];
    
    dst.altitudeString = [NSString stringWithFormat:@"%@ %@", self.altitudeTextField.text, 
                          [[NSArray arrayWithObjects:@"ft", @"m", nil] objectAtIndex:self.altitudeUnitControl.selectedSegmentIndex]];
    
    dst.pressureString = [NSString stringWithFormat:@"%@ %@", self.pressureTextField.text,
                          [[NSArray arrayWithObjects:@"inHg", @"mb", nil] objectAtIndex:self.pressureUnitControl.selectedSegmentIndex]];
    
    dst.windInfoString = [NSString stringWithFormat:@"%@ %@ from %@%@", self.windSpeedTextField.text, 
                          [[NSArray arrayWithObjects:@"Knots", @"MPH", nil] objectAtIndex:self.windSpeedUnitControl.selectedSegmentIndex], 
                          self.windDirectionTextField.text,
                          [[NSArray arrayWithObjects:@"º", @" o'Clock", nil] objectAtIndex:windDirectionUnitControl.selectedSegmentIndex]];
    
    dst.leadInfoString = [NSString stringWithFormat:@"%@ %@ at %@%@", self.leadingSpeedTextField.text, 
                          [[NSArray arrayWithObjects:@"Knots", @"MPH", nil] objectAtIndex:self.leadingSpeedUnitControl.selectedSegmentIndex], 
                          self.leadingDirectionTextField.text, 
                          [[NSArray arrayWithObjects:@"º", @" o'Clock", nil] objectAtIndex:self.leadingDirectionUnitControl.selectedSegmentIndex]];

    dst.passedTrajectory = trajectory;
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
    self.currentTextField = textField;    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) textField.text = @"0";

    self.currentTextField = nil;
}

- (void) nextPreviousTapped:(id)sender {
    int index = [formFields indexOfObject:currentTextField];
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

# pragma mark Actions
- (IBAction)calculate:(id)sender {
    [self performSegueWithIdentifier:@"CalculateTrajectory" sender:self];
}

- (IBAction)setToDefaultEnvironmentTapped:(id)sender {
    self.tempTextField.text = @"59";
    self.tempUnitControl.selectedSegmentIndex = 0;
    self.pressureTextField.text = @"29.92";
    self.pressureUnitControl.selectedSegmentIndex = 0;
    self.rhTextField.text = @"0";
    self.altitudeTextField.text = @"0";
    self.windSpeedTextField.text = @"0";
    self.windDirectionTextField.text = @"0";
}

- (IBAction)setStepperRanges:(id)sender {
    self.rangeStartStepper.Maximum = self.rangeEndStepper.Current - self.rangeStepStepper.Current;
    self.rangeEndStepper.Minimum   = self.rangeStartStepper.Current + self.rangeStepStepper.Current;
    self.rangeStepStepper.Maximum  = self.rangeEndStepper.Current - self.rangeStartStepper.Current;    
}

#pragma mark Table delegates

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 24)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
	label.shadowColor = [UIColor clearColor];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
}

@end
