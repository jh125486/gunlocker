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

@synthesize passedRangeResult, passedRangeResultUnits;

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
}

-(void)viewWillAppear:(BOOL)animated {
    if(self.passedRangeResult)
        self.rangeResultLabel.text = [NSString stringWithFormat:@"%@ %@", self.passedRangeResult, self.passedRangeResultUnits];
    
}

- (void)viewDidUnload
{
    [self setBallisticProfilePicker:nil];
    [self setEditProfileButton:nil];
    [self setDropDriftTableButton:nil];
    [self setDopeCardButton:nil];
    [self setWhizWheelButton:nil];
    [self setDensityAltitudeLabel:nil];
    [self setRangeResultLabel:nil];
    [self setGetWeatherButton:nil];
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self stopUpdatingLocations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrayColors count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [arrayColors objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
}

- (IBAction)getWeather:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        self.currentWeather = [[Weather alloc] initWithLocation:currentLocation];        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self logWeather];
        });
    });
}

- (IBAction)closeModalPopup:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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

- (void)logWeather {
    if(self.currentWeather.goodData) {
        NSLog(@"%@", [self.currentWeather description]);
        self.densityAltitudeLabel.text = [NSString stringWithFormat:@"%.0f ft%", self.currentWeather.densityAltitude];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"WhizWheel"]) {
        WhizWheelViewController *dst = segue.destinationViewController;
        dst.selectedProfile = [arrayColors objectAtIndex:[self.ballisticProfilePicker selectedRowInComponent:0]];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Profiles" style:UIBarButtonItemStyleBordered target:nil action:nil];

    }
}

@end
