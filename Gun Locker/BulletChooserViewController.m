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
@synthesize collation, sectionsArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bullet List";
    
    bullets = [Bullet findAllSortedBy:@"diameter_inches" ascending:YES];
    
    selectedIndex = [bullets indexOfObject:self.selectedBullet];
    
    [self configureSections];
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setSearchResults:nil];
    [self setCollation:nil];
    [self setSectionsArray:nil];
    [self setSearchDisplayController:nil];
    [self setSelectedBullet:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (tableView == self.searchDisplayController.searchResultsTableView) ? 1 : [[collation sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults count] : [[sectionsArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(([[self.sectionsArray objectAtIndex:section] count] == 0) || (tableView == self.searchDisplayController.searchResultsTableView)) {
        return nil;
    } else {
        return [[collation sectionTitles] objectAtIndex:section];
    }
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BulletChooserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    Bullet *bullet = (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ (%@)", bullet.brand, bullet.name, bullet.category];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    NSMutableString *bc = [[NSMutableString alloc] init];
    if ([bullet.ballistic_coefficient objectForKey:@"G1"])
        [bc appendFormat:@"G1 %@ ", [[bullet.ballistic_coefficient objectForKey:@"G1"] objectAtIndex:0]];
    
    if ([bullet.ballistic_coefficient objectForKey:@"G7"])
        [bc appendFormat:@"G7 %@ ", [bullet.ballistic_coefficient objectForKey:@"G7"]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\" %@ gr (BC %@)", bullet.diameter_inches, bullet.weight_grains, bc];
    [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];    
    cell.accessoryType = ([bullet isEqual:self.selectedBullet]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

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
	for (NSString *bullet in bullets) {
		// Ask the collation which section number the time zone belongs in, based on its locale name.
		NSInteger sectionNumber = [collation sectionForObject:bullet collationStringSelector:@selector(category)];
		
		// Get the array for the section.
		NSMutableArray *sectionBullets = [newSectionsArray objectAtIndex:sectionNumber];
		
		//  Add the manufacturer to the section.
		[sectionBullets addObject:bullet];
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
	
	self.sectionsArray = newSectionsArray;    
}

- (void)filterContentForSearchText:(NSString*)searchText  scope:(NSString*)scope { 
    self.searchResults = [bullets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@)", searchText]];
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
    
    Bullet *bullet = (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    // notify profileAddEdit of selected bullet
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedBullet" object:bullet];
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark AlertView

- (void) manuallyEnterBulletTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Manual Bullet Entry"
                                                    message:@"\n\n\n"
                                                   delegate:self 
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];

    weightField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 30.0)];
    ballisticCoefficientField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0, 260.0, 30.0)];
    weightField.placeholder = @"Weight in grains";
    ballisticCoefficientField.placeholder = @"Ballistic coefficient";
    weightField.contentVerticalAlignment = ballisticCoefficientField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    weightField.backgroundColor = ballisticCoefficientField.backgroundColor = [UIColor whiteColor];
    ballisticCoefficientField.keyboardType = UIKeyboardTypeDecimalPad;
    weightField.keyboardType = UIKeyboardTypeNumberPad;
    weightField.keyboardAppearance = ballisticCoefficientField.keyboardAppearance = UIKeyboardAppearanceAlert;
    weightField.clearButtonMode = ballisticCoefficientField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [alert addSubview:weightField];
    [alert addSubview:ballisticCoefficientField];

    [weightField becomeFirstResponder];
        
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
    } else if (([weightField.text intValue] == 0) || ([ballisticCoefficientField.text floatValue]) == 0.0) {
        [self manuallyEnterBulletTapped:nil];
    } else {
        // nsnotify manually entered bullet info
        [[NSNotificationCenter defaultCenter] postNotificationName:@"manuallyEnteredBullet" object:[NSArray arrayWithObjects:[NSNumber numberWithInt:weightField.text.intValue], [NSDecimalNumber decimalNumberWithString:ballisticCoefficientField.text], nil]];

        [self.navigationController popViewControllerAnimated:YES];
    }    
}

@end
