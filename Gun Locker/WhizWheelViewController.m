//
//  WhizWheelViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define CIRCULAR_TABLE_SIZE 1000
#define PIXELS_PER_MIL 9.2
#import "WhizWheelViewController.h"

@implementation WhizWheelViewController
@synthesize tableBackgroundImage;
@synthesize rangesTableView, directionsTableView, speedTableView;
@synthesize rangeLabel, directionLabel, speedLabel;
@synthesize dropInchesLabel, dropMOALabel, dropMILsLabel;
@synthesize driftInchesLabel, driftMOALabel, driftMILsLabel;
@synthesize selectedProfile;
@synthesize lastSelectedRangeCell, lastSelectedDirectionCell, lastSelectedSpeedCell;
@synthesize resultBackgroundView;
@synthesize resultReticleView;
@synthesize resultBulletImpactImage;
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
    
//    self.title = self.selectedProfile.name;
}

-(void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int rangeStart       = [defaults integerForKey:@"rangeStart"] ? [defaults integerForKey:@"rangeStart"] : 100;
    int rangeEnd         = [defaults integerForKey:@"rangeEnd"]   ? [defaults integerForKey:@"rangeEnd"]   : 1200;
    int rangeStep        = [defaults integerForKey:@"rangeStep"]  ? [defaults integerForKey:@"rangeStep"]  : 25;
    self.rangeLabel.text = [defaults integerForKey:@"rangeUnitsControl"] == 0 ? @"Yards" : @"Meters";
        
    // array of Ranges:  pad front and bad to get proper pickerview from tableview
    arrayRanges = [[NSMutableArray alloc] initWithObjects:@"", @"", nil];
    for(int range = rangeStart; range <= rangeEnd; range += rangeStep)
        [arrayRanges addObject:[NSString stringWithFormat:@"%d", range]];
    [arrayRanges addObject:@""];
    [arrayRanges addObject:@""];
    
    // array of Directions
    arrayDirections = [[NSMutableArray alloc] init];
    switch ([defaults integerForKey:@"directionControl"]) {
        case 0:          // degrees
            for(int degree = 0; degree < 360; degree += 10)
                [arrayDirections addObject:[NSString stringWithFormat:@"%d°", degree]];
            directionLabel.text = @"Degree";
            break;
        case 1:          // clock
            [arrayDirections addObject:@"12 o'clock"];
            for(int clock = 1; clock < 12; clock++)
                [arrayDirections addObject:[NSString stringWithFormat:@"%d o'clock", clock]];
            directionLabel.text = @"Direction";
            break;
        case 2:          // cardinal  --> Needs compass to be implemented correctly
            [arrayDirections addObject:@"North"];
            [arrayDirections addObject:@"Northeast"];
            [arrayDirections addObject:@"East"];
            [arrayDirections addObject:@"Southeast"];
            [arrayDirections addObject:@"South"];
            [arrayDirections addObject:@"Southwest"];
            [arrayDirections addObject:@"West"];
            [arrayDirections addObject:@"Northwest"];
            break;
        default:
            break;
    }
    
    // array of Speeds
    arraySpeeds = [[NSMutableArray alloc] init];
    self.speedUnit = [defaults objectForKey:@"speedUnit"];
    self.speedType = [defaults objectForKey:@"speedType"];
    if([speedUnit isEqualToString:@"Human"]) {
        speedLabel.text = speedUnit;
        [arraySpeeds addObject:@"At Rest"];
        [arraySpeeds addObject:@"Walking"];
        [arraySpeeds addObject:@"Jogging"];
        [arraySpeeds addObject:@"Running"];        
    } else { // MPH KPH MPS Knots
        for (int speed = 0; speed < 25; speed++)
            [arraySpeeds addObject:[NSString stringWithFormat:@"%d %@", speed, speedUnit]];
        speedLabel.text = speedType;
    }
    
    [rangesTableView reloadData];
    [directionsTableView reloadData];
    [speedTableView reloadData];
    
    self.nightMode = [[defaults objectForKey:@"nightModeControl"] intValue];
    if (nightMode) {
        rangesTableView.backgroundColor = directionsTableView.backgroundColor = speedTableView.backgroundColor = resultBackgroundView.backgroundColor = [UIColor blackColor];
        resultReticleView.image = [UIImage imageNamed:@"mil_dot_reticle_night"];
        for (UILabel *label in self.view.subviews){
            if ([label isKindOfClass:[UILabel class]]){
                label.textColor = tableBackgroundImage.backgroundColor = [UIColor colorWithRed:0.603 green:0.000 blue:0.000 alpha:1.000];
            }
        }
        rangeLabel.textColor = directionLabel.textColor = speedLabel.textColor = [UIColor lightGrayColor];
    } else {
        rangesTableView.backgroundColor = directionsTableView.backgroundColor = speedTableView.backgroundColor = resultBackgroundView.backgroundColor = [UIColor whiteColor];
        resultReticleView.image = [UIImage imageNamed:@"mil_dot_reticle_day"];
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

    [super viewWillAppear:animated];
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
    [self setResultReticleView:nil];
    [self setTableBackgroundImage:nil];
    [self setResultBulletImpactImage:nil];
    [self setSpeedType:nil];
    [self setSpeedUnit:nil];
    [self setDropInchesLabel:nil];
    [self setDropMOALabel:nil];
    [self setDropMILsLabel:nil];
    [self setDriftInchesLabel:nil];
    [self setDriftMOALabel:nil];
    [self setDriftMILsLabel:nil];
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
    } else if (scrollView == directionsTableView) {
        index = [directionsTableView indexPathForRowAtPoint:CGPointMake([directionsTableView contentOffset].x, 100+[directionsTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [directionsTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedDirectionCell =  [directionsTableView cellForRowAtIndexPath:index];
    } else if (scrollView == speedTableView) {
        index = [speedTableView indexPathForRowAtPoint:CGPointMake([speedTableView contentOffset].x, 100+[speedTableView contentOffset].y)];
        // 'quantitize' scrolling to rows
        [speedTableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.lastSelectedSpeedCell =  [speedTableView cellForRowAtIndexPath:index];
    }

    [self highlightSelectedCells];
    
    [self calculateBallistics];
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
    
    [self calculateBallistics];
}

- (void)calculateBallistics {
    int range = [self.lastSelectedRangeCell.textLabel.text intValue];
    int speed = [self.lastSelectedSpeedCell.textLabel.text intValue];
    
    if ([lastSelectedSpeedCell.textLabel.text isEqualToString:@"At Rest"]) {
        speed = 0;
    } else if ([lastSelectedSpeedCell.textLabel.text isEqualToString:@"Walking"]) {
        speed = 3;
    } else if ([lastSelectedSpeedCell.textLabel.text isEqualToString:@"Jogging"]) {
        speed = 6;
    } else if ([lastSelectedSpeedCell.textLabel.text isEqualToString:@"Running"]) {
        speed = 10;
    }
    
    if ([speedType isEqualToString:@"Leading"]) {
        speed *= -1;
    }
    
    
    // pseudo random drop
    float fakeDropMILs = range/1200.0 * 5; 
    
    // pseudo random drift
    float fakeDriftMILs = range/1200.0 * 5 * speed/30.0 ; 

    self.resultBulletImpactImage.center = CGPointMake(160 + fakeDriftMILs * PIXELS_PER_MIL, 74 + fakeDropMILs * PIXELS_PER_MIL);
    dropInchesLabel.text = [NSString stringWithFormat:@"%.1f\"", fakeDropMILs * ((3.6)*(range/100))];
    dropMOALabel.text    = [NSString stringWithFormat:@"%.1f MOA", fakeDropMILs / 3.6];
    dropMILsLabel.text   = [NSString stringWithFormat:@"%.1f MILs", fakeDropMILs];
    
    driftInchesLabel.text = [NSString stringWithFormat:@"%.1f\"", fakeDriftMILs * ((3.6)*(range/100))];
    driftMOALabel.text    = [NSString stringWithFormat:@"%.1f MOA", fakeDriftMILs / 3.6];
    driftMILsLabel.text   = [NSString stringWithFormat:@"%.1f MILs", fakeDriftMILs];
}

@end
