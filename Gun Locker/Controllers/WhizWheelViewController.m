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
@synthesize resultContainerView = _resultContainerView;
@synthesize resultView = _resultView;
@synthesize rangesTableView = _rangesTableView, directionsTableView = _directionsTableView, speedTableView = _speedTableView;
@synthesize rangeLabel = _rangeLabel, directionTypeLabel = _directionTypeLabel, speedLabel = _speedLabel, fromLabel = _fromLabel;
@synthesize dropInchesLabel = _dropInchesLabel, dropMOAMils = _dropMOAMils;
@synthesize driftInchesLabel = _driftInchesLabel, driftMOAMils = _driftMOAMils;
@synthesize dropUnitLabel = _dropUnitLabel, driftUnitLabel = _driftUnitLabel;
@synthesize selectedProfile = _selectedProfile;
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
    tableIndexes = [[NSMutableDictionary alloc] initWithCapacity:3];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    reticle = [defaults integerForKey:kGLReticleUnitsControlKey] == 0 ? @"MOA" : @"MilDot";
    
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
    
    [tableIndexes setObject:[NSIndexPath indexPathForRow:2 inSection:0] forKey:@"range"];
    [tableIndexes setObject:[NSIndexPath indexPathForRow:([arrayDirections count]*CIRCULAR_TABLE_SIZE/2) inSection:0] forKey:@"direction"];
    [tableIndexes setObject:[NSIndexPath indexPathForRow:([arraySpeeds count]*CIRCULAR_TABLE_SIZE/2) inSection:0] forKey:@"speed"];
    [_rangesTableView scrollToRowAtIndexPath:[tableIndexes objectForKey:@"range"] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [_directionsTableView scrollToRowAtIndexPath:[tableIndexes objectForKey:@"direction"] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [_speedTableView scrollToRowAtIndexPath:[tableIndexes objectForKey:@"speed"] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    [self showTrajectoryWithRecalc:YES];
    
    [self checkDayOrNightMode:nil];
}

- (void)updateToNightMode {
    UIColor *halfRedColor = [UIColor colorWithRed:0.603 green:0.000 blue:0.000 alpha:1.000];
    UIColor *blackColor = [UIColor blackColor];

    _nightMode = YES;
    _rangesTableView.backgroundColor = _directionsTableView.backgroundColor = _resultContainerView.backgroundColor = _speedTableView.backgroundColor = _resultBackgroundView.backgroundColor = blackColor;
    
    _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_night", reticle]];
    for (UILabel *label in _resultView.subviews)
        if ([label isKindOfClass:[UILabel class]])
            label.textColor = halfRedColor;

    _tableBackgroundImage.backgroundColor = halfRedColor;
    
    _titleLabel.textColor = _rangeLabel.textColor = _directionTypeLabel.textColor = [UIColor colorWithWhite:0.75f alpha:1.f];
    _fromLabel.textColor = _speedLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];

    _dropInchesLabel.textColor = _dropMOAMils.textColor = _driftInchesLabel.textColor = _driftMOAMils.textColor = _dropClicksLabel.textColor = _driftClicksLabel.textColor = [UIColor lightGrayColor];
    
    NSArray *visibleCells = [[[_rangesTableView visibleCells] arrayByAddingObjectsFromArray:[_directionsTableView visibleCells]] arrayByAddingObjectsFromArray:[_speedTableView visibleCells]];
    for (UITableViewCell *cell in visibleCells)
        cell.textLabel.textColor = [UIColor redColor];    
    
    [self highlightSelectedCells];
}

- (void)updateToDayMode {
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *blackColor = [UIColor blackColor];
    _nightMode = NO;
    _rangesTableView.backgroundColor = _directionsTableView.backgroundColor = _resultContainerView.backgroundColor = _speedTableView.backgroundColor = _resultBackgroundView.backgroundColor = _titleLabel.textColor = _rangeLabel.textColor = _directionTypeLabel.textColor = whiteColor;
    _fromLabel.textColor = _speedLabel.textColor = [UIColor colorWithWhite:0.75f alpha:1.f];
    
    _reticleImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"Reticles/%@_day", reticle]];
    
    for (UILabel *label in _resultView.subviews)
        if ([label isKindOfClass:[UILabel class]])
            label.textColor = blackColor;
    
    _tableBackgroundImage.backgroundColor = [UIColor lightGrayColor];
    
    NSArray *visibleCells = [[[_rangesTableView visibleCells] arrayByAddingObjectsFromArray:[_directionsTableView visibleCells]] arrayByAddingObjectsFromArray:[_speedTableView visibleCells]];
    for (UITableViewCell *cell in visibleCells)
        cell.textLabel.textColor = blackColor;

    [self highlightSelectedCells];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TestFlight passCheckpoint:@"Whiz Wheel disappeared"];
    [modeTimer invalidate];
}

// TODO: fix orientation across all Views
-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate {
    return NO;
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

-(void)scrollViewWillEndDragging:(UITableView *)tableView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    float rowHeight = tableView.rowHeight;
    float rowMiddleOffset = rowHeight * 0.25 + 1;
    int row = round((targetContentOffset->y - rowMiddleOffset) / rowHeight);

    // 'quantitize' scrolling to rows
    targetContentOffset->y = (row * rowHeight) + rowMiddleOffset;
    NSIndexPath *index = [NSIndexPath indexPathForRow:row + 2 inSection:0];
    
    if(tableView == _rangesTableView) {
        [tableIndexes setObject:index forKey:@"range"];
        [self showTrajectoryWithRecalc:NO];
    } else if (tableView == _directionsTableView) {
        [tableIndexes setObject:index forKey:@"direction"];
        [self showTrajectoryWithRecalc:YES];
    } else if (tableView == _speedTableView) {
        [tableIndexes setObject:index forKey:@"speed"];
        [self showTrajectoryWithRecalc:YES];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self highlightSelectedCells];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.nightMode) {
        UITableViewCell *cell;
        if(scrollView == _rangesTableView) {
            cell = [_rangesTableView cellForRowAtIndexPath:[tableIndexes objectForKey:@"range"]];
        } else if (scrollView == _directionsTableView) {
            cell = [_directionsTableView cellForRowAtIndexPath:[tableIndexes objectForKey:@"direction"]];
        } else if (scrollView == _speedTableView) {
            cell = [_speedTableView cellForRowAtIndexPath:[tableIndexes objectForKey:@"speed"]];
        }
        cell.textLabel.textColor = [UIColor redColor];
    }
}

#pragma mark Actions
-(void)highlightSelectedCells { //  highlight cells under the selector if night mode
    [_rangesTableView cellForRowAtIndexPath:[tableIndexes objectForKey:@"range"]].textLabel.textColor =
    [_directionsTableView cellForRowAtIndexPath:[tableIndexes objectForKey:@"direction"]].textLabel.textColor =
    [_speedTableView cellForRowAtIndexPath:[tableIndexes objectForKey:@"speed"]].textLabel.textColor =
        _nightMode ? [UIColor whiteColor] : [UIColor blackColor];
}

- (void)showTrajectoryWithRecalc:(BOOL)recalc {
    // range index is minus two due to front @"" double padding
    int rangeIndex = ((NSIndexPath *)[tableIndexes objectForKey:@"range"]).row - 2;

    if(recalc) {
        int directionIndex = ((NSIndexPath *)[tableIndexes objectForKey:@"direction"]).row % [arrayDirections count];
        int speedIndex     = ((NSIndexPath *)[tableIndexes objectForKey:@"speed"]).row % [arraySpeeds count];
        NSString *directionString = [arrayDirections objectAtIndex:directionIndex];
        NSString *speedString     = [arraySpeeds objectAtIndex:speedIndex];
        
        // convert direction to degrees
        angleDegrees = [directionType isEqualToString:@"Clocking"] ?
            CLOCK_to_DEGREES([directionString doubleValue]) :
            [directionString intValue];

        // convert speed units
        if ([_speedUnit isEqualToString:@"Human"]) {
            speedMPH = [[dataManager.humanMPHSpeeds objectForKey:speedString] doubleValue];
        } else if ([_speedUnit isEqualToString:@"Knots"]) {
            speedMPH = KNOTS_to_MPH([speedString doubleValue]);
        } else if ([_speedUnit isEqualToString:@"m/s"]) {
            speedMPH = MPS_to_MPH([speedString doubleValue]);
        } else if ([_speedUnit isEqualToString:@"km/h"]) {
            speedMPH = KPH_to_MPH([speedString doubleValue]);
        } else { // MPH
            speedMPH = [speedString doubleValue];
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

- (void)viewDidUnload {
    [self setResultContainerView:nil];
    [self setResultView:nil];
    [super viewDidUnload];
}
@end
