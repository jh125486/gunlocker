//
//  ManufacturerChooserViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManufacturerChooserViewController.h"

@implementation ManufacturerChooserViewController
@synthesize delegate;
@synthesize selectedManufacturer;
@synthesize searchDisplayController, searchBar, searchResults;
@synthesize collation, sectionsArray;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

//    // scroll searchbar out of view
//    self.tableView.contentOffset = CGPointMake(0.0f, 44.0f);
    
    manufacturers = [Manufacturer findAllSortedBy:@"name" ascending:YES];
    
    selectedIndex = [manufacturers indexOfObject:self.selectedManufacturer];

    [self configureSections];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return [[collation sectionTitles] count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [[sectionsArray objectAtIndex:section] count];
    }
}

#pragma TableView methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(([[self.sectionsArray objectAtIndex:section] count] == 0) || 
       (tableView == self.searchDisplayController.searchResultsTableView)) {
        return nil;
    } else {
        return [[collation sectionTitles] objectAtIndex:section];
    }
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section] == nil) ? 0.f : 23.f;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }        
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (title == UITableViewIndexSearch) {
        CGRect searchBarFrame = self.searchDisplayController.searchBar.frame;
        [tableView scrollRectToVisible:searchBarFrame animated:YES];
        return -1;
    } else {
        UILocalizedIndexedCollation *currentCollation = [UILocalizedIndexedCollation currentCollation];
        return [currentCollation sectionForSectionIndexTitleAtIndex:index - 1];
    }
    
//    if(tableView == self.searchDisplayController.searchResultsTableView)
//        return -1;
//    
//    return [collation sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ManufacturerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    Manufacturer *manufacturer = (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = manufacturer.name;
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    cell.detailTextLabel.text = manufacturer.country;
    
    cell.accessoryType = ([manufacturer isEqual:self.selectedManufacturer]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}


- (void)configureSections {
    self.collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];

    // Set up the sections array: elements are mutable arrays that will contain the manufacturers for that section.
	for (index = 0; index < sectionTitlesCount; index++)
		[newSectionsArray addObject:[[NSMutableArray alloc] init]];

    // Segregate the manufacturers into the appropriate arrays.
	for (NSString *manufacturer in manufacturers) {
		// Ask the collation which section number the time zone belongs in, based on its locale name.
		NSInteger sectionNumber = [collation sectionForObject:manufacturer collationStringSelector:@selector(name)];
		
		// Get the array for the section.
		NSMutableArray *sectionManufacturers = [newSectionsArray objectAtIndex:sectionNumber];
		
		//  Add the manufacturer to the section.
		[sectionManufacturers addObject:manufacturer];
	}
    
    
    // XXX possible not needed since data is already sorted from fetch
    // Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {
		
		NSMutableArray *manufacturersForSection = [newSectionsArray objectAtIndex:index];
		
		// If the table view or its contents were editable, you would make a mutable copy here.
		NSArray *sortedManufacturersForSection = [collation sortedArrayFromArray:manufacturersForSection collationStringSelector:@selector(name)];
		
		// Replace the existing array with the sorted array.
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedManufacturersForSection];
	}
	
	self.sectionsArray = newSectionsArray;    
}

- (void)filterContentForSearchText:(NSString*)searchText  scope:(NSString*)scope { 
    self.searchResults = [manufacturers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (short_name contains[cd] %@)", searchText, searchText]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (selectedIndex != NSNotFound) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = indexPath.row;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    Manufacturer *manufacturer = (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    [self.delegate manufacturerChooserViewController:self didSelectManufacturer:manufacturer];
}

#pragma mark - UISearchDisplayController delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

@end
