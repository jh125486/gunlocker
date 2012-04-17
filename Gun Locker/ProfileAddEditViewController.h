//
//  ProfileAddEditViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallisticProfile.h"
#import "Bullet.h"

@interface ProfileAddEditViewController : UITableViewController <UITextFieldDelegate> {
    NSDecimalNumber *bullet_bc;
    NSNumber *bullet_weight;
    NSMutableArray *formFields;
}

@property (nonatomic, weak) Bullet *selectedBullet;
@property (weak, nonatomic) IBOutlet UILabel *bulletInfoLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dragModelControl;
@property (weak, nonatomic) IBOutlet UITextField *muzzleVelocityTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *muzzleVelocityUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *siteHeightTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *siteHeightUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *zeroDistanceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *zeroDistanceUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *temperatureTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *temperatureUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *pressureTextfield;
@property (weak, nonatomic) IBOutlet UISegmentedControl *pressureUnitControl;
@property (weak, nonatomic) IBOutlet UITextField *relativeHumidityTextField;
@property (weak, nonatomic) IBOutlet UITextField *altitudeTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *altitudeUnitControl;

@property (weak, nonatomic) UITextField *currentTextField;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@end
