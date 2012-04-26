//
//  BallisticsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BallisticsViewController.h"

@implementation BallisticsViewController

@synthesize ballisticProfilePicker;
@synthesize editProfileButton;
@synthesize dropDriftTableButton;
@synthesize dopeCardButton;
@synthesize whizWheelButton;
@synthesize getWeatherButton;
@synthesize densityAltitudeLabel;
@synthesize rangeResultLabel;

@synthesize locationManager, currentLocation, locationTimer;
@synthesize currentWeather;
@synthesize weatherIndicator;

@synthesize rangeResult, rangeResultUnits;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrayColors = [[NSMutableArray alloc] init];
    [arrayColors addObject:@"Red"];
    [arrayColors addObject:@"Orange"];
    [arrayColors addObject:@"Yellow"];
    [arrayColors addObject:@"Green"];
    [arrayColors addObject:@"Blue"];
    [arrayColors addObject:@"Indigo"];
    [arrayColors addObject:@"Violet"];
    

    
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

-(void)viewDidAppear:(BOOL)animated {
    //wait for weather to update
    
    // TESTING Trajectory
    BallisticProfile *bc = [BallisticProfile findFirst];
    if (bc == Nil) bc = [BallisticProfile createEntity];
    
    bc.bullet_weight = [NSNumber numberWithInt:55.0];
    bc.drag_model = @"G7";
    bc.muzzle_velocity = [NSNumber numberWithInt:3240];
    bc.zero = [NSNumber numberWithInt:100];
    bc.sight_height_inches = [NSNumber numberWithDouble:1.5];
    bc.name = @"M16";
    bc.bullet_bc = [NSArray arrayWithObject:[NSDecimalNumber decimalNumberWithString:@"0.272"]];
    bc.bullet_diameter_inches = [NSDecimalNumber decimalNumberWithString:@"0.224"];                 
    
    Trajectory *trajectory = [Trajectory createEntity];
    trajectory.range_min = [NSNumber numberWithInt:100];
    trajectory.range_max = [NSNumber numberWithInt:1000];
    trajectory.range_increment = [NSNumber numberWithInt:100];
    trajectory.relative_humidity = [NSNumber numberWithDouble:0.0];
    trajectory.pressure_inhg = [NSNumber numberWithDouble:29.92];
    trajectory.temp_c = [NSNumber numberWithDouble:15];
    [bc addTrajectoriesObject:trajectory];
    
    [trajectory calculateTrajectory];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setBallisticProfilePicker:nil];
    [self setEditProfileButton:nil];
    [self setDropDriftTableButton:nil];
    [self setDopeCardButton:nil];
    [self setWhizWheelButton:nil];
    [self setDensityAltitudeLabel:nil];
    [self setRangeResultLabel:nil];
    [self setGetWeatherButton:nil];
    [self setWeatherIndicator:nil];
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self stopUpdatingLocations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)getWeather:(id)sender {
    self.densityAltitudeLabel.hidden = YES;
    [weatherIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.currentWeather = [[Weather alloc] initWithLocation:currentLocation];        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(self.currentWeather.goodData) {
                NSLog(@"%@", [self.currentWeather description]);
                self.densityAltitudeLabel.text = [NSString stringWithFormat:@"%.0f ft%", self.currentWeather.densityAltitude];
                [weatherIndicator stopAnimating];
                self.densityAltitudeLabel.hidden = NO;
            }
        });
    });
}

- (IBAction)closeModalPopup:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setRange:(NSNotification*)notification {
    NSArray *passedRange = [notification object];
    rangeResult = [passedRange objectAtIndex:0];
    rangeResultUnits = [passedRange objectAtIndex:1];
    self.rangeResultLabel.text = [NSString stringWithFormat:@"%.0f %@", [rangeResult floatValue], rangeResultUnits];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"WhizWheel"]) {
        WhizWheelViewController *dst = segue.destinationViewController;
        dst.selectedProfile = [arrayColors objectAtIndex:[self.ballisticProfilePicker selectedRowInComponent:0]];
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Profiles" style:UIBarButtonItemStyleBordered target:nil action:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;

    if(newLocation.horizontalAccuracy <= 100.0f)
        [self stopUpdatingLocations];
    [self getWeather:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if(error.code == kCLErrorDenied) {
        [self stopUpdatingLocations];
        self.getWeatherButton.hidden = TRUE;
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

#pragma mark PickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [arrayColors count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arrayColors objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
}

@end
