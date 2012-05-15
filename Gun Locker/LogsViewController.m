//
//  LogsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogsViewController.h"

@implementation LogsViewController
@synthesize maintenanceCountLabel = _maintenanceCountLabel;
@synthesize malfunctionCountLabel = _malfunctionCountLabel;
@synthesize dopeCardsCountLabel = _dopeCardsCountLabel;
@synthesize magazineCountLabel = _magazineCountLabel;
@synthesize ammunitionCountLabel = _ammunitionCountLabel;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNumber *magazineCount     = [Magazine aggregateOperation:@"sum:" onAttribute:@"count" withPredicate:nil];
    NSNumber *ammunitionCount   = [Ammunition aggregateOperation:@"sum:" onAttribute:@"count" withPredicate:nil];
    
    _maintenanceCountLabel.text = [[Maintenance numberOfEntities] stringValue];
    _malfunctionCountLabel.text = [[Malfunction numberOfEntities] stringValue];
    _dopeCardsCountLabel.text   = [[DopeCard numberOfEntities] stringValue];
    _magazineCountLabel.text    = [NSString stringWithFormat:@"%@ total", magazineCount];
    _ammunitionCountLabel.text  = [NSString stringWithFormat:@"%@ total", ammunitionCount];
 }

- (void)viewDidUnload {
    [self setMalfunctionCountLabel:nil];
    [self setMaintenanceCountLabel:nil];
    [self setDopeCardsCountLabel:nil];
    [self setAmmunitionCountLabel:nil];
    [self setMagazineCountLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table delegates
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 24)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
	label.shadowColor = [UIColor clearColor];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
}

@end
