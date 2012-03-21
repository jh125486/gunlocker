//
//  BallisticsViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weather.h"
#import "WhizWheelViewController.h"

@interface BallisticsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate> {
    NSMutableArray *arrayColors;
}

@property (weak, nonatomic) IBOutlet UIPickerView *ballisticProfilePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *dropDriftTableButton;
@property (weak, nonatomic) IBOutlet UIButton *dopeCardButton;
@property (weak, nonatomic) IBOutlet UIButton *whizWheelButton;
@property (weak, nonatomic) IBOutlet UIButton *getWeatherButton;
@property (weak, nonatomic) IBOutlet UILabel *densityAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rangeResultLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSTimer *locationTimer;

@property (strong, nonatomic) Weather *currentWeather;

@property (weak, nonatomic) NSString * passedRangeResult;
@property (weak, nonatomic) NSString *passedRangeResultUnits;


- (IBAction)getWeather:(id)sender;

- (IBAction)closeModalPopup:(id)sender;
@end
