//
//  WhizWheelViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallisticProfile.h"
#import "Trajectory.h"
#import "TrajectoryRange.h"
#import "AstronomicalCalendar.h"
#import "GeoLocation.h"

@interface WhizWheelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *arrayRanges;
    NSArray *arrayDirections;
    NSArray *arraySpeeds;
    Trajectory *trajectory;
    int rangeIndex;
    NSString *reticle;
    DataManager *dataManager;
    NSString *directionType;
    double angleDegrees;
    double speedMPH;
    NSTimer *modeTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *tableBackgroundImage;
@property (weak, nonatomic) IBOutlet UITableView *rangesTableView;
@property (weak, nonatomic) IBOutlet UITableView *directionsTableView;
@property (weak, nonatomic) IBOutlet UITableView *speedTableView;
@property (weak, nonatomic) IBOutlet UIImageView *resultBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *reticleImage;
@property (weak, nonatomic) IBOutlet UIImageView *reticlePOIImage;

@property (weak, nonatomic) UITableViewCell *lastSelectedRangeCell;
@property (weak, nonatomic) UITableViewCell *lastSelectedDirectionCell;
@property (weak, nonatomic) UITableViewCell *lastSelectedSpeedCell;

@property BOOL nightMode;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (weak, nonatomic) NSString *speedType;
@property (weak, nonatomic) NSString *speedUnit;
@property (weak, nonatomic) IBOutlet UILabel *dropInchesLabel;
@property (weak, nonatomic) IBOutlet UILabel *driftInchesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropMOAMils;
@property (weak, nonatomic) IBOutlet UILabel *driftMOAMils;
@property (weak, nonatomic) IBOutlet UILabel *dropUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *driftUnitLabel;

@property (nonatomic, weak) BallisticProfile *selectedProfile;
@end
