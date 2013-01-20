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
@synthesize dropClicksLabel = _dropClicksLabel;
@synthesize driftClicksLabel = _driftClicksLabel;
@synthesize titleLabel = _titleLabel;
@synthesize tableBackgroundImage = _tableBackgroundImage;
@synthesize rangesTableView = _rangesTableView, directionsTableView = _directionsTableView, speedTableView = _speedTableView;
@synthesize rangeLabel = _rangeLabel, directionTypeLabel = _directionTypeLabel, speedLabel = _speedLabel, fromLabel = _fromLabel;
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
    _titleLabel.text = self.selectedProfile.name;
    trajectory = [[Trajectory alloc] init];
    trajectory.tempC = 15;
    trajectory.relativeHumidity = 0;
    trajectory.pressureInhg = 29.92;
    trajectory.altitudeM = 0;
    trajectory.ballisticProfile = _selectedProfile;
    
    elevation_click = [[_selectedProfile.elevation_click decimalFromFraction] doubleValue];
    windage_click   = [[_selectedProfile.windage_click decimalFromFraction] doubleValue];

    [trajectory setup];
    
    dataManager = [DataManager sharedManager];
    
    
    modeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f * 60.f // every 5 minutes
                                                 target:self
                                               selector:@selector(checkDayOrNightMode:)
                                               userInfo:nil
                                                repeats:YES];    
}

-(void)checkDayOrNightMode:(NSTimer*)timer {
    int mode = [[[NSUserDefaults standardUserDefaults] objectForKey:kGLNightModeControlKey] intValue];
    
    if (mode == 0) {// day mode all the time
        DebugLog(@"Mode: day mode");
        [self updateToDayMode];
    } else if (mode == 1) { // night mode all the time
        DebugLog(@"Mode: night mode");
        [self updateToNightMode];
    } else { // Auto
        DebugLog(@"Mode: auto mode");
        
        // TODO get a better fix from the GPS here
        GeoLocation *location = [[GeoLocation alloc] initWithName:@"Location" 
                                                      andLatitude:dataManager.locationManager.location.coordinate.latitude 
                                                     andLongitude:dataManager.locationManager.location.coordinate.longitude 
                                                      andTimeZone:[NSTimeZone systemTimeZone]];
        
        AstronomicalCalendar *astronomicalCalendar = [[AstronomicalCalendar alloc] initWithLocation:location];
        NSDate *sunrise = [astronomicalCalendar sunrise];
        NSDate *sunset  = [astronomicalCalendar sunset];    
        NSDate *currentTime = [NSDate date];
        
        BOOL isNightTime = (([currentTime compare:sunrise] == NSOrderedAscending) || ([currentTime compare:sunset] == NSOrderedDescending));

        
        if (isNightTime) {
            if (!_nightMode) {
                DebugLog(@"! Switching to night mode");
                [self updateToNightMode];   
            }
        } else { // Day mode
            if (_nightMode) { 
                DebugLog(@"! Switching to day mode");
                [self updateToDayMode];
            }
        }
    }    
}

-(void)viewWillAppear:(BOOL)animated {    
    [super viewWillAppear:animated];
    
    // set to initial picker positions
    rangeIndex = 0;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    reticle = [defaults boolForKey:kGLReticleUnitsControlKey] ? @"MOA" : @"MilDot";
    
    // do all conversions for UnitControls
    trajectory.rangeUnit  = [defaults integerForKey:kGLRangeUnitsControlKey];
    trajectory.rangeStart = [defaults integerForKey:kGLRangeStartKey];
    trajectory.rangeEnd   =  [defaults integerForKey:kGLRangeEndKey];
    trajectory.rangeStep  = [defaults integerForKey:kGLRangeStepKey];
    
    _rangeLabel.text = (trajectory.rangeUnit == 0) ? @"Yards" : @"Meters";
    
    // array of Ranges:  pad front and back to get proper fake pickerview row alignment from real tableview
    arrayRanges = [[NSMutableArray alloc] initWithObjects:@"", @"", nil];
    for(int range = trajectory.rangeStart; range <= trajectory.rangeEnd; range += trajectory.rangeStep)
        [arrayRanges addObject:[NSString stringWithFormat:@"%d", range]];
    [arrayRanges addObject:@""];
    [arrayRanges addObject:@""];
    
    
    directionType = [dataManager.directionTypes objectAtIndex:[defaults integerForKey:kGLDirectionControlKey]];
    arrayDirections = [dataManager.whizWheelPicker2 objectForKey:directionType];
    
    _speedUnit = [defaults objectForKey:@"speedUnit"]; // should have another label to differentiate between leading and windage
    _speedType = [defaults objectForKey:@"speedType"];
    _directionTypeLabel.text = _speedType;
    arraySpeeds = [dataManager.whizWheelPicker3 objectForKey:_speedUnit];
        
    [_rangesTableView reloadData];
    [_directionsTableView reloadData];
    [_speedTableView reloadData];
    
    [self updateInitialSelectedCells];
    [self showTrajectoryWithRecalc:YES];
    
    [self checkDayOrNightMode:nil];
}

- (void)updateToNightMode {
    _nightMode = YES;
    _rangesTableView.backgroundColor = _directionsTableView.backgroundColor = [UIColor blackColor];
    _speedTableView.backgroundColor = _resultBackgroundView.backgroundColor = [UIColor blackColor];
    
    _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_night", reticle]];
    for (UILabel *label in self.view.subviews)
        if ([label isKindOfClass:[UILabel class]])
            label.textColor =  [UIColor colorWithRed:0.603 green:0.000 blue:0.000 alpha:1.000];

    _tableBackgroundImage.backgroundColor = [UIColor colorWithRed:0.603 green:0.000 blue:0.000 alpha:1.000];
    
    _titleLabel.textColor = _rangeLabel.textColor = _directionTypeLabel.textColor = [UIColor colorWithWhite:0.75f alpha:1.f];
    _fromLabel.textColor = _speedLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];

    _dropInchesLabel.textColor = _dropMOAMils.textColor = _driftInchesLabel.textColor = _driftMOAMils.textColor = _dropClicksLabel.textColor = _driftClicksLabel.textColor = [UIColor lightGrayColor];
    
    NSArray *visibleCells = [[[_rangesTableView visibleCells] arrayByAddingObjectsFromArray:[_directionsTableView visibleCells]] arrayByAddingObjectsFromArray:[_speedTableView visibleCells]];
    for (UITableViewCell *cell in visibleCells)
        cell.textLabel.textColor = [UIColor redColor];    
    
    [self highlightSelectedCells];
}

- (void)updateToDayMode {
    _nightMode = NO;
    _rangesTableView.backgroundColor = _directionsTableView.backgroundColor = [UIColor whiteColor];
    _speedTableView.backgroundColor = _resultBackgroundView.backgroundColor = _titleLabel.textColor = [UIColor whiteColor];
    
    _rangeLabel.textColor = _directionTypeLabel.textColor = [UIColor whiteColor];
    _fromLabel.textColor = _speedLabel.textColor = [UIColor colorWithWhite:0.75f alpha:1.f];
    
    _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_day", reticle]];
    
    for (UILabel *label in self.view.subviews)
        if ([label isKindOfClass:[UILabel class]])
            label.textColor = [UIColor blackColor];
    
    _tableBackgroundImage.backgroundColor = [UIColor lightGrayColor];
    
    NSArray *visibleCells = [[[_rangesTableView visibleCells] arrayByAddingObjectsFromArray:[_directionsTableView visibleCells]] arrayByAddingObjectsFromArray:[_speedTableView visibleCells]];
    for (UITableViewCell *cell in visibleCells)
        cell.textLabel.textColor = [UIColor blackColor];

    [self highlightSelectedCells];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TestFlight passCheckpoint:@"Whiz Wheel disappeared"];
    [modeTimer invalidate];
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

    cell.backgroundColor = _nightMode ? [UIColor blackColor] : [UIColor whiteColor];
    cell.textLabel.textColor = _nightMode ? [UIColor redColor] : [UIColor blackColor];
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
        _lastSelectedRangeCell.textLabel.textColor =  
            _lastSelectedDirectionCell.textLabel.textColor = 
            _lastSelectedSpeedCell.textLabel.textColor = [UIColor whiteColor];
    } else {
        _lastSelectedRangeCell.textLabel.textColor =  
        _lastSelectedDirectionCell.textLabel.textColor = 
        _lastSelectedSpeedCell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)updateInitialSelectedCells {
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
        if ([directionType isEqualToString:@"Clocking"]) {
            angleDegrees =  CLOCK_to_DEGREES([_lastSelectedDirectionCell.textLabel.text intValue]);
        } else { // in Degrees
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
        DebugLog(@"Whiz Wheel: Recalculated Wind/Leading %.1f mph at %.1f degrees", speedMPH, angleDegrees);
    }
        
    TrajectoryRange *rangeDatum = [trajectory.ranges objectAtIndex:rangeIndex];
        
    _dropInchesLabel.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_inches];
    _driftInchesLabel.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_inches];

    if ([reticle isEqualToString:@"MOA"]) {
        _reticlePOIImage.center = CGPointMake(160.f + rangeDatum.drift_moa * PIXELS_PER_MOA +0.25f, 
                                              74.f - rangeDatum.drop_moa * PIXELS_PER_MOA +0.25f);
        _dropMOAMils.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_moa];
        _driftMOAMils.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_moa];
        _dropUnitLabel.text = _driftUnitLabel.text = @"MOA";
    } else { // MILs
        _reticlePOIImage.center = CGPointMake(160.f + rangeDatum.drift_mils * PIXELS_PER_MIL +0.25f, 
                                              74.f - rangeDatum.drop_mils * PIXELS_PER_MIL +0.25f);        
        _dropMOAMils.text  = [NSString stringWithFormat:@"%.1f", rangeDatum.drop_mils];
        _driftMOAMils.text = [NSString stringWithFormat:@"%.1f", rangeDatum.drift_mils];
        _dropUnitLabel.text = _driftUnitLabel.text = @"MILs";
    }
    
    if ([_selectedProfile.scope_click_unit isEqualToString:@"MILs"]) {
        _dropClicksLabel.text  = [NSString stringWithFormat:@"%g", round(rangeDatum.drop_mils / elevation_click)];
        _driftClicksLabel.text = [NSString stringWithFormat:@"%g", round(rangeDatum.drift_mils / windage_click)];
    } else { //MOA
        _dropClicksLabel.text  = [NSString stringWithFormat:@"%g", round(rangeDatum.drop_moa / elevation_click)];
        _driftClicksLabel.text = [NSString stringWithFormat:@"%g", round(rangeDatum.drift_moa / windage_click)];            
    }

}

@end
