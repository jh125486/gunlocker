//
//  CaliberChooserViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CaliberChooserViewController.h"
#import "DatabaseHelper.h"

@implementation CaliberChooserViewController
{
	NSMutableArray *calibers;
	NSUInteger selectedIndex;
}

@synthesize managedObjectContext;
@synthesize delegate;
@synthesize caliber;
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

    calibers = [NSMutableArray arrayWithObjects:
                    @".17 HMR",
                    @".17 Mach 2 HM2",
                    @".22 LR",
                    @".22 WMR",
                    @".22 Hornet",
                    @".25 Auto",
                    @".32 ACP",
                    @".32 H&R Magnum",
                    @".32 S&W Long",
                    @".32 Winchester Special",
                    @".357 Magnum",
                    @".357 SIG",
                    @".38 S&W",
                    @".38 Special",
                    @".38 Super",
                    @".380 ACP",
                    @"9mm Browning Long",
                    @"9mm Largo",
                    @"9×19mm Parabellum/Luger",
                    @"9x18mm Makarov",
                    @"9x23mm Win",
                    @".40 S&W",
                    @"10mm Auto",
                    @".41 Magnum",
                    @".44 Magnum",
                    @".44 Russian",
                    @".44 Special",
                    @".45 ACP",
                    @".45 Colt",
                    @".45 GAP",
                    @".50 AE",
                    @".204 Ruger",
                    @".22-250",
                    @".222 Remington",
                    @".223/5.56mm",
                    @".243 Winchester",
                    @".25-06 Remington",
                    @".270 WSM",
                    @".270 Winchester",
                    @".280 Remington",
                    @".30 Carbine",
                    @".30 Luger",
                    @".30-06 Springfield",
                    @".30-30 Winchester",
                    @".300 AAC Blackout",
                    @".300 WSM",
                    @".300 Win Mag",
                    @".303 British",
                    @".308/7.62x51",
                    @".327 Federal Magnum",
                    @".338 Federal",
                    @".338 Lapua",
                    @".45-70",
                    @".450 Bushmaster",
                    @".454 Casull",
                    @".458 SOCOM",
                    @".458 Win Mag",
                    @".480 Ruger",
                    @".50 BMG",
                    @".50 Beowulf",
                    @".500 S&W Magnum",
                    @"5.45x39mm",
                    @"5.7x28mm",
                    @"5mm Remington Magnum",
                    @"6.5 Carcano",
                    @"6.5 Grendel",
                    @"6.5x55",
                    @"6.8 SPC",
                    @"7.35 Carcano",
                    @"7.5 French",
                    @"7.5 Swiss",
                    @"7.62 Nagant",
                    @"7.62x25",
                    @"7.62x39mm",
                    @"7.62x45",
                    @"7.62x54R",
                    @"7.63 Mauser",
                    @"7.65 Argentine",
                    @"7.7 Arisaka",
                    @"7.92x33 Kurz",
                    @"7mm Rem Mag",
                    @"7mm WSM",
                    @"7mm Weatherby Magnum",
                    @"7x57 Mauser",
                    @"8 x 59 Breda",
                    @"8mm Mauser",
                    @"8x50R Lebel",
                    @"8x56R Steyr",
                    @"9.3x57",
                    @"9.3x62",
                    @"9.3x72R",
                    @"9.3x74R",
                    @".410 Gauge",
                    @"28 Gauge",
                    @"20 Gauge",
                    @"16 Gauge",
                    @"12 Gauge",
                    @"10 Gauge",
                    nil ];
    
    if([self.caliber length] > 0 && ![calibers containsObject:self.caliber])
        [calibers insertObject:self.caliber atIndex:0];
    
    selectedIndex = [calibers indexOfObject:self.caliber];
    NSLog(@"got here: %@ index:%d", self.caliber, selectedIndex);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    calibers = nil;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)filterContentForSearchText:(NSString*)searchText  scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    
    self.searchResults = [calibers filteredArrayUsingPredicate:resultPredicate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [calibers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CaliberCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [calibers objectAtIndex:indexPath.row];
    }
    
    if ([cell.textLabel.text isEqualToString:self.caliber])
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (selectedIndex != NSNotFound)
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = indexPath.row;
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    [self.delegate caliberChooserViewController:self didSelectCaliber:(cell.textLabel.text)];
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
