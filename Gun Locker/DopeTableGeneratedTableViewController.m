//
//  DopeTableGeneratedTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeTableGeneratedTableViewController.h"

@implementation DopeTableGeneratedTableViewController
@synthesize passedTrajectory = _passedTrajectory;
@synthesize dopeCardSectionHeaderView = _dopeCardSectionHeaderView;
@synthesize rangeUnitLabel = _rangeUnitLabel, dropUnitLabel = _dropUnitLabel, driftUnitLabel = _driftUnitLabel;
@synthesize weaponLabel = _weaponLabel, profileNameLabel = _profileNameLabel;
@synthesize zeroLabel = _zeroLabel, mvLabel = _mvLabel;
@synthesize tempLabel = _tempLabel, rhLabel = _rhLabel, altitudeLabel = _altitudeLabel, pressureLabel = _pressureLabel;
@synthesize windInfoLabel = _windInfoLabel, targetInfoLabel = _targetInfoLabel;
@synthesize rangeUnit =_rangeUnit, dropDriftUnit = _dropDriftUnit;
@synthesize tempString = _tempString, altitudeString = _altitudeString, pressureString = _pressureString;
@synthesize windInfoString = _windInfoString, targetInfoString = _targetInfoString;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    trajectory = _passedTrajectory;

    _weaponLabel.text      = _passedTrajectory.ballisticProfile.weapon.model;
    _profileNameLabel.text = _passedTrajectory.ballisticProfile.name;    
    _rangeUnitLabel.text   = _rangeUnit;
    _dropUnitLabel.text    = _dropDriftUnit;
    _driftUnitLabel.text   = _dropDriftUnit;
    _zeroLabel.text        = [NSString stringWithFormat:@"%@ %@", [_passedTrajectory.ballisticProfile.zero stringValue], [_rangeUnit lowercaseString]];
    _mvLabel.text          = [NSString stringWithFormat:@"%@ fps", [_passedTrajectory.ballisticProfile.muzzle_velocity stringValue]];
    _tempLabel.text        = _tempString;
    _rhLabel.text          = [NSString stringWithFormat:@"%.0f%%", _passedTrajectory.relativeHumidity];
    _altitudeLabel.text    = _altitudeString;
    _pressureLabel.text    = _pressureString;
    _windInfoLabel.text    = _windInfoString;
    _targetInfoLabel.text  = _targetInfoString;
    
    [trajectory setup];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [trajectory calculateTrajectory];
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setRangeUnit:nil];
    [self setTempString:nil];
    [self setAltitudeString:nil];
    [self setPressureString:nil];
    [self setWindInfoString:nil];
    [self setTargetInfoString:nil];
    [self setDropDriftUnit:nil];
    [self setPassedTrajectory:nil];
    [self setZeroLabel:nil];
    [self setMvLabel:nil];
    [self setTempLabel:nil];
    [self setRhLabel:nil];
    [self setAltitudeLabel:nil];
    [self setPressureLabel:nil];
    [self setWindInfoLabel:nil];
    [self setTargetInfoLabel:nil];
    [self setWeaponLabel:nil];
    [self setWeaponLabel:nil];
    [self setProfileNameLabel:nil];
    [self setDopeCardSectionHeaderView:nil];
    [self setRangeUnitLabel:nil];
    [self setDropUnitLabel:nil];
    [self setDriftUnitLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [trajectory.ranges count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DopeTableGeneratedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DopeTableGeneratedCell"];
    
    TrajectoryRange *rangeDatum = [trajectory.ranges objectAtIndex:indexPath.row];

    cell.rangeLabel.text = [NSString stringWithFormat:@"%.0f", rangeDatum.range];
    
    if (_dropDriftUnit == @"Inches") {
        cell.dropLabel.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_inches];
        cell.driftLabel.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_inches];
    } else if (_dropDriftUnit == @"MOA") {
        cell.dropLabel.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_moa];
        cell.driftLabel.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_moa];
    } else if (_dropDriftUnit == @"Mils") {
        cell.dropLabel.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_mils];
        cell.driftLabel.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_mils];
    }
    
    cell.velocityLabel.text = [NSString stringWithFormat:@"%g", round(rangeDatum.velocity_fps)];
    cell.energyLabel.text   = [NSString stringWithFormat:@"%g", round(rangeDatum.energy_ftlbs)];
    cell.timeLabel.text     = [NSString stringWithFormat:@"%.3f", rangeDatum.time];
    
    if (rangeDatum.velocity_fps < 1116.45) {
        cell.backgroundView.alpha = 0.2f;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor colorWithRed:0.855 green:0.812 blue:0.682 alpha:1.000];
}  

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _dopeCardSectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(_dopeCardSectionHeaderView.frame);
}

#pragma mark Actions
- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {
    // set up a new Weapon.DopeCard with all the info
    DopeCard *newDopeCard = [DopeCard createEntity];
    newDopeCard.weapon = trajectory.ballisticProfile.weapon;
    
    newDopeCard.name = _profileNameLabel.text;

    newDopeCard.zero = [_passedTrajectory.ballisticProfile.zero stringValue];
    newDopeCard.zero_unit = _passedTrajectory.ballisticProfile.zero_unit;
    newDopeCard.muzzle_velocity = [_passedTrajectory.ballisticProfile.muzzle_velocity stringValue];
    newDopeCard.weather_info = [NSString stringWithFormat:@"%@ / RH %@ / %@ / %@", _tempString, _rhLabel.text, _altitudeString, _pressureString];
    newDopeCard.wind_info = _windInfoString;
    newDopeCard.lead_info = _targetInfoString;
    
    // set DopeCard.notes to trajectory autogenerated Date
    newDopeCard.notes = [NSString stringWithFormat:@"Generated on %@", [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                                      dateStyle:NSDateFormatterShortStyle 
                                                                                                      timeStyle:NSDateFormatterNoStyle]];
    
    newDopeCard.range_unit = _rangeUnit;
    newDopeCard.drop_unit = newDopeCard.drift_unit = _dropDriftUnit;

    NSMutableArray *dopeData = [[NSMutableArray alloc] initWithCapacity:trajectory.ranges.count];
    for (TrajectoryRange *rangeDatum in trajectory.ranges) {
        [dopeData addObject:[NSString stringWithFormat:@"%.0f", rangeDatum.range]];
        [dopeData addObject:[NSString stringWithFormat:@"%.1f", rangeDatum.drop_inches]];
        [dopeData addObject:[NSString stringWithFormat:@"%.1f", rangeDatum.drift_inches]];
    }
    
    [newDopeCard setDope_data:[NSArray arrayWithArray:dopeData]];
    
    [[NSManagedObjectContext defaultContext] save]; 
    NSString *message = [NSString stringWithFormat:@"Dope card for weapon\n'%@'\nsaved with name\n'%@'", newDopeCard.weapon, newDopeCard.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dope Card Saved" 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:@"Ok", nil];
    alert.delegate = self;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
}

@end
