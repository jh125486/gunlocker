//
//  DopeCardViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardTableViewController.h"

@implementation DopeCardTableViewController
@synthesize infoView = _infoView;
@synthesize dopeCardSectionHeaderView = _dopeCardSectionHeaderView;
@synthesize weaponLabel = _weaponLabel;
@synthesize zeroLabel = _zeroLabel;
@synthesize mvLabel = _mvLabel;
@synthesize weatherLabel = _weatherLabel;
@synthesize windInfoLabel = _windInfoLabel;
@synthesize leadInfoLabel = _leadInfoLabel;
@synthesize notesLabel = _notesLabel;
@synthesize rangeLabel = _rangeLabel;
@synthesize dropLabel = _dropLabel;
@synthesize driftLabel = _driftLabel;
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
    dataManager = [DataManager sharedManager];
    
    //Register updateDopeCard to receive "editedDopeCard" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDopeCard:) name:@"editedDopeCard" object:nil];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDopeCard];
    
}

- (void)loadDopeCard {
    self.title = _dopeCard.name;
    _weaponLabel.text = _dopeCard.weapon.description;
    if (_dopeCard.zero.length > 0) _zeroLabel.text = [NSString stringWithFormat:@"%@ %@", 
                                                      _dopeCard.zero, 
                                                      [dataManager.rangeUnits objectAtIndex:_dopeCard.zero_unit.intValue]];
    if (_dopeCard.muzzle_velocity.length > 0) _mvLabel.text = [_dopeCard.muzzle_velocity stringByAppendingString:@" fps"];
    if (_dopeCard.weather_info.length > 0) _weatherLabel.text = _dopeCard.weather_info;
    if (_dopeCard.wind_info.length > 0) _windInfoLabel.text = _dopeCard.wind_info;
    if (_dopeCard.lead_info.length > 0) _leadInfoLabel.text = _dopeCard.lead_info;
    if (_dopeCard.notes.length > 0) _notesLabel.text = _dopeCard.notes;
    _rangeLabel.text = _dopeCard.range_unit;
    _dropLabel.text  = _dopeCard.drop_unit;
    _driftLabel.text = _dopeCard.drift_unit;
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
    [self setInfoView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {    
    [self.tableView setContentOffset:CGPointMake(0.f, _infoView.isHidden ? CGRectGetHeight(_infoView.frame) : 0.f) animated:YES];
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
    
    [[DataManager sharedManager] saveAppDatabase];
}

- (IBAction)infoViewTapped:(id)sender {
    _infoView.hidden = !_infoView.hidden;
    [self.tableView setContentOffset:CGPointMake(0.f, _infoView.isHidden ? CGRectGetHeight(_infoView.frame) : 0.f) animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray *)_dopeCard.dope_data count]/3;
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
    return _dopeCardSectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(_dopeCardSectionHeaderView.frame);
}

@end
