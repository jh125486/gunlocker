//
//  DopeTableGeneratedTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallisticProfile.h"
#import "Trajectory.h"
#import "TrajectoryRange.h"
#import "DopeTableGeneratedCell.h"
#import "DopeCard.h"

@interface DopeTableGeneratedTableViewController : UITableViewController <UIAlertViewDelegate> {
    Trajectory* trajectory;
}

@property (strong, nonatomic) Trajectory *passedTrajectory;
@property (strong, nonatomic) IBOutlet UIView *dopeCardSectionHeaderView;
@property (weak, nonatomic) NSString *rangeUnit;
@property (weak, nonatomic) NSString *tempString;
@property (weak, nonatomic) NSString *pressureString;
@property (weak, nonatomic) NSString *altitudeString;
@property (weak, nonatomic) NSString *dropDriftUnit;
@property (weak, nonatomic) NSString *windInfoString;
@property (weak, nonatomic) NSString *targetInfoString;

@property (weak, nonatomic) IBOutlet UILabel *rangeUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *driftUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *weaponLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *zeroLabel;
@property (weak, nonatomic) IBOutlet UILabel *mvLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *rhLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *windInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetInfoLabel;

- (IBAction)cancelTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;

@end
