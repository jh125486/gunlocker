//
//  WhizWheelViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define CIRCULAR_TABLE_SIZE 1000
#define PIXELS_PER_MIL 10
#define PIXELS_PER_MOA 2
#import "WhizWheelViewController.h"

@implementation WhizWheelViewController
@synthesize tableBackgroundImage = _tableBackgroundImage;
@synthesize rangesTableView = _rangesTableView, directionsTableView = _directionsTableView, speedTableView = _speedTableView;
@synthesize rangeLabel = _rangeLabel, directionLabel = _directionLabel, speedLabel = _speedLabel;
@synthesize dropInchesLabel = _dropInchesLabel, dropMOAMils = _dropMOAMils;
@synthesize driftInchesLabel = _driftInchesLabel, driftMOAMils = _driftMOAMils;
@synthesize dropUnitLabel = _dropUnitLabel, driftUnitLabel = _driftUnitLabel;
@synthesize selectedProfile = _selectedProfile;
@synthesize lastSelectedRangeCell = _lastSelectedRangeCell;
@synthesize lastSelectedDirectionCell = _lastSelectedDirectionCell;
@synthesize lastSelectedSpeedCell = _lastSelectedSpeedCell;
@synthesize resultBackgroundView = _resultBackgroundView;
@synthesize reticleImage = _reticleImage;
@synthesize reticlePOIImage = _reticlePOIImage;
@synthesize nightMode = _nightMode;
@synthesize speedUnit = _speedUnit, speedType = _speedType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.selectedProfile.name;
    trajectory = [[Trajectory alloc] init];
    dataManager = [DataManager sharedManager];
}

-(void)viewWillAppear:(BOOL)animated {    
    [super viewWillAppear:animated];

    // set to initial picker positions
    rangeIndex = 0;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    reticle = [defaults boolForKey:@"reticleUnitsControl"] ? @"MOA" : @"MilDot";
    
    // do all conversions for UnitControls
    trajectory.rangeUnit  = [defaults integerForKey:@"rangeUnitsControl"];
    trajectory.rangeStart = [defaults integerForKey:@"rangeStart"];
    trajectory.rangeEnd   =  [defaults integerForKey:@"rangeEnd"];
    trajectory.rangeStep  = [defaults integerForKey:@"rangeStep"];
    trajectory.tempC = 15;
    trajectory.relativeHumidity = 0;
    trajectory.pressureInhg = 29.92;
    trajectory.altitudeM = 0;
    trajectory.ballisticProfile = _selectedProfile;
    _rangeLabel.text = (trajectory.rangeUnit == 0) ? @"Yards" : @"Meters";
    
    // array of Ranges:  pad front and back to get proper fake pickerview row alignment from real tableview
    arrayRanges = [[NSMutableArray alloc] initWithObjects:@"", @"", nil];
    for(int range = trajectory.rangeStart; range <= trajectory.rangeEnd; range += trajectory.rangeStep)
        [arrayRanges addObject:[NSString stringWithFormat:@"%d", range]];
    [arrayRanges addObject:@""];
    [arrayRanges addObject:@""];
    
    
    _directionLabel.text = [dataManager.directionTypes objectAtIndex:[defaults integerForKey:@"directionControl"]];
    arrayDirections = [dataManager.whizWheelPicker2 objectForKey:_directionLabel.text];
    
    _speedUnit = [defaults objectForKey:@"speedUnit"]; // should have another label to differentiate between leading and windage
    _speedType = [defaults objectForKey:@"speedType"];
    _speedLabel.text = _speedType;
    arraySpeeds = [dataManager.whizWheelPicker3 objectForKey:_speedUnit];
        
    [_rangesTableView reloadData];
    [_directionsTableView reloadData];
    [_speedTableView reloadData];
    
    _nightMode = [[defaults objectForKey:@"nightModeControl"] intValue];
    
    if (_nightMode) {
        _rangesTableView.backgroundColor = _directionsTableView.backgroundColor = _speedTableView.backgroundColor = _resultBackgroundView.backgroundColor = [UIColor blackColor];
        _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_night", reticle]];
        for (UILabel *label in self.view.subviews){
            if ([label isKindOfClass:[UILabel class]])
                label.textColor = _tableBackgroundImage.backgroundColor = [UIColor colorWithRed:0.603 green:0.000 blue:0.000 alpha:1.000];
        }
        _rangeLabel.textColor = _directionLabel.textColor = _speedLabel.textColor = [UIColor lightGrayColor];
    } else { // NON night mode
        _rangesTableView.backgroundColor = _directionsTableView.backgroundColor = _speedTableView.backgroundColor = _resultBackgroundView.backgroundColor = [UIColor whiteColor];
        _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_day", reticle]];
        for (UILabel *label in self.view.subviews) {
            if ([label isKindOfClass:[UILabel class]])
                label.textColor = [UIColor blackColor];
        }
        _rangeLabel.textColor = _directionLabel.textColor = _speedLabel.textColor = [UIColor whiteColor];
        _tableBackgroundImage.backgroundColor = [UIColor lightGrayColor];
    }
    
    [self setInitialSelectedCells];
    [self highlightSelectedCells];
    [self showTrajectoryWithRecalc:YES];
}

- (void)viewDidUnload {
    [self setRangesTableView:nil];
    [self setRangeLabel:nil];
    [self setSelectedProfile:nil];
    [self setLastSelectedRangeCell:nil];
    [self setDirectionsTableView:nil];
    [self setSpeedTableView:nil];
    [self setSpeedLabel:nil];
    [self setDirectionLabel:nil];
    [self setResultBackgroundView:nil];
    [self setReticleImage:nil];
    [self setTableBackgroundImage:nil];
    [self setReticlePOIImage:nil];
    [self setSpeedType:nil];
    [self setSpeedUnit:nil];
    [self setDropInchesLabel:nil];
    [self setDriftInchesLabel:nil];
    [self setDropMOAMils:nil];
    [self setDriftMOAMils:nil];
    [self setDropUnitLabel:nil];
    [self setDriftUnitLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _rangesTableView) {
        return [arrayRanges count];
    } else if (tableView == _directionsTableView) {
        return [arrayDirections count] * CIRCULAR_TABLE_SIZE;
    } else if (tableView == _speedTableView) {
        return [arraySpeeds count] * CIRCULAR_TABLE_SIZE;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    
    if (tableView == _rangesTableView) {
        cellIdentifier = @"RangeCell";
    } else if (tableView == _directionsTableView) {
        cellIdentifier = @"DirectionCell";
    } else if (tableView == _speedTableView) {
        cellIdentifier = @"SpeedCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    cell.backgroundColor = self.nightMode ? [UIColor blackColor] : [UIColor whiteColor];
    cell.textLabel.textColor = self.nightMode ? [UIColor redColor] : [UIColor blackColor];
    cell.textLabel.textAlignment = UITextAlignmentRight;

    NSString *cellText;
    if (tableView == _rangesTableView) {
        cellText = [arrayRanges objectAtIndex:indexPath.row];
    } else if (tableView == _directionsTableView) {
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cellText = [arrayDirections objectAtIndex:indexPath.row % [arrayDirections count]];
    } else if (tableView == _speedTableView) {
        cellText = [arraySpeeds objectAtIndex:indexPath.row % [arraySpeeds count]];
        if (![_speedUnit isEqualToString:@"Human"]) cellText = [cellText stringByAppendingString:_speedUnit];
    }
    
    cell.textLabel.text = cellText;
    
    return cell;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *index;
    if(scrollView == _rangesTableView) {
        index = [_rangesTableView indexPathForRowAtPoint:CGPointMake([_rangesTableView contentOffset].x, 
                                                                     100 + [_rangesTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [_rangesTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedRangeCell =  [_rangesTableView cellForRowAtIndexPath:index];
        rangeIndex = index.row - 2;
        [self showTrajectoryWithRecalc:NO];
    } else if (scrollView == _directionsTableView) {
        index = [_directionsTableView indexPathForRowAtPoint:CGPointMake([_directionsTableView contentOffset].x, 
                                                                         100 + [_directionsTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [_directionsTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedDirectionCell =  [_directionsTableView cellForRowAtIndexPath:index];
        [self showTrajectoryWithRecalc:YES];
    } else if (scrollView == _speedTableView) {
        index = [_speedTableView indexPathForRowAtPoint:CGPointMake([_speedTableView contentOffset].x, 
                                                                    100 + [_speedTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [_speedTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedSpeedCell =  [_speedTableView cellForRowAtIndexPath:index];
        [self showTrajectoryWithRecalc:YES];
    }

    [self highlightSelectedCells];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.nightMode) {
        if(scrollView == _rangesTableView) {
            _lastSelectedRangeCell.textLabel.textColor = [UIColor redColor];
        } else if (scrollView == _directionsTableView) {
            _lastSelectedDirectionCell.textLabel.textColor = [UIColor redColor];
        } else if (scrollView == _speedTableView) {
            _lastSelectedSpeedCell.textLabel.textColor = [UIColor redColor];
        }
    }
}


#pragma mark Actions
-(void)highlightSelectedCells { //  highlight cells under the selector if night mode
    if(_nightMode) {
        _lastSelectedRangeCell.textLabel.textColor = [UIColor whiteColor];
        _lastSelectedDirectionCell.textLabel.textColor = [UIColor whiteColor];
        _lastSelectedSpeedCell.textLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setInitialSelectedCells {
    // scroll direction and speed to middle to simulate a circular picker
    NSIndexPath *initialRange = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *initialDirection = [NSIndexPath indexPathForRow:([arrayDirections count]*CIRCULAR_TABLE_SIZE/2) inSection:0];
    NSIndexPath *initialSpeed = [NSIndexPath indexPathForRow:([arraySpeeds count]*CIRCULAR_TABLE_SIZE/2) inSection:0];
    
    [_rangesTableView scrollToRowAtIndexPath:initialRange atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    _lastSelectedRangeCell = [_rangesTableView cellForRowAtIndexPath:initialRange];
    [_directionsTableView scrollToRowAtIndexPath:initialDirection atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    _lastSelectedDirectionCell = [_directionsTableView cellForRowAtIndexPath:initialDirection];
    [_speedTableView scrollToRowAtIndexPath:initialSpeed atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    _lastSelectedSpeedCell = [_speedTableView cellForRowAtIndexPath:initialSpeed];
}

- (void)showTrajectoryWithRecalc:(BOOL)recalc {
    if(recalc) {
        // convert direction 
        if ([_directionLabel.text isEqualToString:@"Clocking"]) {
            angleDegrees =  CLOCK_to_DEGREES([_lastSelectedDirectionCell.textLabel.text intValue]);
        } else { // degrees
            angleDegrees = [_lastSelectedDirectionCell.textLabel.text intValue];
        }

        // convert speed units
        if ([_speedUnit isEqualToString:@"Human"]) {
            speedMPH = [[dataManager.humanMPHSpeeds objectForKey:_lastSelectedSpeedCell.textLabel.text] doubleValue]; 
        } else if ([_speedUnit isEqualToString:@"Knots"]) {
            speedMPH = KNOTS_to_MPH([_lastSelectedSpeedCell.textLabel.text doubleValue]);
        } else if ([_speedUnit isEqualToString:@"m/s"]) {
            speedMPH = MPS_to_MPH([_lastSelectedSpeedCell.textLabel.text doubleValue]);
        } else if ([_speedUnit isEqualToString:@"km/h"]) {
            speedMPH = KPH_to_MPH([_lastSelectedSpeedCell.textLabel.text doubleValue]);
        } else { // MPH
            speedMPH = [_lastSelectedSpeedCell.textLabel.text doubleValue];
        }
    
        // set up wind/leading speed/direction
        if ([_speedType isEqualToString:@"Wind"]) {
            trajectory.windAngle = angleDegrees;
            trajectory.windSpeed = speedMPH;
            trajectory.targetSpeed = 0.0;
        } else { // Leading Target
            trajectory.targetAngle = angleDegrees;
            trajectory.targetSpeed = speedMPH;
            trajectory.windSpeed = 0.0;
        }
        
        [trajectory setupWindAndLeading];
        [trajectory calculateTrajectory];
        NSLog(@"Whiz Wheel: Recalculated Wind/Leading %.1f mph at %.1f degrees", speedMPH, angleDegrees);
    }
        
    TrajectoryRange *range = [trajectory.ranges objectAtIndex:rangeIndex];
    
    NSLog(@"row %d\trange: %g\tdrop: %g\"\tdrift: %g\"", rangeIndex, range.range, range.drop_inches, range.drift_inches);
    
    _dropInchesLabel.text  = [NSString stringWithFormat:@"%.1f", range.drop_inches];
    _driftInchesLabel.text = [NSString stringWithFormat:@"%.1f", range.drift_inches];

    if ([reticle isEqualToString:@"MOA"]) {
        _reticlePOIImage.center = CGPointMake(160.f + range.drift_moa * PIXELS_PER_MOA +0.25f, 
                                              74.f - range.drop_moa * PIXELS_PER_MOA +0.25f);
        _dropMOAMils.text  = [NSString stringWithFormat:@"%.1f", range.drop_moa];
        _driftMOAMils.text = [NSString stringWithFormat:@"%.1f", range.drift_moa];
        _dropUnitLabel.text = _driftUnitLabel.text = @"MOA";
    } else { // MILs
        _reticlePOIImage.center = CGPointMake(160.f + range.drift_mils * PIXELS_PER_MIL +0.25f, 
                                              74.f - range.drop_mils * PIXELS_PER_MIL +0.25f);        
        _dropMOAMils.text  = [NSString stringWithFormat:@"%.1f", range.drop_mils];
        _driftMOAMils.text = [NSString stringWithFormat:@"%.1f", range.drift_mils];
        _dropUnitLabel.text = _driftUnitLabel.text = @"MILs";
    }
}

@end
