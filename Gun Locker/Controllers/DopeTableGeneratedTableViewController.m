//
//  DopeTableGeneratedTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeTableGeneratedTableViewController.h"

@implementation DopeTableGeneratedTableViewController
@synthesize infoView = _infoView;
@synthesize passedTrajectory = _passedTrajectory;
@synthesize dopeCardSectionHeaderView = _dopeCardSectionHeaderView;
@synthesize rangeUnitLabel = _rangeUnitLabel, dropUnitLabel = _dropUnitLabel, driftUnitLabel = _driftUnitLabel;
@synthesize weaponLabel = _weaponLabel, profileNameLabel = _profileNameLabel;
@synthesize zeroLabel = _zeroLabel, mvLabel = _mvLabel;
@synthesize tempLabel = _tempLabel, rhLabel = _rhLabel, altitudeLabel = _altitudeLabel, pressureLabel = _pressureLabel;
@synthesize windInfoLabel = _windInfoLabel, targetInfoLabel = _targetInfoLabel;
@synthesize rangeUnit =_rangeUnit, dopeUnit = _dropDriftUnit;
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
    
    elevation_click = [[_passedTrajectory.ballisticProfile.elevation_click decimalFromFraction] doubleValue];
    windage_click   = [[_passedTrajectory.ballisticProfile.windage_click decimalFromFraction] doubleValue];
    
    [trajectory setup];
    [trajectory setupWindAndLeading];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [trajectory calculateTrajectory];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _weaponLabel.font = [UIFont boldSystemFontOfSize:20.f];    
        _profileNameLabel.font = [UIFont boldSystemFontOfSize:18.f];
    } else {
        _weaponLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _profileNameLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {    
    [self.tableView setContentOffset:CGPointMake(0.f, _infoView.isHidden ? CGRectGetHeight(_infoView.frame) : 0.f) animated:YES];
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
    
    if ([_dropDriftUnit isEqual: @"Inches"]) {
        cell.dropLabel.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_inches];
        cell.driftLabel.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_inches];
    } else if ([_dropDriftUnit isEqualToString:@"MOA"]) {
        cell.dropLabel.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_moa];
        cell.driftLabel.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_moa];
    } else if ([_dropDriftUnit isEqualToString:@"Mils"]) {
        cell.dropLabel.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_mils];
        cell.driftLabel.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_mils];
    } else if ([_dropDriftUnit isEqualToString:@"Clicks"]) {
        if ([_passedTrajectory.ballisticProfile.scope_click_unit isEqualToString:@"MILs"]) {
            cell.dropLabel.text  = [NSString stringWithFormat:@"%g", round(rangeDatum.drop_mils / elevation_click)];
            cell.driftLabel.text = [NSString stringWithFormat:@"%g", round(rangeDatum.drift_mils / windage_click)];
        } else { //MOA
            cell.dropLabel.text  = [NSString stringWithFormat:@"%g", round(rangeDatum.drop_moa / elevation_click)];
            cell.driftLabel.text = [NSString stringWithFormat:@"%g", round(rangeDatum.drift_moa / windage_click)];            
        }
    }
    
    cell.velocityLabel.text = [NSString stringWithFormat:@"%g", round(rangeDatum.velocity_fps)];
    cell.energyLabel.text   = [NSString stringWithFormat:@"%g", round(rangeDatum.energy_ftlbs)];
    cell.timeLabel.text     = [NSString stringWithFormat:@"%.3f", rangeDatum.time];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(DopeTableGeneratedCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
//    if ([cell.velocityLabel.text floatValue] < 1116.45) { // XXX should be Speed of Sound
//                                             // XXX highlight row if below speed of sound
//                                             //        tableView.opaque = NO;
//                                             //        tableView.backgroundColor = [UIColor clearColor];
//                                             //        tableView.backgroundView = nil;
//        cell.backgroundView.alpha = 1.f;
//        cell.backgroundColor = UIColorFromString(@"FF0000");
//    }
    
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
        
    newDopeCard.weather_info = [NSString stringWithFormat:@"%@ / RH %@ / %@ / %@", _tempLabel.text, _rhLabel.text, _altitudeLabel.text, _pressureLabel.text];
    
    newDopeCard.wind_info = _windInfoLabel.text;
    newDopeCard.lead_info = _targetInfoLabel.text;
    
    // set DopeCard.notes to trajectory autogenerated Date
    newDopeCard.notes = [NSString stringWithFormat:@"Generated on %@", [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                                      dateStyle:NSDateFormatterShortStyle 
                                                                                                      timeStyle:NSDateFormatterNoStyle]];
    
    newDopeCard.range_unit = _rangeUnit;
    newDopeCard.drop_unit = newDopeCard.drift_unit = _dropDriftUnit;

    NSMutableArray *dopeData = [[NSMutableArray alloc] initWithCapacity:[self.tableView numberOfRowsInSection:0]];
    
    for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row++) {
        TrajectoryRange *rangeDatum = [trajectory.ranges objectAtIndex:row];
        NSString *dropText, *driftText;
         
        if ([_dropDriftUnit isEqual: @"Inches"]) {
            dropText  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_inches];
            driftText = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_inches];
        } else if ([_dropDriftUnit isEqualToString:@"MOA"]) {
            dropText  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_moa];
            driftText = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_moa];
        } else if ([_dropDriftUnit isEqualToString:@"Mils"]) {
            dropText  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_mils];
            driftText = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_mils];
        } else if ([_dropDriftUnit isEqualToString:@"Clicks"]) {
            if ([_passedTrajectory.ballisticProfile.scope_click_unit isEqualToString:@"MILs"]) {
                dropText  = [NSString stringWithFormat:@"%g", round(rangeDatum.drop_mils / elevation_click)];
                driftText = [NSString stringWithFormat:@"%g", round(rangeDatum.drift_mils / windage_click)];
            } else { //MOA
                dropText  = [NSString stringWithFormat:@"%g", round(rangeDatum.drop_moa / elevation_click)];
                driftText = [NSString stringWithFormat:@"%g", round(rangeDatum.drift_moa / windage_click)];
            }
        }
        
        [dopeData addObject: [NSString stringWithFormat:@"%.0f", rangeDatum.range]];
        [dopeData addObject:dropText];
        [dopeData addObject:driftText];
    }
        
    [newDopeCard setDope_data:[NSArray arrayWithArray:dopeData]];
    
    [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"DopeCards%@", newDopeCard.weapon]];
    [[DataManager sharedManager] saveAppDatabase];
    NSString *message = [NSString stringWithFormat:@"Dope card for weapon\n'%@'\nsaved with name\n'%@'", newDopeCard.weapon, newDopeCard.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dope Card Saved" 
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:@"Ok", nil];
    alert.delegate = self;
    [alert show];
}

- (IBAction)infoViewTapped:(id)sender {
    CGFloat offset = self.tableView.contentOffset.y == CGRectGetHeight(_infoView.frame) ? 0.f : CGRectGetHeight(_infoView.frame);
    [self.tableView setContentOffset:CGPointMake(0.f, offset) animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissModalViewControllerAnimated:YES];
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//}
//
//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView reloadData];
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)theIndexPath {
//    for (NSIndexPath *indexPath in [tableView indexPathsForSelectedRows]) {
//        if ((indexPath.row == theIndexPath.row) && (indexPath.section == theIndexPath.section)) {
//            return tableView.rowHeight + 10.f;
//        }
//    }
//    return  tableView.rowHeight;
//}

@end
