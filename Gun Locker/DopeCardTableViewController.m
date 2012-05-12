//
//  DopeCardViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardTableViewController.h"

@implementation DopeCardTableViewController
@synthesize dopeCardSectionHeaderView;
@synthesize weaponLabel;
@synthesize zeroLabel;
@synthesize mvLabel;
@synthesize weatherLabel;
@synthesize windInfoLabel;
@synthesize leadInfoLabel;
@synthesize notesLabel;
@synthesize rangeLabel;
@synthesize dropLabel;
@synthesize driftLabel;
@synthesize selectedDopeCard = _dopeCard;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Register updateDopeCard to receive "editedDopeCard" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDopeCard:) name:@"editedDopeCard" object:nil];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDopeCard];
    
}

- (void)loadDopeCard {
    self.title = _dopeCard.name;
    self.weaponLabel.text = _dopeCard.weapon.description;
    if (_dopeCard.zero.length > 0) self.zeroLabel.text = [NSString stringWithFormat:@"%@ %@", _dopeCard.zero, _dopeCard.range_unit];
    if (_dopeCard.muzzle_velocity.length > 0) self.mvLabel.text = [_dopeCard.muzzle_velocity stringByAppendingString:@" fps"];
    if (_dopeCard.weather_info.length > 0) self.weatherLabel.text = _dopeCard.weather_info;
    if (_dopeCard.wind_info.length > 0) self.windInfoLabel.text = _dopeCard.wind_info;
    if (_dopeCard.lead_info.length > 0) self.leadInfoLabel.text = _dopeCard.lead_info;
    if (_dopeCard.notes.length > 0) self.notesLabel.text = _dopeCard.notes;
    self.rangeLabel.text = _dopeCard.range_unit;
    self.dropLabel.text  = _dopeCard.drop_unit;
    self.driftLabel.text = _dopeCard.drift_unit;
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setWeaponLabel:nil];
    [self setZeroLabel:nil];
    [self setMvLabel:nil];
    [self setWeatherLabel:nil];
    [self setWindInfoLabel:nil];
    [self setLeadInfoLabel:nil];
    [self setNotesLabel:nil];
    [self setRangeLabel:nil];
    [self setDropLabel:nil];
    [self setDriftLabel:nil];
    [self setDopeCardSectionHeaderView:nil];
    [self setWeatherLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"EditDopeCard"]) {
        DopeCardsAddEditViewController *dst = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        dst.selectedDopeCard = _dopeCard;
    }
}

// can only add dopeCard from weapon view, so no worry about updating sections
- (void) updateDopeCard:(NSNotification*) notification {
    _dopeCard = [notification object];
    
    NSError *error;
    if(![[NSManagedObjectContext defaultContext] save:&error]) {
        NSLog(@"error updating DopeCard");
    } else {
        NSLog(@"Updated DopeCard");
    }    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dopeCard.dope_data count]/3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DopeCardRowCell";
    DopeCardRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(DopeCardRowCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.row * 3;
    cell.rangeLabel.text = [_dopeCard.dope_data objectAtIndex:index + 0];
    cell.dropLabel.text  = [_dopeCard.dope_data objectAtIndex:index + 1];
    cell.driftLabel.text = [_dopeCard.dope_data objectAtIndex:index + 2];
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

@end
