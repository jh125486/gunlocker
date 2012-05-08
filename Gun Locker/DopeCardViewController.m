//
//  DopeCardViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardViewController.h"

@implementation DopeCardViewController
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
@synthesize tableView;
@synthesize selectedDopeCard;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = selectedDopeCard.name;
    self.weaponLabel.text = selectedDopeCard.weapon.description;
    self.zeroLabel.text = [NSString stringWithFormat:@"%@ %@", selectedDopeCard.zero, selectedDopeCard.range_unit];
    self.mvLabel.text   = [NSString stringWithFormat:@"%@ fps",selectedDopeCard.muzzle_velocity];
    self.weatherLabel.text = selectedDopeCard.weather_info;
    self.windInfoLabel.text = selectedDopeCard.wind_info;
    self.leadInfoLabel.text = selectedDopeCard.lead_info;
    self.notesLabel.text = selectedDopeCard.notes;
    self.rangeLabel.text = selectedDopeCard.range_unit;
    self.dropLabel.text  = selectedDopeCard.drop_unit;
    self.driftLabel.text = selectedDopeCard.drift_unit;
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
    [self setTableView:nil];
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
        dst.selectedDopeCard = self.selectedDopeCard;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [selectedDopeCard.dope_data count]/3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DopeCardRowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DopeCardRowCell"];
    
    cell.rangeLabel.text = [selectedDopeCard.dope_data objectAtIndex:(indexPath.row * 3) + 0];
    cell.dropLabel.text  = [selectedDopeCard.dope_data objectAtIndex:(indexPath.row * 3) + 1];
    cell.driftLabel.text = [selectedDopeCard.dope_data objectAtIndex:(indexPath.row * 3) + 2];
        
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

@end
