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
@synthesize chooseProfileButton, selectedProfileTextField;
@synthesize selectedProfilePickerView = _selectedProfilePickerView;
@synthesize selectedProfileWeaponLabel, selectedProfileNameLabel;
@synthesize dopeCardsButton, whizWheelButton;

@synthesize locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize locationTimer;
@synthesize currentWeather = _currentWeather;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
//// TESTING Trajectory
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
        ballisticProfile1.weapon = [[Weapon findAll] objectAtIndex:1];
        [ballisticProfile1 calculateTheta];
        
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
        [ballisticProfile2 calculateTheta];

        [[NSManagedObjectContext defaultContext] save];
    }
//// TESTING trajectory
    
    self.title = @"Ballistics";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    
    _selectedProfilePickerView = [[UIPickerView alloc] init];
    _selectedProfilePickerView.delegate = self;
    [_selectedProfilePickerView setShowsSelectionIndicator:YES];
    self.selectedProfileTextField.inputView = _selectedProfilePickerView;
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
    
    
    //Register setRange to recieve "setRange" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRange:) name:@"setRange" object:nil];    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    profiles = [BallisticProfile findAll];
    NSLog(@"Profile count: %d (%d)", [profiles count], [BallisticProfile countOfEntities]);
    
    [self setUpPickerData];
    [_selectedProfilePickerView reloadAllComponents];
    if ([profiles containsObject:selectedProfile]) {
        [_selectedProfilePickerView selectRow:[profiles indexOfObject:selectedProfile] inComponent:0 animated:NO];
    } else {
        [self resetChooseProfileButton];
    }        
    
    self.chooseProfileButton.enabled = (profiles.count != 0);
    
    self.addNewProfileButton.enabled = ([Weapon countOfEntities] != 0);
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //crash for some reason
//    if (_currentWeather && _currentWeather.goodData) {
//        self.wxTimestampLabel.text = [NSString stringWithFormat:@"Station reported weather %@", [[_currentWeather.timestamp distanceOfTimeInWords] lowercaseString]];
//    } else {
//        self.wxTimestampLabel.text = @"";
//    }
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
    
	if ([segueID isEqualToString:@"WhizWheel"]) {
        ((WhizWheelViewController *)segue.destinationViewController).selectedProfile = selectedProfile;
    } else if ([segueID isEqualToString:@"DopeTable"]) {
        ((DopeTableTableViewController *)segue.destinationViewController).currentWeather = _currentWeather;
        ((DopeTableTableViewController *)segue.destinationViewController).selectedProfile = selectedProfile;
    }  else if ([segueID isEqualToString:@"ShowProfile"]) {
        ((ProfileViewTableViewController *)segue.destinationViewController).profile = selectedProfile;
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)setRange:(NSNotification*)notification {
    NSArray *passedRange = [notification object];
    rangeResult = [passedRange objectAtIndex:0];
    rangeResultUnits = [passedRange objectAtIndex:1];
    self.rangeLabel.text = [NSString stringWithFormat:@"%.0f %@", [rangeResult floatValue], rangeResultUnits];
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
    
    [self.chooseProfileButton setTitle:@"" forState:UIControlStateNormal];
    [self.chooseProfileButton setTitle:@"" forState:UIControlStateHighlighted];
    [self.chooseProfileButton setTitle:@"" forState:UIControlStateSelected];
//    chooseProfileButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.dopeCardsButton.enabled = YES;
    self.whizWheelButton.enabled = YES;
    [self.selectedProfileTextField resignFirstResponder];
}

-(void)resetChooseProfileButton {
    selectedProfile = nil;
    [self.chooseProfileButton setTitle:@"Choose a Profile" forState:UIControlStateNormal];
    [self.chooseProfileButton setTitle:@"Choose a Profile" forState:UIControlStateHighlighted];
    [self.chooseProfileButton setTitle:@"Choose a Profile" forState:UIControlStateSelected];
    self.selectedProfileWeaponLabel.text = @"";
    self.selectedProfileNameLabel.text = @"";
    self.dopeCardsButton.enabled = NO;
    self.whizWheelButton.enabled = NO;
}

- (void)profileCancel:(id)sender {
    [self.selectedProfileTextField resignFirstResponder];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    _currentLocation = newLocation;
    
    if(newLocation.horizontalAccuracy <= 100.0f)
        [self stopUpdatingLocations];
    [self getWX:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorDenied) {
        [self stopUpdatingLocations];
        [self resetWX];
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
    return [profilePickerData count];
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    return [profilePickerData objectAtIndex:row];
}

- (void)setUpPickerData {
    profilePickerData = [[NSMutableArray alloc] initWithCapacity:[profiles count]];
    
    for(BallisticProfile *profile in profiles) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
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
        [profilePickerData addObject:view];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
//    NSLog(@"Selected profile: %@. Index of selected profile: %i", [profiles objectAtIndex:row], row);
}

#pragma mark UIActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // perform segue to ViewProfile
            [self performSegueWithIdentifier:@"ShowProfile" sender:nil];
            break;
            
        case 1:
            // choose a different profile
            [self.selectedProfileTextField becomeFirstResponder];
            break;
        default:
            break;
    }
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

#pragma mark WX

- (IBAction)getWX:(id)sender {
    self.wxStationLabel.hidden = self.wxTimestampLabel.hidden = YES;
    [self.wxIndicator startAnimating];
    self.wxButton.enabled = NO;

    NSLog(@"Getting weather for Lat %f Long %f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);

    NSString *unescapedURL = [NSString stringWithFormat:@"http://weather.aero/dataserver_current/httpparam?dataSource=metars&requestType=retrieve&format=csv&radialDistance=30;%f,%f&hoursBeforeNow=2&fields=observation_time,station_id,latitude,longitude,temp_c,dewpoint_c,wind_dir_degrees,wind_speed_kt,altim_in_hg", _currentLocation.coordinate.longitude, _currentLocation.coordinate.latitude];
    
    NSURL *url = [NSURL URLWithString:[unescapedURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.finishedBlock = ^{
        if (operation.hasAcceptableStatusCode) {
            NSArray *metarArray = [[[NSString alloc] initWithBytes:[operation.responseObject bytes] length:[operation.responseObject length] encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
            
            if ([[metarArray objectAtIndex:0] isEqualToString:@"No errors"]) {
                int count = [[[[metarArray objectAtIndex:4] componentsSeparatedByString:@" "] objectAtIndex:0] intValue];
                
                NSArray *weatherArray = [metarArray subarrayWithRange:NSMakeRange(6, count)]; 

                _currentWeather = [[Weather alloc] initClosetWeatherFromMetarArray:weatherArray andLocation:_currentLocation];

                self.tempLabel.text = [NSString stringWithFormat:@"%.0fº F", TEMP_C_to_TEMP_F(_currentWeather.tempC)];
                self.rhLabel.text   = [NSString stringWithFormat:@"%.0f%%", _currentWeather.relativeHumidity];
                self.windLabel.text = [NSString stringWithFormat:@"%.0f knots from %@", _currentWeather.windSpeedKnots, 
                                                     [_currentWeather cardinalDirectionFromDegrees:_currentWeather.windDirectionDegrees]];
                self.altitudeLabel.text = [NSString stringWithFormat:@"%.0f'%", METERS_to_FEET(_currentWeather.altitudeMeters)];
                self.densityAltitudeLabel.text = [NSString stringWithFormat:@"%.0f'%", _currentWeather.densityAltitude];
                self.wxStationLabel.text = [NSString stringWithFormat:@"%@ (%.0f km)", _currentWeather.stationID, _currentWeather.kmFromStation];
                self.wxTimestampLabel.hidden = self.wxStationLabel.hidden = NO;
                [self.wxIndicator stopAnimating];
                self.wxButton.enabled = YES;
                self.wxTimestampLabel.text = [NSString stringWithFormat:@"Station reported weather %@", [[_currentWeather.timestamp distanceOfTimeInWords] lowercaseString]];

                self.wxButton.titleLabel.text = @"↻ WX";

            } else { // errors with weather.aero
               NSLog(@"! Problem with METAR data from weather.aero: %@\n", metarArray);
                [self resetWX];
                self.wxTimestampLabel.text = @"Error processing weather data: dataservice down";
           }
        } else {      // network errors       
            NSLog(@"! Error: %@", operation.error.localizedDescription);
            [self resetWX];
            self.wxTimestampLabel.text = operation.error.localizedDescription;
        }
    };
    
    [operation start];
}

-(void)resetWX {
    _currentWeather = nil;
    
    [self.wxIndicator stopAnimating];
    self.tempLabel.text            = @"n/a";
    self.rhLabel.text              = @"n/a";
    self.windLabel.text            = @"n/a";
    self.altitudeLabel.text        = @"n/a";
    self.densityAltitudeLabel.text = @"n/a";
    self.wxTimestampLabel.hidden   = NO;
    self.wxButton.enabled          = YES;
    self.wxButton.titleLabel.text  = @"⇣ WX";
}

@end
