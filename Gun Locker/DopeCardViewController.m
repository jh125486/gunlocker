//
//  DopeCardViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardViewController.h"

@implementation DopeCardViewController
@synthesize weaponLabel;
@synthesize zeroLabel;
@synthesize windInfoLabel;
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
    self.weaponLabel.text = selectedDopeCard.weapon.model;
    NSString *zero_unit = selectedDopeCard.range_unit;
    zero_unit = ([zero_unit isEqualToString:@"Feet"]) ? @"foot": [[zero_unit substringToIndex:[zero_unit length] -1] lowercaseString];
    self.zeroLabel.text = [NSString stringWithFormat:@"%@ %@ zero", selectedDopeCard.zero, zero_unit];
    self.windInfoLabel.text = selectedDopeCard.wind_info;
    self.notesLabel.text = selectedDopeCard.notes;
    self.rangeLabel.text = selectedDopeCard.range_unit;
    self.dropLabel.text  = selectedDopeCard.drop_unit;
    self.driftLabel.text = selectedDopeCard.drift_unit;
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setZeroLabel:nil];
    [self setWindInfoLabel:nil];
    [self setNotesLabel:nil];
    [self setTableView:nil];
    [self setRangeLabel:nil];
    [self setDropLabel:nil];
    [self setDriftLabel:nil];
    [self setWeaponLabel:nil];
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
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor lightTextColor];
}  

@end
