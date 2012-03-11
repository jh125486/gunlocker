//
//  ManufacturerChooserViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManufacturerChooserViewController.h"
#import "Manufacturer.h"

@implementation ManufacturerChooserViewController
{
	NSArray *manufacturers;
	NSUInteger selectedIndex;
}

@synthesize managedObjectContext;
@synthesize delegate;
@synthesize selectedManufacturer;
@synthesize searchDisplayController;
@synthesize searchBar;
@synthesize searchResults;
@synthesize collation;
@synthesize sectionsArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // scroll searchbar out of view
    self.tableView.contentOffset = CGPointMake(0.0f, 44.0f);
    
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];    
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Manufacturer" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:nil];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    manufacturers = [managedObjectContext executeFetchRequest:request error:&error];
    
    if([manufacturers count] == 0) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"manufacturers" ofType:@"txt"];
        NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        
        for (NSString *manufacturer in [content componentsSeparatedByString:@"\n"]) {
            NSArray *splitParts = [manufacturer componentsSeparatedByString:@":"];
            
            Manufacturer *tManufacturer = [NSEntityDescription insertNewObjectForEntityForName:@"Manufacturer" inManagedObjectContext:managedObjectContext];
            tManufacturer.name = [splitParts objectAtIndex:0];
            tManufacturer.country = [splitParts objectAtIndex:1];
            
        }   
        NSError *error = nil;
        if (![managedObjectContext save:&error])
            NSLog(@"%@", [error localizedDescription]);
        // reload manufacturers
        manufacturers = [managedObjectContext executeFetchRequest:request error:&error];
    }
    
    // dont think selectedIndex matters anywhere
    //selectedIndex = [manufacturers indexOfObject:self.selectedManufacturer];

    [self configureSections];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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

/*
 Section-related methods: Retrieve the section titles and section index titles from the collation.
 */
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SimpleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[self.searchResults objectAtIndex:indexPath.row] name];
        cell.detailTextLabel.text = [[self.searchResults objectAtIndex:indexPath.row] country];
    } else {        
        cell.textLabel.text = [[[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name];
        cell.detailTextLabel.text = [[[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] country];
    }
    
    if ([cell.textLabel.text isEqualToString:self.selectedManufacturer])
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}


- (void)configureSections
{
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
    
    // add the selected manufacturer to the collation if not empty and not found in manufacturers
    if([self.selectedManufacturer length] != 0) {
        if([[manufacturers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", self.selectedManufacturer]] count] == 0) {
            NSLog(@"Manufacturer not found");            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Manufacturer" inManagedObjectContext:self.managedObjectContext];
            Manufacturer *tManufacturer = (Manufacturer *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
            
            tManufacturer.name = self.selectedManufacturer;

            NSInteger sectionNumber = [collation sectionForObject:tManufacturer collationStringSelector:@selector(name)];		
            [[newSectionsArray objectAtIndex:sectionNumber] addObject:tManufacturer];
        }
    }
    
    // Now that all the data's in place, each section array needs to be sorted.
	for (index = 0; index < sectionTitlesCount; index++) {
		
		NSMutableArray *manufacturersForSection = [newSectionsArray objectAtIndex:index];
		
		// If the table view or its contents were editable, you would make a mutable copy here.
		NSArray *sortedmanufacturersForSection = [collation sortedArrayFromArray:manufacturersForSection collationStringSelector:@selector(name)];
		
		// Replace the existing array with the sorted array.
		[newSectionsArray replaceObjectAtIndex:index withObject:sortedmanufacturersForSection];
	}
	
	self.sectionsArray = newSectionsArray;    
}

- (void)filterContentForSearchText:(NSString*)searchText  scope:(NSString*)scope
{    
    self.searchResults = [manufacturers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText]];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [[[sectionsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] name];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (selectedIndex != NSNotFound)
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = indexPath.row;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.delegate manufacturerChooserViewController:self didSelectManufacturer:cell.textLabel.text];
}

#pragma mark - UISearchDisplayController delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] 
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

@end
