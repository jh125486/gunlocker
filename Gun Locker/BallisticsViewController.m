//
//  Ballistics2ViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BallisticsViewController.h"

@implementation BallisticsViewController
@synthesize addNewProfileButton = _addNewProfileButton;
@synthesize rangeLabel = _rangeLabel, rangeResult = _rangeResult, rangeResultUnits = _rangeResultUnits;
@synthesize tempLabel = _tempLabel, windLabel = _windLabel; 
@synthesize altitudeLabel = _altitudeLabel, densityAltitudeLabel = _densityAltitudeLabel, rhLabel = _rhLabel;
@synthesize wxButton = _wxButton, wxStationLabel = _wxStationLabel, wxIndicator = _wxIndicator, wxTimestampLabel = _wxTimestampLabel;
@synthesize chooseProfileButton = _chooseProfileButton, selectedProfileTextField = _selectedProfileTextField;
@synthesize selectedProfilePickerView = _selectedProfilePickerView;
@synthesize selectedProfileWeaponLabel = _selectedProfileWeaponLabel, selectedProfileNameLabel = _selectedProfileNameLabel;
@synthesize dopeCardsButton = _dopeCardsButton, whizWheelButton = _whizWheelButton;

@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize locationTimer = _locationTimer;
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
    
    self.title = @"Ballistics";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    
    _selectedProfilePickerView = [[UIPickerView alloc] init];
    _selectedProfilePickerView.delegate = self;
    [_selectedProfilePickerView setShowsSelectionIndicator:YES];
    _selectedProfileTextField.inputView = _selectedProfilePickerView;
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
    _selectedProfileTextField.inputAccessoryView = textFieldToolBarView;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    //    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 3000.0f;
    [_locationManager startUpdatingLocation];
    [_locationManager startMonitoringSignificantLocationChanges];
    _locationTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 
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
    
    [self setUpPickerData];
    [_selectedProfilePickerView reloadAllComponents];
    if ([profiles containsObject:selectedProfile]) {
        [_selectedProfilePickerView selectRow:[profiles indexOfObject:selectedProfile] inComponent:0 animated:NO];
        [self profileSelected:nil];
    } else {
        [self resetChooseProfileButton];
    }        
    
    _chooseProfileButton.enabled = (profiles.count != 0);
    
    _addNewProfileButton.enabled = ([Weapon countOfEntities] != 0);
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //crash for some reason
//    if (_currentWeather && _currentWeather.goodData) {
//        _wxTimestampLabel.text = [NSString stringWithFormat:@"Station reported weather %@", [[_currentWeather.timestamp distanceOfTimeInWords] lowercaseString]];
//    } else {
//        _wxTimestampLabel.text = @"";
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

- (void)setRange:(NSNotification*)notification {
    NSArray *passedRange = [notification object];
    _rangeResult = [passedRange objectAtIndex:0];
    _rangeResultUnits = [passedRange objectAtIndex:1];
    _rangeLabel.text = [NSString stringWithFormat:@"%.0f %@", [_rangeResult floatValue], _rangeResultUnits];
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
        [_selectedProfileTextField becomeFirstResponder];
    }
}

- (void)profileSelected:(id)sender {
    selectedProfile = [profiles objectAtIndex:[_selectedProfilePickerView selectedRowInComponent:0]];
    _selectedProfileWeaponLabel.text = [selectedProfile.weapon description];
    _selectedProfileNameLabel.text = selectedProfile.name;
    
    [_chooseProfileButton setTitle:@"" forState:UIControlStateNormal];
    [_chooseProfileButton setTitle:@"" forState:UIControlStateHighlighted];
    [_chooseProfileButton setTitle:@"" forState:UIControlStateSelected];
//    chooseProfileButton.titleLabel.textAlignment = UITextAlignmentCenter;
    _dopeCardsButton.enabled = YES;
    _whizWheelButton.enabled = YES;
    [_selectedProfileTextField resignFirstResponder];
}

-(void)resetChooseProfileButton {
    selectedProfile = nil;
    [_chooseProfileButton setTitle:@"Choose a Profile" forState:UIControlStateNormal];
    [_chooseProfileButton setTitle:@"Choose a Profile" forState:UIControlStateHighlighted];
    [_chooseProfileButton setTitle:@"Choose a Profile" forState:UIControlStateSelected];
    _selectedProfileWeaponLabel.text = @"";
    _selectedProfileNameLabel.text = @"";
    _dopeCardsButton.enabled = NO;
    _whizWheelButton.enabled = NO;
}

- (void)profileCancel:(id)sender {
    [_selectedProfileTextField resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"WhizWheel"]) {
        WhizWheelViewController *dst = segue.destinationViewController;
        dst.selectedProfile = selectedProfile;
    } else if ([segueID isEqualToString:@"DopeTable"]) {
        DopeTableTableViewController *dst = segue.destinationViewController;
        dst.currentWeather = _currentWeather;
        dst.selectedProfile = selectedProfile;
    } else if ([segueID isEqualToString:@"ShowProfile"]) {
        ProfileViewTableViewController *dst = segue.destinationViewController;
        dst.profile = selectedProfile;
    } else if ([segueID isEqualToString:@"AddProfile"]) {
        ProfileAddEditViewController *dst = [[segue.destinationViewController  viewControllers] objectAtIndex:0];
        dst.delegate = self;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
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
        _wxButton.enabled = _wxTimestampLabel.hidden = NO;
        _wxTimestampLabel.text = @"Location services disabled";
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
    _locationManager.delegate = nil;
    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingLocation]; 
    [_locationTimer invalidate]; 
}

#pragma mark - ProfileAddEditViewController delegate

-(void)profileAddEditViewController:(ProfileAddEditViewController *)controller didAddEditProfile:(BallisticProfile *)profile {
    selectedProfile = profile;
}


# pragma mark tableview header/footer

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != 0) return nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.tableView.sectionFooterHeight)];
    [view addSubview:_wxTimestampLabel];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == 0) ? 30.0f : 0.0f;
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
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
        view.backgroundColor = [UIColor clearColor];
        UIImageView *thumbNail = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 1.0f, 56.0f, 42.0f)];
        UILabel *firstLine  = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, 0.0f, 230.0f, 22.0f)];
        UILabel *secondLine = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, 22.0f, 230.0f, 22.0f)];
        
        firstLine.font  = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f];
        secondLine.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0f];
        firstLine.backgroundColor = secondLine.backgroundColor = [UIColor clearColor];
        firstLine.textColor = [UIColor blackColor];
        secondLine.textColor = [UIColor darkGrayColor];
        firstLine.adjustsFontSizeToFitWidth = YES;
        
        thumbNail.image = [UIImage imageWithData:profile.weapon.photo_thumbnail];
        firstLine.text  = profile.weapon.description;
        secondLine.text = profile.name;
        
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
            [_selectedProfileTextField becomeFirstResponder];
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
    _wxStationLabel.hidden = _wxTimestampLabel.hidden = YES;
    [_wxIndicator startAnimating];
    _wxButton.enabled = NO;

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

                _tempLabel.text = [NSString stringWithFormat:@"%.0fº F", TEMP_C_to_TEMP_F(_currentWeather.tempC)];
                _rhLabel.text   = [NSString stringWithFormat:@"%.0f%%", _currentWeather.relativeHumidity];
                _windLabel.text = [NSString stringWithFormat:@"%.0f knots from %@", _currentWeather.windSpeedKnots, 
                                                     [_currentWeather cardinalDirectionFromDegrees:_currentWeather.windDirectionDegrees]];
                _altitudeLabel.text = [NSString stringWithFormat:@"%.0f'%", METERS_to_FEET(_currentWeather.altitudeMeters)];
                _densityAltitudeLabel.text = [NSString stringWithFormat:@"%.0f'%", _currentWeather.densityAltitude];
                _wxStationLabel.text = [NSString stringWithFormat:@"%@ (%.0f km)", _currentWeather.stationID, _currentWeather.kmFromStation];
                _wxTimestampLabel.hidden = _wxStationLabel.hidden = NO;
                [_wxIndicator stopAnimating];
                _wxButton.enabled = YES;
                _wxTimestampLabel.text = [NSString stringWithFormat:@"Station reported weather %@", [[_currentWeather.timestamp distanceOfTimeInWords] lowercaseString]];

                _wxButton.titleLabel.text = @"↻ WX";

            } else { // errors with weather.aero
               NSLog(@"! Problem with METAR data from weather.aero: %@\n", metarArray);
                [self resetWX];
                _wxTimestampLabel.text = @"Error processing weather data: dataservice down";
           }
        } else {      // network errors       
            NSLog(@"! Error: %@", operation.error.localizedDescription);
            [self resetWX];
            _wxTimestampLabel.text = operation.error.localizedDescription;
        }
    };
    
    [operation start];
}

-(void)resetWX {
    _currentWeather = nil;
    
    [_wxIndicator stopAnimating];
    _tempLabel.text            = @"n/a";
    _rhLabel.text              = @"n/a";
    _windLabel.text            = @"n/a";
    _altitudeLabel.text        = @"n/a";
    _densityAltitudeLabel.text = @"n/a";
    _wxTimestampLabel.hidden   = NO;
    _wxButton.enabled          = YES;
    _wxButton.titleLabel.text  = @"⇣ WX";
}

@end
