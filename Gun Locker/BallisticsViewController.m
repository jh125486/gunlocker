//
//  Ballistics2ViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BallisticsViewController.h"

@implementation BallisticsViewController
@synthesize addNewProfileButton;
@synthesize rangeLabel, rangeResult, rangeResultUnits;
@synthesize tempLabel, windLabel, altitudeLabel, densityAltitudeLabel, rhLabel;
@synthesize wxButton, wxStationLabel, wxIndicator, wxTimestampLabel;
@synthesize chooseProfileButton, selectedProfileTextField, selectedProfilePickerView, selectedProfileWeaponLabel, selectedProfileNameLabel;
@synthesize dopeCardsButton, whizWheelButton;

@synthesize locationManager, currentLocation, locationTimer;
@synthesize currentWeather;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
// TESTING Trajectory
    if ([BallisticProfile countOfEntities] == 0) {
        BallisticProfile *ballisticProfile1 = [BallisticProfile createEntity];
        ballisticProfile1.bullet_weight = [NSNumber numberWithInt:55.0];
        ballisticProfile1.drag_model = @"G7";
        ballisticProfile1.muzzle_velocity = [NSNumber numberWithInt:3240];
        ballisticProfile1.zero = [NSNumber numberWithInt:100];
        ballisticProfile1.sight_height_inches = [NSNumber numberWithDouble:1.5];
        ballisticProfile1.name = @"55 grain M193 ";
        ballisticProfile1.bullet_bc = [NSArray arrayWithObject:[NSDecimalNumber decimalNumberWithString:@"0.272"]];
        ballisticProfile1.bullet_diameter_inches = [NSDecimalNumber decimalNumberWithString:@"0.224"];                 
        ballisticProfile1.weapon = [[Weapon findAll] objectAtIndex:2];
        
        BallisticProfile *ballisticProfile2 = [BallisticProfile createEntity];

        ballisticProfile2.bullet_weight = [NSNumber numberWithInt:62.0f];
        ballisticProfile2.drag_model = @"G7";
        ballisticProfile2.muzzle_velocity = [NSNumber numberWithInt:2900];
        ballisticProfile2.zero = [NSNumber numberWithInt:100];
        ballisticProfile2.sight_height_inches = [NSNumber numberWithDouble:2.6];
        ballisticProfile2.name = @"62 grain SS109";
        ballisticProfile2.bullet_bc = [NSArray arrayWithObject:[NSDecimalNumber decimalNumberWithString:@"0.151"]];
        ballisticProfile2.bullet_diameter_inches = [NSDecimalNumber decimalNumberWithString:@"0.224"];                 
        ballisticProfile2.weapon = [[Weapon findAll] objectAtIndex:0];
    }
// TESTING trajectory
    
    
    self.title = @"Ballistics";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    
    selectedProfilePickerView = [[UIPickerView alloc] init];
    selectedProfilePickerView.delegate = self;
    [selectedProfilePickerView setShowsSelectionIndicator:YES];
    self.selectedProfileTextField.inputView = selectedProfilePickerView;
    UIToolbar* textFieldToolBarView = [[UIToolbar alloc] init];
    textFieldToolBarView.barStyle = UIBarStyleBlack;
    textFieldToolBarView.translucent = YES;
    textFieldToolBarView.tintColor = nil;
    [textFieldToolBarView sizeToFit];
    UIBarButtonItem *space  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                           target:self action:@selector(profileCancel:)];
    UIBarButtonItem *done   = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                           target:self action:@selector(profileSelected:)];
    [textFieldToolBarView setItems:[NSArray arrayWithObjects:cancel, space, done, nil]];
    self.selectedProfileTextField.inputAccessoryView = textFieldToolBarView;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    //    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 3000.0f;
    [locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 
                                                          target:self 
                                                        selector:@selector(stopUpdatingLocations) 
                                                        userInfo:nil 
                                                         repeats:NO];
    
    profiles = [[BallisticProfile findAll] mutableCopy];
    
    //Register setRange to recieve "setRange" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRange:) name:@"setRange" object:nil];    
}

-(void)viewWillAppear:(BOOL)animated {
    self.chooseProfileButton.enabled = (profiles.count != 0);
    
    self.addNewProfileButton.enabled = ([Weapon countOfEntities] != 0);
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setWxButton:nil];
    [self setTempLabel:nil];
    [self setWindLabel:nil];
    [self setAltitudeLabel:nil];
    [self setDensityAltitudeLabel:nil];
    [self setWxStationLabel:nil];
    [self setRhLabel:nil];
    [self setChooseProfileButton:nil];
    [self setDopeCardsButton:nil];
    [self setWhizWheelButton:nil];
    [self setRangeLabel:nil];
    [self setSelectedProfileTextField:nil];
    [self stopUpdatingLocations];
    [self setAddNewProfileButton:nil];
    [self setSelectedProfileWeaponLabel:nil];
    [self setSelectedProfileNameLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
	if ([segueID isEqualToString:@"WhizWheel"]) {
        ((WhizWheelViewController *)segue.destinationViewController).selectedProfile = selectedProfile;
    } else if ([segueID isEqualToString:@"DopeTable"]) {
        ((DopeTableTableViewController *)segue.destinationViewController).currentWeather = currentWeather;
        ((DopeTableTableViewController *)segue.destinationViewController).selectedProfile = selectedProfile;
    }

}

- (void)setRange:(NSNotification*)notification {
    NSArray *passedRange = [notification object];
    rangeResult = [passedRange objectAtIndex:0];
    rangeResultUnits = [passedRange objectAtIndex:1];
    self.rangeLabel.text = [NSString stringWithFormat:@"%.0f %@", [rangeResult floatValue], rangeResultUnits];
}

- (IBAction)getWX:(id)sender {
    self.wxStationLabel.hidden = YES;
    [self.wxIndicator startAnimating];
    self.wxButton.enabled = NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.currentWeather = [[Weather alloc] initWithLocation:currentLocation];        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(self.currentWeather.goodData) {
                self.tempLabel.text = [NSString stringWithFormat:@"%.0fº F", TEMP_C_to_TEMP_F(self.currentWeather.temp_c)];
                self.rhLabel.text   = [NSString stringWithFormat:@"%.0f%%", self.currentWeather.relativeHumidity];
                self.windLabel.text = [NSString stringWithFormat:@"%.0f knots from %@", self.currentWeather.wind_speed_kt, 
                                                     [self.currentWeather cardinalDirectionFromDegrees:self.currentWeather.wind_dir_degrees]];
                self.altitudeLabel.text = [NSString stringWithFormat:@"%.0f'%", METERS_to_FEET(self.currentWeather.altitude_m)];
                self.densityAltitudeLabel.text = [NSString stringWithFormat:@"%.0f'%", self.currentWeather.densityAltitude];
                self.wxStationLabel.text = [NSString stringWithFormat:@"%@ (%.0f km)", self.currentWeather.stationID, self.currentWeather.kmFromStation];
                self.wxStationLabel.hidden = NO;
                [self.wxIndicator stopAnimating];
                self.wxButton.enabled = YES;
                self.wxTimestampLabel.text = [NSString stringWithFormat:@"Station reported weather %@", [[self.currentWeather.timestamp distanceOfTimeInWords] lowercaseString]];
                self.wxButton.titleLabel.text = @"↻ WX";
            }
        });
    });
}

- (IBAction)chooseProfileTapped:(id)sender {
    if(selectedProfile) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"View Selected Profile", @"Choose a Different Profile", nil];
        sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        [self.selectedProfileTextField becomeFirstResponder];
    }
}

- (void)profileSelected:(id)sender {
    selectedProfile = [profiles objectAtIndex:[self.selectedProfilePickerView selectedRowInComponent:0]];
    self.selectedProfileWeaponLabel.text = [selectedProfile.weapon description];
    self.selectedProfileNameLabel.text = selectedProfile.name;
    
    [chooseProfileButton setTitle:@"" forState:UIControlStateNormal];
    [chooseProfileButton setTitle:@"" forState:UIControlStateHighlighted];
    [chooseProfileButton setTitle:@"" forState:UIControlStateSelected];
//    chooseProfileButton.titleLabel.textAlignment = UITextAlignmentCenter;
    dopeCardsButton.enabled = YES;
    whizWheelButton.enabled = YES;
    [self.selectedProfileTextField resignFirstResponder];
}

- (void)profileCancel:(id)sender {
    [self.selectedProfileTextField resignFirstResponder];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    
    if(newLocation.horizontalAccuracy <= 100.0f)
        [self stopUpdatingLocations];
    [self getWX:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorDenied) {
        [self stopUpdatingLocations];
        self.wxButton.titleLabel.text = @"⇣ WX";
    } else if(error.code == kCLErrorLocationUnknown) {
        // retry
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)stopUpdatingLocations { 
    locationManager.delegate = nil;
    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager stopUpdatingLocation]; 
    [locationTimer invalidate]; 
}

# pragma mark tableview

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != 0) return nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view addSubview:self.wxTimestampLabel];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0f;
}

#pragma mark Pickerview

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;    
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [profiles count];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (view == nil) {
        BallisticProfile *profile = [profiles objectAtIndex:row];
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *thumbNail = [[UIImageView alloc] initWithFrame:CGRectMake(16, 1, 56, 42)];
        thumbNail.image = [UIImage imageWithData:profile.weapon.photo_thumbnail];
        UILabel *firstLine  = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 230, 22)];
        UILabel *secondLine = [[UILabel alloc] initWithFrame:CGRectMake(75, 22, 230, 22)];
        firstLine.backgroundColor = [UIColor clearColor];
        secondLine.backgroundColor = [UIColor clearColor];
        firstLine.font  = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22];
        secondLine.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18];
        firstLine.textColor = [UIColor blackColor];
        secondLine.textColor = [UIColor darkGrayColor];
        firstLine.adjustsFontSizeToFitWidth = YES;
        firstLine.text  = [NSString stringWithFormat:@"%@", profile.weapon];
        secondLine.text = [NSString stringWithFormat:@"%@", profile.name];
        [view addSubview:thumbNail];
        [view addSubview:firstLine];
        [view addSubview:secondLine];
    }
    
    return view;    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected profile: %@. Index of selected profile: %i", [profiles objectAtIndex:row], row);
}

#pragma mark UIActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // perform segue to ViewProfile
            break;
            
        case 1:
            
            [self.selectedProfileTextField becomeFirstResponder];
            break;
        default:
            break;
    }
}

@end
