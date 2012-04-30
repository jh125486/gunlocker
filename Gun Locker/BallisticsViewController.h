//
//  Ballistics2ViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallisticProfile.h"
#import "Trajectory.h"
#import "Weather.h"
#import "Weapon.h"
#import "WhizWheelViewController.h"
#import "DopeTableTableViewController.h"

@interface BallisticsViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, UIActionSheetDelegate> {
    NSMutableArray *profiles;
    BallisticProfile *selectedProfile;
}


@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (weak, nonatomic) IBOutlet UIButton *wxButton;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *rhLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *densityAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *wxStationLabel;
@property (strong, nonatomic) IBOutlet UILabel *wxTimestampLabel;

@property (weak, nonatomic) IBOutlet UIButton *chooseProfileButton;

@property (weak, nonatomic) IBOutlet UILabel *selectedProfileWeaponLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedProfileNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *selectedProfileTextField;
@property (strong, nonatomic) UIPickerView *selectedProfilePickerView;

@property (weak, nonatomic) IBOutlet UIButton *dopeCardsButton;
@property (weak, nonatomic) IBOutlet UIButton *whizWheelButton;

@property (weak, nonatomic) IBOutlet UIButton *addNewProfileButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSTimer *locationTimer;

@property (strong, nonatomic) Weather *currentWeather;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *wxIndicator;

@property (weak, nonatomic) NSNumber *rangeResult;
@property (weak, nonatomic) NSString *rangeResultUnits;

- (IBAction)getWX:(id)sender;
- (IBAction)chooseProfileTapped:(id)sender;

@end
