//
//  BulletChooserViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BulletChooserViewController.h"

@implementation BulletChooserViewController
@synthesize selectedBullet;
@synthesize searchDisplayController, searchBar, searchResults;
@synthesize collation;
@synthesize selectedCategory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.selectedCategory) {
        self.title = @"Bullet Categories";
        categories = [[NSCountedSet alloc] init];
        for(Bullet *bullet in [Bullet findAllSortedBy:@"diameter_inches" ascending:YES])
            [categories addObject:bullet.category];
        items = [[categories allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    } else {
        self.title = self.selectedCategory;
        items = [Bullet findAllSortedBy:@"diameter_inches" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"category == %@", self.selectedCategory]];
        selectedIndex = [items indexOfObject:self.selectedBullet];
    }
    
    [self configureSections];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSearchBar:nil];
    [self setSearchResults:nil];
    [self setCollation:nil];
    [self setSearchDisplayController:nil];
    [self setSelectedBullet:nil];
    [self setSelectedCategory:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BulletChooserLoopBack"]) {
        if (self.selectedCategory) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            if (selectedIndex != NSNotFound) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            selectedIndex = indexPath.row;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            selectedBullet = (self.tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];        
            
            if ([self.selectedBullet.ballistic_coefficient objectForKey:@"G1"] && [self.selectedBullet.ballistic_coefficient objectForKey:@"G7"]) {
                [[[UIActionSheet alloc] initWithTitle:@"Choose Drag Model"
                                             delegate:self
                                    cancelButtonTitle:nil
                               destructiveButtonTitle:nil
                                    otherButtonTitles:@"G7", @"G1", nil] showInView:[UIApplication sharedApplication].keyWindow];
            } else if ([self.selectedBullet.ballistic_coefficient objectForKey:@"G1"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedDragModel" object:@"G1"];
                [self bulletChosen];            
            } else if ([self.selectedBullet.ballistic_coefficient objectForKey:@"G7"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedDragModel" object:@"G7"];
                [self bulletChosen];
            }
        } else {
            BulletChooserViewController* section = segue.destinationViewController;
            UITableViewCell* cell = (UITableViewCell*)sender;
            section.selectedCategory = cell.textLabel.text;
            section.selectedBullet = self.selectedBullet;
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Categories" style:UIBarButtonItemStyleBordered target:nil action:nil];
        }
    }
}

#pragma mark Tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (tableView == self.searchDisplayController.searchResultsTableView) ? 1 : [[collation sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults count] : [[sections objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(([[sections objectAtIndex:section] count] == 0) || (tableView == self.searchDisplayController.searchResultsTableView)) {
        return nil;
    } else {
        return [[collation sectionTitles] objectAtIndex:section];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableViewHeaderViewPlain *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewPlain" 
                                                                          owner:self 
                                                                        options:nil] 
                                            objectAtIndex:0];
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        // prepends a Search icon to all indexTitles
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }        
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (title == UITableViewIndexSearch) {
        CGRect searchBarFrame = self.searchDisplayController.searchBar.frame;
        [tableView scrollRectToVisible:searchBarFrame animated:YES];
        return -1;
    } else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index - 1];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BulletChooserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    if (self.selectedCategory) {
        Bullet *bullet = (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

        NSMutableString *cellText = [[NSMutableString alloc] init];
        if (![bullet.brand isEqualToString:bullet.category]) [cellText appendFormat:@"%@ ", bullet.brand];
        [cellText appendString:bullet.name];
        cell.textLabel.text = cellText;
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
        NSMutableString *bc = [[NSMutableString alloc] init];
        if ([bullet.ballistic_coefficient objectForKey:@"G1"])
            [bc appendFormat:@"G1 %@ ", [[bullet.ballistic_coefficient objectForKey:@"G1"] objectAtIndex:0]];
        
        if ([bullet.ballistic_coefficient objectForKey:@"G7"])
            [bc appendFormat:@"G7 %@ ", [[bullet.ballistic_coefficient objectForKey:@"G7"] objectAtIndex:0]];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\" %@ gr (BC %@)", bullet.diameter_inches, bullet.weight_grains, bc];
        [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];    
        cell.accessoryType = ([bullet isEqual:self.selectedBullet]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        NSString *category = (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text = category;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Bullets", [categories countForObject:category]];
    }
        
    return cell;
}

- (void)configureSections {
    self.collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger index, sectionTitlesCount = [[collation sectionTitles] count];
	NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];

    // Set up the sections array: elements are mutable arrays that will contain the categories/bullets for that section.
	for (index = 0; index < sectionTitlesCount; index++)
		[newSectionsArray addObject:[[NSMutableArray alloc] init]];

    // Segregate the categories/bullets into the appropriate arrays.
    // Ask the collation which section number the object belongs in, based on its locale name.
    // Get the array for the section.            
    //  Add the bullet to the section.
    if (self.selectedCategory) {
        for (Bullet *bullet in items) {
            if ([bullet.brand isEqualToString:bullet.category]) {
                [[newSectionsArray objectAtIndex:[collation sectionForObject:bullet collationStringSelector:@selector(name)]] addObject:bullet];            
            } else {
                [[newSectionsArray objectAtIndex:[collation sectionForObject:bullet collationStringSelector:@selector(brand)]] addObject:bullet];
            }
        }
    } else {
        for (NSString *category in items) {
            [[newSectionsArray objectAtIndex:[collation sectionForObject:category collationStringSelector:@selector(description)]] addObject:category];
        }
    }
    
//// no need to sort because of the findAllSortedby 
//	for (index = 0; index < sectionTitlesCount; index++) {
//		
//		NSMutableArray *bulletsForSection = [newSectionsArray objectAtIndex:index];
//		
//		// If the table view or its contents were editable, you would make a mutable copy here.
////		NSArray *sortedBulletsForSection = [collation sortedArrayFromArray:bulletsForSection collationStringSelector:@selector(name)];
//        NSArray *sortedBulletsForSection = [bulletsForSection sortedArrayUsingSelector:@selector(weight_grains)];
//		// Replace the existing array with the sorted array.
//		[newSectionsArray replaceObjectAtIndex:index withObject:sortedBulletsForSection];
//	}
	
	sections = newSectionsArray;    
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)filterContentForSearchText:(NSString*)searchText  scope:(NSString*)scope {
    if (self.selectedCategory) {
        self.searchResults = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@)", searchText]];
    } else{
        self.searchResults = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF contains[cd] %@)", searchText]];
    }
}

- (void)bulletChosen {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedBullet" object:selectedBullet];
    [self dismissModalViewControllerAnimated:YES];
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar {
    [UIView animateWithDuration:.2f animations:^{
        CGRect theFrame = self.searchBar.superview.frame;
        theFrame.origin.y = 0.f;
        self.searchBar.superview.frame = theFrame;
    }];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [UIView animateWithDuration:.2f animations:^{
        CGRect theFrame = self.searchBar.superview.frame;
        theFrame.origin.y = 86.f;
        self.searchBar.superview.frame = theFrame;
    }];
    return YES;
}

#pragma mark ActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedDragModel" object:(buttonIndex == 0) ? @"G7" : @"G1"];
    [self bulletChosen];
}

@end
