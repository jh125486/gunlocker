//
//  WhizWheelViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define CIRCULAR_TABLE_SIZE 1000
#define PIXELS_PER_MIL -10
#define PIXELS_PER_MOA -2
#import "WhizWheelViewController.h"

@implementation WhizWheelViewController
@synthesize tableBackgroundImage;
@synthesize rangesTableView, directionsTableView, speedTableView;
@synthesize rangeLabel, directionLabel, speedLabel;
@synthesize dropInchesLabel = _dropInchesLabel, dropMOAMils = _dropMOAMils;
@synthesize driftInchesLabel = _driftInchesLabel, driftMOAMils = _driftMOAMils;
@synthesize dropUnitLabel = _dropUnitLabel, driftUnitLabel = _driftUnitLabel;
@synthesize selectedProfile;
@synthesize lastSelectedRangeCell, lastSelectedDirectionCell, lastSelectedSpeedCell;
@synthesize resultBackgroundView;
@synthesize reticleImage = _reticleImage;
@synthesize reticlePOIImage = _reticlePOIImage;
@synthesize nightMode;
@synthesize speedUnit, speedType;

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

    
//    trajectory.windSpeed = (self.windSpeedUnitControl.selectedSegmentIndex == 0) ? KNOTS_to_MPH([self.windSpeedTextField.text doubleValue]) : [self.windSpeedTextField.text doubleValue];
//    trajectory.windAngle = (self.windDirectionUnitControl.selectedSegmentIndex == 0) ? [self.windDirectionTextField.text doubleValue] : CLOCK_to_DEGREES([self.windDirectionTextField.text doubleValue]);
//    
//    trajectory.leadSpeed = (self.leadingSpeedUnitControl.selectedSegmentIndex == 0) ? KNOTS_to_MPH([self.leadingSpeedTextField.text doubleValue]) : [self.leadingSpeedTextField.text doubleValue];
//    trajectory.leadAngle = (self.leadingDirectionUnitControl.selectedSegmentIndex == 0) ? [self.leadingDirectionTextField.text doubleValue] : CLOCK_to_DEGREES([self.leadingDirectionTextField.text doubleValue]);
  
}

-(void)viewWillAppear:(BOOL)animated {    
    [super viewWillAppear:animated];

    // set to initial picker positions
    rangeIndex = 0;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    reticle = [defaults boolForKey:@"reticleUnitsControl"] ? @"MOA" : @"MilDot";
    
    int rangeStart       = [defaults integerForKey:@"rangeStart"];
    int rangeEnd         = [defaults integerForKey:@"rangeEnd"];
    int rangeStep        = [defaults integerForKey:@"rangeStep"];
    self.rangeLabel.text = [defaults integerForKey:@"rangeUnitsControl"] == 0 ? @"Yards" : @"Meters";

    // XXX do all conversions for UnitControls
    trajectory.rangeStart = rangeStart;
    trajectory.rangeEnd =  rangeEnd;
    trajectory.rangeStep = rangeStep;
    trajectory.tempC = 15;
    trajectory.relativeHumidity = 0;
    trajectory.pressureInhg = 29.92;
    trajectory.altitudeM = 0;
    trajectory.ballisticProfile = selectedProfile;
    
    // array of Ranges:  pad front and back to get proper fake pickerview row alignment from real tableview
    arrayRanges = [[NSMutableArray alloc] initWithObjects:@"", @"", nil];
    for(int range = rangeStart; range <= rangeEnd; range += rangeStep)
        [arrayRanges addObject:[NSString stringWithFormat:@"%d", range]];
    [arrayRanges addObject:@""];
    [arrayRanges addObject:@""];
    
    
    self.directionLabel.text = [dataManager.directionTypes objectAtIndex:[defaults integerForKey:@"directionControl"]];
    arrayDirections = [dataManager.whizWheelPicker2 objectForKey:directionLabel.text];
    
    self.speedUnit = [defaults objectForKey:@"speedUnit"]; // should have another label to differentiate between leading and windage
    self.speedType = [defaults objectForKey:@"speedType"];
    self.speedLabel.text = speedType;
    arraySpeeds = [dataManager.whizWheelPicker3 objectForKey:speedUnit];
    
    NSLog(@"whiz2 keys %@  whiz3 key %@", [dataManager.whizWheelPicker2 allKeys], [dataManager.whizWheelPicker3 allKeys]);
    NSLog(@"size of ranges: %d directions %d speeds %d", [arrayRanges count], [arrayDirections count], [arraySpeeds count]);
    
    [rangesTableView reloadData];
    [directionsTableView reloadData];
    [speedTableView reloadData];
    
    self.nightMode = [[defaults objectForKey:@"nightModeControl"] intValue];
    
    if (nightMode) {
        rangesTableView.backgroundColor = directionsTableView.backgroundColor = speedTableView.backgroundColor = resultBackgroundView.backgroundColor = [UIColor blackColor];
        _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_night", reticle]];
        for (UILabel *label in self.view.subviews){
            if ([label isKindOfClass:[UILabel class]]){
                label.textColor = tableBackgroundImage.backgroundColor = [UIColor colorWithRed:0.603 green:0.000 blue:0.000 alpha:1.000];
            }
        }
        rangeLabel.textColor = directionLabel.textColor = speedLabel.textColor = [UIColor lightGrayColor];
    } else {
        rangesTableView.backgroundColor = directionsTableView.backgroundColor = speedTableView.backgroundColor = resultBackgroundView.backgroundColor = [UIColor whiteColor];
        _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_day", reticle]];
        for (UILabel *label in self.view.subviews){
            if ([label isKindOfClass:[UILabel class]]){
                label.textColor = [UIColor blackColor];
            }
        }
        rangeLabel.textColor = directionLabel.textColor = speedLabel.textColor = [UIColor whiteColor];
        tableBackgroundImage.backgroundColor = [UIColor lightGrayColor];
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
    if (tableView == rangesTableView) {
        return [arrayRanges count];
    } else if (tableView == directionsTableView) {
        return [arrayDirections count] * CIRCULAR_TABLE_SIZE;
    } else if (tableView == speedTableView) {
        return [arraySpeeds count] * CIRCULAR_TABLE_SIZE;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    
    if (tableView == rangesTableView) {
        cellIdentifier = @"RangeCell";
    } else if (tableView == directionsTableView) {
        cellIdentifier = @"DirectionCell";
    } else if (tableView == speedTableView) {
        cellIdentifier = @"SpeedCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    cell.backgroundColor = self.nightMode ? [UIColor blackColor] : [UIColor whiteColor];
    cell.textLabel.textColor = self.nightMode ? [UIColor redColor] : [UIColor blackColor];
    cell.textLabel.textAlignment = UITextAlignmentRight;

    NSString *cellText;
    if (tableView == rangesTableView) {
        cellText = [arrayRanges objectAtIndex:indexPath.row];
    } else if (tableView == directionsTableView) {
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cellText = [arrayDirections objectAtIndex:indexPath.row % [arrayDirections count]];
    } else if (tableView == speedTableView) {
        cellText = [arraySpeeds objectAtIndex:indexPath.row % [arraySpeeds count]];
        if (![speedUnit isEqualToString:@"Human"]) cellText = [cellText stringByAppendingString:self.speedUnit];
    }
    
    cell.textLabel.text = cellText;
    
    return cell;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSIndexPath *index;
    if(scrollView == rangesTableView) {
        index = [rangesTableView indexPathForRowAtPoint:CGPointMake([rangesTableView contentOffset].x, 100+[rangesTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [rangesTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedRangeCell =  [rangesTableView cellForRowAtIndexPath:index];
        rangeIndex = index.row - 2;
        [self showTrajectoryWithRecalc:NO];
    } else if (scrollView == directionsTableView) {
        index = [directionsTableView indexPathForRowAtPoint:CGPointMake([directionsTableView contentOffset].x, 100+[directionsTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [directionsTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedDirectionCell =  [directionsTableView cellForRowAtIndexPath:index];
        [self showTrajectoryWithRecalc:YES];
    } else if (scrollView == speedTableView) {
        index = [speedTableView indexPathForRowAtPoint:CGPointMake([speedTableView contentOffset].x, 100+[speedTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [speedTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedSpeedCell =  [speedTableView cellForRowAtIndexPath:index];
        [self showTrajectoryWithRecalc:YES];
    }


    
    
    [self highlightSelectedCells];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.nightMode) {
        if(scrollView == rangesTableView) {
            self.lastSelectedRangeCell.textLabel.textColor = [UIColor redColor];
        } else if (scrollView == directionsTableView) {
            self.lastSelectedDirectionCell.textLabel.textColor = [UIColor redColor];
        } else if (scrollView == speedTableView) {
            self.lastSelectedSpeedCell.textLabel.textColor = [UIColor redColor];
        }
    }
}


#pragma mark Actions
-(void)highlightSelectedCells { //  highlight cells under the selector if night mode
    if(nightMode) {
        self.lastSelectedRangeCell.textLabel.textColor = [UIColor whiteColor];
        self.lastSelectedDirectionCell.textLabel.textColor = [UIColor whiteColor];
        self.lastSelectedSpeedCell.textLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setInitialSelectedCells {
    // scroll direction and speed to middle to simulate a circular picker
    NSIndexPath *initialRange = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *initialDirection = [NSIndexPath indexPathForRow:([arrayDirections count]*CIRCULAR_TABLE_SIZE/2) inSection:0];
    NSIndexPath *initialSpeed = [NSIndexPath indexPathForRow:([arraySpeeds count]*CIRCULAR_TABLE_SIZE/2) inSection:0];
    
    [rangesTableView scrollToRowAtIndexPath:initialRange atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    self.lastSelectedRangeCell = [rangesTableView cellForRowAtIndexPath:initialRange];
    [directionsTableView scrollToRowAtIndexPath:initialDirection atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    self.lastSelectedDirectionCell = [directionsTableView cellForRowAtIndexPath:initialDirection];
    [speedTableView scrollToRowAtIndexPath:initialSpeed atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    self.lastSelectedSpeedCell = [speedTableView cellForRowAtIndexPath:initialSpeed];
}

- (void)showTrajectoryWithRecalc:(BOOL)recalc {
    if(recalc) {
        // set up wind/leading speed/direction unit conversions
        if ([speedType isEqualToString:@"Wind"]) {
            trajectory.windSpeed = [self.lastSelectedSpeedCell.textLabel.text doubleValue];
            trajectory.windAngle = [self.lastSelectedDirectionCell.textLabel.text doubleValue];
            trajectory.leadSpeed = 0.0;
        } else {
            if ([speedUnit isEqualToString:@"Human"]) {
                trajectory.leadSpeed = [[dataManager.humanMPHSpeeds objectForKey:lastSelectedSpeedCell.textLabel.text] doubleValue];
            } else {                
                trajectory.leadSpeed = [self.lastSelectedSpeedCell.textLabel.text doubleValue];
            }
            trajectory.leadAngle = [self.lastSelectedDirectionCell.textLabel.text doubleValue];
            trajectory.windSpeed = 0.0;
        }
        
        [trajectory setup];
        [trajectory calculateTrajectory];
        NSLog(@"Whiz Wheel: had to recalculate");
    }
        
    TrajectoryRange *range = [trajectory.ranges objectAtIndex:rangeIndex];
    
    NSLog(@"row %d\trange: %@\tdrop: \"%@\tdrift: %@\"", rangeIndex, range.range_yards, range.drop_inches, range.drift_inches);
    
    _dropInchesLabel.text  = range.drop_inches;
    _driftInchesLabel.text = range.drift_inches;

    if ([reticle isEqualToString:@"MOA"]) {
        _reticlePOIImage.center = CGPointMake(160.5f + [range.drift_moa floatValue] * PIXELS_PER_MOA, 
                                               74.5f + [range.drop_moa floatValue]  * PIXELS_PER_MOA);
        _dropMOAMils.text  = range.drop_moa;
        _driftMOAMils.text = range.drift_moa;
        _dropUnitLabel.text = _driftUnitLabel.text = @"MOA";
    } else {
        _reticlePOIImage.center = CGPointMake(160.5f + [range.drift_mils floatValue] * PIXELS_PER_MIL, 
                                               74.5f + [range.drop_mils floatValue]  * PIXELS_PER_MIL);        
        _dropMOAMils.text  = range.drop_mils;
        _driftMOAMils.text = range.drift_mils;
        _dropUnitLabel.text = _driftUnitLabel.text = @"MILs";
    }
}

@end
