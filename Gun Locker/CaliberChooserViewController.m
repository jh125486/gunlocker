//
//  CaliberChooserViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CaliberChooserViewController.h"

@implementation CaliberChooserViewController

@synthesize delegate = _delegate;
@synthesize selectedCaliber = _selectedCaliber;
@synthesize searchDisplayController;
@synthesize searchWasActive = _searchWasActive, savedSearchTerm = _savedSearchTerm, savedScopeButtonIndex = _savedScopeButtonIndex;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    _searchWasActive       = [self.searchDisplayController isActive];
    _savedSearchTerm       = [self.searchDisplayController.searchBar text];
    _savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.frame = CGRectMake(0,self.searchDisplayController.searchBar.bounds.size.height,320,480);
    
    if (_savedSearchTerm) {
        [self.searchDisplayController setActive:_searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:_savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        _savedSearchTerm = nil;
    }
    
    sections = [[NSArray alloc] initWithObjects:@"Rimfire", @"Handgun", @"Rifle", @"Shotgun", nil];
    NSMutableArray *calibersTemp = [[NSMutableArray alloc] initWithCapacity:[sections count]];
    for (NSString *section in sections) {
        [calibersTemp addObject:[Caliber findAllSortedBy:@"diameter_inches" 
                                            ascending:YES 
                                        withPredicate:[NSPredicate predicateWithFormat:@"type = %@", section]]];
    }
    calibers = [[NSArray alloc] initWithArray:calibersTemp];    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    // save the state of the search UI so that it can be restored if the view is re-created
    _searchWasActive       = [self.searchDisplayController isActive];
    _savedSearchTerm       = [self.searchDisplayController.searchBar text];
    _savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)viewDidUnload {
    [self setSavedSearchTerm:nil];
    [self setDelegate:nil];
    [self setSelectedCaliber:nil];
    [self setSearchDisplayController:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

// helper to determine correct caliber
- (Caliber *)caliberForTableView:(UITableView *)tableView andIndexPath:(NSIndexPath*)indexPath {
    NSArray *caliberArray = tableView == self.tableView ? [calibers objectAtIndex:indexPath.section] : searchResults;
    return [caliberArray objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView == self.tableView ? [calibers count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.tableView ? [[calibers objectAtIndex:section] count] : [searchResults count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return tableView == self.tableView ? [sections objectAtIndex:section] : nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *header = [self tableView:tableView titleForHeaderInSection:section];
    if (header == nil) return nil;
    TableViewHeaderViewPlain *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewPlain" 
                                                                          owner:self 
                                                                        options:nil] 
                                            objectAtIndex:0];
    headerView.headerTitleLabel.text = header;
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CaliberCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    [self configureCell:cell withCaliber:[self caliberForTableView:tableView andIndexPath:indexPath]];	
    return cell;
}

-(void)configureCell:(UITableViewCell*)cell withCaliber:(Caliber*)caliber {
    cell.textLabel.text = caliber.name;
    cell.detailTextLabel.text = caliber.type;
    cell.accessoryType = [cell.textLabel.text isEqualToString:_selectedCaliber] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    [_delegate caliberChooserViewController:self didSelectCaliber:cell.textLabel.text];
}

#pragma mark - UISearchDisplayController delegate methods

-(void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    searchResults = nil;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString 
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:searchOption];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope {
    NSPredicate *filter;
    if (scope == 0) { // 'All'
        filter = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
    } else { // type of cartridge/shell
        filter = [NSPredicate predicateWithFormat:@"(type = %@) AND (name CONTAINS[cd] %@)", [sections objectAtIndex:scope -1], searchText];        
    }

    searchResults = [Caliber findAllSortedBy:@"diameter_inches" ascending:YES withPredicate:filter];
    self.savedScopeButtonIndex = scope;
}

@end
