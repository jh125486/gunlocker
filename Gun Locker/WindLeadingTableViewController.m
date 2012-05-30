//
//  WindLeadingTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindLeadingTableViewController.h"

@interface WindLeadingTableViewController () {
    NSIndexPath *selectedPath;
}
@end

@implementation WindLeadingTableViewController

@synthesize delegate;
@synthesize selectedWindLeading;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    selectedPath = [NSIndexPath indexPathForRow:[defaults integerForKey:@"speedIndexPathRow"] inSection:[defaults integerForKey:@"speedIndexPathSection"]];
    
    [[self.tableView cellForRowAtIndexPath:selectedPath] setAccessoryType:UITableViewCellAccessoryCheckmark];    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (selectedPath) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:selectedPath];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedPath = indexPath;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    DataManager *dataManager = [DataManager sharedManager];

    NSString *speedType = [dataManager.speedTypes objectAtIndex:indexPath.section];
    NSString *speedUnit = cell.textLabel.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:indexPath.row forKey:@"speedIndexPathRow"];
    [defaults setInteger:indexPath.section forKey:@"speedIndexPathSection"];
    
    [defaults setObject:speedType forKey:@"speedType"];
    [defaults setObject:speedUnit forKey:@"speedUnit"];
    
    [self.delegate windLeadingTableViewController:self didSelectWindLeading:[NSString stringWithFormat:@"%@ %@", speedType, speedUnit]];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableViewHeaderViewPlain *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewPlain" 
                                                                            owner:self 
                                                                          options:nil] 
                                              objectAtIndex:0];
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

@end
