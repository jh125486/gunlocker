//
//  CaliberChooserViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CaliberChooserViewController.h"

@implementation CaliberChooserViewController
{
	NSMutableArray *calibers;
	NSUInteger selectedIndex;
}

@synthesize delegate;
@synthesize selectedCaliber;
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize searchResults;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // load calibers from file
    NSString* path = [[NSBundle mainBundle] pathForResource:@"calibers" ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    calibers = [[content componentsSeparatedByString:@"\n"] mutableCopy];
    
    if([self.selectedCaliber length] > 0 && ![calibers containsObject:self.selectedCaliber])
        [calibers insertObject:self.selectedCaliber atIndex:0];
    
    selectedIndex = [calibers indexOfObject:self.selectedCaliber];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)filterContentForSearchText:(NSString*)searchText  scope:(NSString*)scope {
    self.searchResults = [calibers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [calibers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SimpleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [calibers objectAtIndex:indexPath.row];
    }
    
    if ([cell.textLabel.text isEqualToString:self.selectedCaliber])
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (selectedIndex != NSNotFound)
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = indexPath.row;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    [self.delegate caliberChooserViewController:self didSelectCaliber:cell.textLabel.text];
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
