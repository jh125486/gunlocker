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

@interface WhizWheelViewController ()

@end

@implementation WhizWheelViewController
@synthesize tableBackgroundImage;
@synthesize rangesTableView, directionsTableView, speedTableView;
@synthesize rangeLabel, directionLabel, speedLabel;
@synthesize dropLabel;
@synthesize driftLabel;
@synthesize dropResultLabel;
@synthesize driftResultLabel;
@synthesize selectedProfile;
@synthesize lastSelectedRangeCell, lastSelectedDirectionCell, lastSelectedSpeedCell;
@synthesize resultBackgroundView;
@synthesize resultReticleView;
@synthesize resultBulletImpactImage;
@synthesize nightMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // TODO change object from NSString to BallisticProfile
    self.title = (NSString*)self.selectedProfile;
}

-(void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"DidAppear %@ - %@ - %@", [defaults objectForKey:@"rangeStart"], [defaults objectForKey:@"rangeEnd"], [defaults objectForKey:@"rangeStep"]);
}

-(void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"WillAppear %@ - %@ - %@", [defaults objectForKey:@"rangeStart"], [defaults objectForKey:@"rangeEnd"], [defaults objectForKey:@"rangeStep"]);
    int rangeStart       = [[defaults objectForKey:@"rangeStart"] intValue] ? [[defaults objectForKey:@"rangeStart"] intValue] : 100;
    int rangeEnd         = [[defaults objectForKey:@"rangeEnd"] intValue] ? [[defaults objectForKey:@"rangeEnd"] intValue] : 1200;
    int rangeStep        = [[defaults objectForKey:@"rangeStep"] intValue] ? [[defaults objectForKey:@"rangeStep"] intValue] : 25;
    self.rangeLabel.text = [[defaults objectForKey:@"rangeUnitsControl"] intValue] == 0 ? @"Yards" : @"Meters";
    
    // TODO set up defaults for direction type
    // TODO set up defaults for speed type/units
    
    
    // array of Ranges:  pad front and bad to get proper pickerview from tableview
    arrayRanges = [[NSMutableArray alloc] initWithObjects:@"", @"", nil];
    for(int range = rangeStart; range <= rangeEnd; range += rangeStep)
        [arrayRanges addObject:[NSString stringWithFormat:@"%d", range]];
    [arrayRanges addObject:@""];
    [arrayRanges addObject:@""];
    
    // array of Directions
    arrayDirections = [[NSMutableArray alloc] init];
    switch ([[defaults objectForKey:@"directionType"] intValue]) {
        case 0:          // degrees
            for(int degree = 0; degree < 360; degree += 10)
                [arrayDirections addObject:[NSString stringWithFormat:@"%d°", degree]];
            break;
        case 1:          // clock
            [arrayDirections addObject:@"12 o'clock"];
            for(int clock = 1; clock < 12; clock++)
                [arrayDirections addObject:[NSString stringWithFormat:@"%d o'clock", clock]];
            break;
        case 2:          // cardinal
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
    switch ([[defaults objectForKey:@"directionType"] intValue]) {
        case 0: // MPH || MPS || KPH || Knots
            for (int speed = 0; speed < 25; speed++)
                [arraySpeeds addObject:[NSString stringWithFormat:@"%d", speed]];
            break;
        case 1: // human speed
            [arraySpeeds addObject:@"At Rest"];
            [arraySpeeds addObject:@"Walking"];
            [arraySpeeds addObject:@"Jogging"];
            [arraySpeeds addObject:@"Running"];
            break;
        default:
            break;
    }

    [rangesTableView reloadData];
    [directionsTableView reloadData];
    [speedTableView reloadData];
    
    self.nightMode = [[defaults objectForKey:@"nightModeControl"] intValue];
    if (nightMode) {
        rangesTableView.backgroundColor = directionsTableView.backgroundColor = speedTableView.backgroundColor = resultBackgroundView.backgroundColor = [UIColor blackColor];
        resultReticleView.image = [UIImage imageNamed:@"mil_dot_reticle_night"];
        dropLabel.textColor = driftLabel.textColor = dropResultLabel.textColor = driftResultLabel.textColor = rangeLabel.textColor = directionLabel.textColor = speedLabel.textColor = tableBackgroundImage.backgroundColor = [UIColor colorWithRed:0.603 green:0.000 blue:0.000 alpha:1.000];
        rangeLabel.shadowColor = directionLabel.shadowColor = speedLabel.shadowColor = [UIColor redColor];
    } else {
        rangesTableView.backgroundColor = directionsTableView.backgroundColor = speedTableView.backgroundColor = resultBackgroundView.backgroundColor = [UIColor whiteColor];
        resultReticleView.image = [UIImage imageNamed:@"mil_dot_reticle_day"];
        dropLabel.textColor = driftLabel.textColor = dropResultLabel.textColor = driftResultLabel.textColor = [UIColor blackColor];
        rangeLabel.textColor = directionLabel.textColor = speedLabel.textColor = tableBackgroundImage.backgroundColor = [UIColor lightGrayColor];
        rangeLabel.shadowColor = directionLabel.shadowColor = speedLabel.shadowColor = [UIColor whiteColor];
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
    [self setDropLabel:nil];
    [self setDriftLabel:nil];
    [self setDropResultLabel:nil];
    [self setDriftResultLabel:nil];
    [self setResultBulletImpactImage:nil];
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
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
    
    // pseudo random drop
    float drop_pixels = range/1200.0 * 5 * PIXELS_PER_MIL;
    
    // pseudo random drift
    float drift_pixels = range/1200.0 * 5 * speed/25.0 * PIXELS_PER_MIL;

    self.resultBulletImpactImage.center = CGPointMake(160 +drift_pixels, 74 + drop_pixels);
        
    NSLog(@"Drop: %f\tDrift: %f", drop_pixels, drift_pixels);
}

@end
