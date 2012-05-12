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
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor colorWithRed:0.855 green:0.812 blue:0.682 alpha:1.000];
}  

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.dopeCardSectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(self.dopeCardSectionHeaderView.frame);
}

#pragma mark Actions
- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {
    // set up a new Weapon.DopeCard with all the info
    DopeCard *newDopeCard = [DopeCard createEntity];
    newDopeCard.weapon = trajectory.ballisticProfile.weapon;
    
    newDopeCard.name = self.profileNameLabel.text;
    newDopeCard.zero = [self.passedTrajectory.ballisticProfile.zero stringValue];
    newDopeCard.muzzle_velocity = [self.passedTrajectory.ballisticProfile.muzzle_velocity stringValue];
    newDopeCard.weather_info = [NSString stringWithFormat:@"%@ / RH %@ / %@ / %@", self.tempString, self.rhLabel.text, self.altitudeString, self.pressureString];
    newDopeCard.wind_info = self.windInfoLabel.text;
    newDopeCard.lead_info = self.leadInfoString;
    
    // set DopeCard.notes to trajectory autogenerated Date
    newDopeCard.notes = [NSString stringWithFormat:@"Generated on %@", [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                                      dateStyle:NSDateFormatterShortStyle 
                                                                                                      timeStyle:NSDateFormatterNoStyle]];
    
    newDopeCard.range_unit = self.rangeUnit;
    newDopeCard.drop_unit = newDopeCard.drift_unit = self.dropDriftUnit;

    NSMutableArray *dopeData = [[NSMutableArray alloc] initWithCapacity:trajectory.ranges.count];
    for (TrajectoryRange *range in trajectory.ranges) {
        [dopeData addObject:range.range_yards];
        [dopeData addObject:range.drop_inches];
        [dopeData addObject:range.drift_inches];
    }
    
    newDopeCard.dope_data = [NSArray arrayWithArray:dopeData];
    
    [[NSManagedObjectContext defaultContext] save];    
    NSLog(@"Saved dopecard %@ for %@", newDopeCard, newDopeCard.weapon);
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
