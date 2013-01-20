//
//  DopeCardsTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardsViewController.h"

@implementation DopeCardsViewController
@synthesize noDopeCardsImageView = _noDopeCardsImageView;
@synthesize tableView;
@synthesize selectedWeapon = _selectedWeapon;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataManager = [DataManager sharedManager];

    //Register addNewDopeCardToArray to recieve "addNewDopeCard" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDopeCard:) name:@"newDopeCard" object:nil];

    if (!_selectedWeapon) self.navigationItem.rightBarButtonItem = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self updateTitle];
}

- (void)updateTitle {
    int count = [_fetchedResultsController.fetchedObjects count];
    self.title = [NSString stringWithFormat:@"Dope Cards (%d)", count];
    
    _noDopeCardsImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Table/DopeCards"]];
    _noDopeCardsImageView.hidden = (count != 0);
    self.tableView.hidden = (count == 0);
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"ShowDopeCard"]) {
        DopeCardTableViewController *dst = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        dst.selectedDopeCard = [_fetchedResultsController objectAtIndexPath:indexPath];
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dope Cards" 
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:nil 
                                                                            action:nil];
}

// can only add dopeCard from weapon view, so no worry about updating sections
- (void) addNewDopeCard:(NSNotification*) notification {
    DopeCard *newDopeCard = [notification object];
    newDopeCard.weapon = _selectedWeapon;
    
    [[DataManager sharedManager] saveAppDatabase];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [_fetchedResultsController sectionIndexTitles];
}

# pragma mark UITableviewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [_fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DopeCardSummaryCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    DopeCard *dopeCard = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = dopeCard.name;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Zero: %@ %@ / Wind: %@", 
                                 dopeCard.zero, 
                                 [dataManager.rangeUnits objectAtIndex:[dopeCard.zero_unit intValue]],
                                 dopeCard.wind_info];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[_fetchedResultsController objectAtIndexPath:indexPath] deleteEntity];
    }
    [[DataManager sharedManager] saveAppDatabase];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor colorWithRed:0.855 green:0.812 blue:0.682 alpha:1.000];
}  

#pragma mark FetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;

    NSPredicate *typeFilter = (_selectedWeapon) ? [NSPredicate predicateWithFormat:@"weapon = %@", self.selectedWeapon] : nil;
    
    NSFetchRequest *fetchRequest = [DopeCard requestAllSortedBy:(_selectedWeapon) ? @"name" : @"weapon" ascending:YES 
                                                  withPredicate:typeFilter];
    NSString *cacheName = (_selectedWeapon) ? [NSString stringWithFormat:@"DopeCards%@", _selectedWeapon] : @"DopeCards";
    fetchRequest.fetchBatchSize = 20;
    
    NSString *sectionNameKeyPath = (_selectedWeapon) ? nil : @"weapon.description";
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                    managedObjectContext:[NSManagedObjectContext defaultContext] 
                                                                      sectionNameKeyPath:sectionNameKeyPath
                                                                               cacheName:cacheName];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self updateTitle];
    [self.tableView endUpdates];
}

@end
