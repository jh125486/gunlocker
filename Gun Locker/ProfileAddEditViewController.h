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
#import "BulletChooserViewController.h"
#import "BulletEntryManualViewController.h"

@interface ProfileAddEditViewController : UITableViewController <UITextFieldDelegate> {
    NSArray *manually_entered_bc;
    NSNumber *bullet_weight;
    NSString *drag_model;
    NSMutableArray *formFields;
}

@property (nonatomic, weak) BallisticProfile *selectedProfile;
@property (nonatomic, strong) Bullet *selectedBullet;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *bulletTypePromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletWeightPromptLabel;
@property (weak, nonatomic) IBOutlet UILabel *bulletWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *dragModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *bcLabel;
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

- (IBAction)bulletControlTapped:(UISegmentedControl *)sender;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
@end
