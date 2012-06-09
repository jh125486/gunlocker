//
//  MagazineByBrandViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazineListByBrandViewController.h"

@implementation MagazineListByBrandViewController
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize caliberLabel = _caliberLabel;
@synthesize brandCountLabel = _brandCountLabel;
@synthesize selectedCaliber = _selectedCaliber;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Calibers";
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if ([_fetchedResultsController.fetchedObjects count] == 0) [self.navigationController popViewControllerAnimated:YES];
}

- (void)setTitle {
    _caliberLabel.text = _selectedCaliber;
    
    NSNumber *magazines = [Magazine aggregateOperation:@"sum:" 
                                           onAttribute:@"count" 
                                         withPredicate:_fetchedResultsController.fetchRequest.predicate];
    _brandCountLabel.text = [NSString stringWithFormat:@"%d brands / %@ magazines", [_fetchedResultsController.sections count], magazines];
}

- (void)viewDidUnload {
    [self setFetchedResultsController:nil];
    [self setCaliberLabel:nil];
    [self setBrandCountLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"MagazineShow"]) {
        MagazineShowViewController *dst = segue.destinationViewController;
        dst.selectedMagazine = [_fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    } else if ([segueID isEqualToString:@"AddMagazineFromBrand"]) {
        MagazineAddEditViewController *dst = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        dst.selectedCaliber = _selectedCaliber;
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Brands" 
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:nil 
                                                                            action:nil];

}

#pragma mark - Table view data source

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
    return ([self tableView:tableView titleForHeaderInSection:section]) ? [tableView sectionHeaderHeight] : 0.f;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [_fetchedResultsController sectionForSectionIndexTitle:[title substringToIndex:1] atIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MagazineByBrandCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Magazine *magazine        = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text       =  [NSString stringWithFormat:@"%@ (%d round)", magazine.type, [magazine.capacity intValue]];
    if (![magazine.color isEqualToString:@""]) cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", cell.textLabel.text, magazine.color];
    cell.detailTextLabel.text = [magazine.count stringValue];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[_fetchedResultsController objectAtIndexPath:indexPath] deleteEntity];
        [[NSManagedObjectContext defaultContext] save];
    }
}

#pragma mark FetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    
    NSPredicate *caliberFilter = [NSPredicate predicateWithFormat:@"caliber = %@", _selectedCaliber];
    
    NSFetchRequest *fetchRequest = [Magazine requestAllSortedBy:@"brand" ascending:YES withPredicate:caliberFilter];
    fetchRequest.fetchBatchSize = 20;

    NSString *sectionNameKeyPath = @"brand";
    
    NSString *cacheName = [NSString stringWithFormat:@"MagazineByCaliber%@", _selectedCaliber];
    
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
            [self configureCell:(UITableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
    [self setTitle];
    [self.tableView endUpdates];
    if ([_fetchedResultsController.fetchedObjects count] == 0) [self.navigationController popViewControllerAnimated:YES];
}

@end
