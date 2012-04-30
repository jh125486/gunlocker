//
//  DopeTableGeneratedTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeTableGeneratedTableViewController.h"

@implementation DopeTableGeneratedTableViewController
@synthesize passedTrajectory;
@synthesize dopeCardSectionHeaderView;
@synthesize rangeUnitLabel, dropUnitLabel, driftUnitLabel;
@synthesize weaponLabel, profileNameLabel;
@synthesize zeroLabel, mvLabel, tempLabel, rhLabel, altitudeLabel, pressureLabel, windInfoLabel, targetInfoLabel;
@synthesize rangeUnit, dropDriftUnit, tempString, altitudeString, pressureString, windInfoString, leadInfoString;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    trajectory = self.passedTrajectory;

    self.weaponLabel.text      = self.passedTrajectory.ballisticProfile.weapon.model;
    self.profileNameLabel.text = self.passedTrajectory.ballisticProfile.name;    
    self.rangeUnitLabel.text = self.rangeUnit;
    self.dropUnitLabel.text = self.dropDriftUnit;
    self.driftUnitLabel.text = self.dropDriftUnit;
    self.zeroLabel.text = [NSString stringWithFormat:@"%@ %@", [self.passedTrajectory.ballisticProfile.zero stringValue], [self.rangeUnit lowercaseString]];
    self.mvLabel.text = [NSString stringWithFormat:@"%@ fps", [self.passedTrajectory.ballisticProfile.muzzle_velocity stringValue]];
    self.tempLabel.text = self.tempString;
    self.rhLabel.text = [NSString stringWithFormat:@"%.0f%%", self.passedTrajectory.relativeHumidity];
    self.altitudeLabel.text = self.altitudeString;
    self.pressureLabel.text = self.pressureString;
    self.windInfoLabel.text = self.windInfoString;
    self.targetInfoLabel.text = self.leadInfoString;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [trajectory calculateTrajectory];
}

- (void)viewDidUnload {
    [self setRangeUnit:nil];
    [self setTempString:nil];
    [self setAltitudeString:nil];
    [self setPressureString:nil];
    [self setWindInfoString:nil];
    [self setLeadInfoString:nil];
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
    
    TrajectoryRange *range = [trajectory.ranges objectAtIndex:indexPath.row];

    // figure out which units to show on Range/Drop/Drift
    cell.rangeLabel.text    = range.range_yards;
    cell.dropLabel.text     = range.drop_inches;
    cell.driftLabel.text    = range.drift_inches;
    cell.velocityLabel.text = range.velocity_fps;
    cell.energyLabel.text   = range.energy_ftlbs;
    cell.timeLabel.text     = range.time;

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor lightTextColor];
}  

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.dopeCardSectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(self.dopeCardSectionHeaderView.frame);
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {
    // set up a new Weapon.DopeCard with all the info
    DopeCard *newDopeCard = [DopeCard createEntity];
    newDopeCard.weapon = trajectory.ballisticProfile.weapon;
    
    newDopeCard.name = trajectory.ballisticProfile.name;
    newDopeCard.zero = self.zeroLabel.text;
    newDopeCard.wind_info = self.windInfoLabel.text;
    newDopeCard.range_unit = self.rangeUnit;
    newDopeCard.drop_unit = newDopeCard.drift_unit = self.dropDriftUnit;
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:trajectory.ranges.count];
    
    for (TrajectoryRange *range in trajectory.ranges) {
        [data addObject:range.range_yards];
        [data addObject:range.drop_inches];
        [data addObject:range.drift_inches];
    }
    
    newDopeCard.dope_data = data;
    
    // set DopeCard.notes to read autogenerated Date
    newDopeCard.notes = [NSString stringWithFormat:@"Generated on %@", [NSDate date]];
    if (passedTrajectory.leadSpeed > 0) newDopeCard.notes = [self.leadInfoString stringByAppendingFormat:@"%@", newDopeCard.notes];
    
    [[NSManagedObjectContext defaultContext] save];    
    NSLog(@"Saved dopecard %@ for %@", newDopeCard, newDopeCard.weapon);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dope Card Saved" 
                                                    message:[NSString stringWithFormat:@"Dope card for %@ saved with title %@", newDopeCard.weapon, newDopeCard.name]
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