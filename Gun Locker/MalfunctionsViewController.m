//
//  MalfunctionsTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MalfunctionsViewController.h"

@implementation MalfunctionsViewController
@synthesize noMalfunctionsImageView = _noMalfunctionsImageView;
@synthesize tableView;
@synthesize selectedWeapon = _selectedWeapon;
@synthesize selectedMaintenance = _selectedMaintenance;
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
            
    if (!(_selectedWeapon) || _selectedMaintenance) self.navigationItem.rightBarButtonItem = nil;
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self setTitle];
}

- (void)setTitle {
    int count = [_fetchedResultsController.fetchedObjects count];
    self.title = [NSString stringWithFormat:@"Malfunctions (%d)", count];
    
    _noMalfunctionsImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Table/Malfunctions"]];
    _noMalfunctionsImageView.hidden = (count != 0);
    self.tableView.hidden = (count == 0);
}

- (void)viewDidUnload {
    [self setSelectedMaintenance:nil];
    [self setSelectedWeapon:nil];
    [self setNoMalfunctionsImageView:nil];
    [self setTableView:nil];
    [self setFetchedResultsController:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"AddNewMalfunction"]) {
        UINavigationController *destinationController = segue.destinationViewController;
        // dig past navigationcontroller to get to AddViewController
        MalfunctionsAddViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        [dst setSelectedWeapon:_selectedWeapon];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return (_selectedWeapon) ? nil : [_fetchedResultsController sectionIndexTitles];
}

# pragma mark UITableviewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [_fetchedResultsController sectionForSectionIndexTitle:[title substringToIndex:1] atIndex:index];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.tableView.sectionHeaderHeight)];
    UILabel *firstLine, *secondLine;

    if (_selectedWeapon) { // Weapon Malfunction Table
        headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Table/tableView_header_background"]];
        firstLine = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 320.0f, CGRectGetHeight(headerView.frame))];
        firstLine.text = [[[_fetchedResultsController sections] objectAtIndex:section] name];
    } else { // Logbook
        headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Table/tableView_header_background2"]];
        Weapon *weapon = [[_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]] weapon];
        UIImageView *thumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 3.0f, 56.0f, 42.0f)];
        firstLine     = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 2.0f, 256.0f, 23.0f)];
        secondLine    = [[UILabel alloc] initWithFrame:CGRectMake(68.0f, 24.0f, 252.0f, 23.0f)];
        
        secondLine.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:18.0f];
        secondLine.backgroundColor = [UIColor clearColor];
        secondLine.textColor = [UIColor darkGrayColor];
        secondLine.shadowColor = [UIColor lightTextColor];
        secondLine.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        thumbnailImageView.image = [UIImage imageWithData:weapon.primary_photo.thumbnail_size];
        firstLine.text  = weapon.manufacturer.name;
        secondLine.text = weapon.model;
        
        [headerView addSubview:thumbnailImageView];
        [headerView addSubview:secondLine];       
    }
    
    firstLine.font  = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20.0f];
    firstLine.backgroundColor = [UIColor clearColor];
    firstLine.textColor = [UIColor blackColor];
    firstLine.shadowColor = [UIColor lightTextColor];
    firstLine.shadowOffset = CGSizeMake(0.0f, 1.0f);

    firstLine.adjustsFontSizeToFitWidth = YES;
    [headerView addSubview:firstLine];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:self.tableView titleForHeaderInSection:section] != nil) ? ((_selectedWeapon) ? 23.0f : 46.0f) : 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MalfunctionCell";
    MalfunctionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];    
    return cell;
}

-(void)configureCell:(MalfunctionCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Malfunction *malfunction  = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.roundCountLabel.text = [malfunction.round_count stringValue];
    cell.failtureText.text    = malfunction.failure;
    cell.fixText.text         = malfunction.fix; 
    cell.dateLabel.text       = (_selectedWeapon) ? nil : malfunction.dateAgoInWords;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[_fetchedResultsController objectAtIndexPath:indexPath] deleteEntity];
    }
    [[NSManagedObjectContext defaultContext] save];      
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Malfunction *currentMalfunction = [_fetchedResultsController objectAtIndexPath:indexPath]; 
    QRootElement *root = [[QRootElement alloc] init];
    root.grouped = YES;
    root.title = [NSString stringWithFormat:@"Malfunction %d/%d", indexPath.section, indexPath.row];
	
    QSection *infoSection = [[QSection alloc] initWithTitle:@"Info"];
    QSection *failureSection = [[QSection alloc] initWithTitle:@"Failure"];
    QSection *fixSection = [[QSection alloc] initWithTitle:@"Fix Action"];
    
    QLabelElement *malfunctionDate = [[QLabelElement alloc] initWithTitle:@"Date" Value:[currentMalfunction.date onlyDate]];
    QLabelElement *roundCount      = [[QLabelElement alloc] initWithTitle:@"Round count" Value:currentMalfunction.round_count];
            
    [infoSection addElement:malfunctionDate];
    [infoSection addElement:roundCount];
    [failureSection addElement:[[QTextElement alloc] initWithText:currentMalfunction.failure]];
    [fixSection addElement:[[QTextElement alloc] initWithText:currentMalfunction.fix]];
    
    [root addSection:infoSection];
    [root addSection:failureSection];
    [root addSection:fixSection];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Malfunctions" 
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:nil 
                                                                            action:nil];

    [self.navigationController pushViewController:[[QuickDialogController alloc] initWithRoot:root] animated:YES];
}

#pragma mark FetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    
    NSPredicate *typeFilter = (_selectedWeapon) ? [NSPredicate predicateWithFormat:@"weapon = %@", _selectedWeapon] : nil;
    typeFilter = (_selectedMaintenance) ? [NSPredicate predicateWithFormat:@"maintenance = %@", _selectedMaintenance] : typeFilter;
    
    NSFetchRequest *fetchRequest = [Malfunction requestAllSortedBy:(_selectedWeapon) ? @"date" : @"weapon.manufacturer.name" ascending:YES 
                                                     withPredicate:typeFilter];
    fetchRequest.fetchBatchSize = 20;
    
    NSString *sectionNameKeyPath = (_selectedWeapon) ? @"dateAgoInWords" : @"weapon.description";

    NSString *cacheName = (_selectedWeapon) ? [NSString stringWithFormat:@"Malfunction%@", _selectedWeapon] : @"Malfunction";
    cacheName = (_selectedMaintenance) ? [NSString stringWithFormat:@"RelatedMalfunction%@", _selectedMaintenance] : cacheName;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
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

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(MalfunctionCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self setTitle];
    [self.tableView endUpdates];
}

@end
