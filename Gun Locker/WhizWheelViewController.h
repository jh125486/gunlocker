//
//  WhizWheelViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhizWheelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *arrayRanges;
    NSMutableArray *arrayDirections;
    NSMutableArray *arraySpeeds;
}

@property (weak, nonatomic) IBOutlet UIImageView *tableBackgroundImage;
@property (weak, nonatomic) IBOutlet UITableView *rangesTableView;
@property (weak, nonatomic) IBOutlet UITableView *directionsTableView;
@property (weak, nonatomic) IBOutlet UITableView *speedTableView;
@property (weak, nonatomic) IBOutlet UIImageView *resultBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *resultReticleView;
@property (weak, nonatomic) IBOutlet UIImageView *resultBulletImpactImage;

@property (weak, nonatomic) UITableViewCell *lastSelectedRangeCell;
@property (weak, nonatomic) UITableViewCell *lastSelectedDirectionCell;
@property (weak, nonatomic) UITableViewCell *lastSelectedSpeedCell;

@property BOOL nightMode;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *directionLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropLabel;
@property (weak, nonatomic) IBOutlet UILabel *driftLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *driftResultLabel;
@property (weak, nonatomic) NSString *speedType;
@property (weak, nonatomic) NSString *speedUnit;

@property (strong, nonatomic) NSObject *selectedProfile;
@end
