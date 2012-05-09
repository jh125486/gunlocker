//
//  DopeCardsTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardsViewController.h"

@implementation DopeCardsViewController
@synthesize noDopeCardsImageView;
@synthesize tableView;
@synthesize selectedWeapon;
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
    NSLog(@"%@", self.selectedWeapon);

    //Register addNewDopeCardToArray to recieve "addNewDopeCard" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDopeCard:) name:@"newDopeCard" object:nil];
    
    if (!selectedWeapon) self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self loadDopeCards];
    [self.tableView reloadData];
    [self setTitle];
}

- (void)setTitle {
    self.title = [NSString stringWithFormat:@"Dope Cards (%d)", count];
    
    self.noDopeCardsImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Table/DopeCards"]];
    self.noDopeCardsImageView.hidden = (count != 0);
    self.tableView.hidden = (count == 0);
}

- (void)loadDopeCards {
    dopeCards = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];

    if (self.selectedWeapon) {
        sections = [[self.selectedWeapon.dope_cards sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        count = [sections count];
    } else {
        for(DopeCard *dopeCard in [DopeCard findAllSortedBy:@"name" ascending:YES]) {
            if ([dopeCards objectForKey:dopeCard.weapon.description] != nil) {
                [(NSMutableArray *)[dopeCards objectForKey:dopeCard.weapon.description] addObject:dopeCard];
            } else {
                [sections addObject:dopeCard.weapon.description];
                [dopeCards setObject:[NSMutableArray arrayWithObject:dopeCard] forKey:dopeCard.weapon.description];
            }
            count++;
        }
        [sections sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"model" ascending:YES]]];
        sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
    }
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSelectedWeapon:nil];
    [self setNoDopeCardsImageView:nil];
    [self setTableView:nil];
    [self setFetchedResultsController:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"ShowDopeCard"]) {
        DopeCardViewController *dst = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        dst.selectedDopeCard = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[dopeCards objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
    self.navigationItem.title = @"Dope Cards";
}

- (void) addNewDopeCard:(NSNotification*) notification {
    DopeCard *newDopeCard = [notification object];
    newDopeCard.weapon = self.selectedWeapon;
    
    
    [sections addObject:newDopeCard];

    count++;

    [[NSManagedObjectContext defaultContext] save];
    [self setTitle];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.selectedWeapon) ? 1 : [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.selectedWeapon) ? count : [[dopeCards objectForKey:[sections objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (self.selectedWeapon) ? nil : [sections objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DopeCardSummaryCell"];
        
    DopeCard *dopeCard = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[dopeCards objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    cell.textLabel.text = dopeCard.name;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Zero: %@ %@ / Wind: %@", dopeCard.zero, [dopeCard.range_unit lowercaseString], dopeCard.wind_info];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DopeCard *currentDopeCard = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[dopeCards objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [currentDopeCard deleteEntity];
        
        // update table data
        [self.tableView beginUpdates];
        if(self.selectedWeapon) {
            [sections removeObject:currentDopeCard];
            NSLog(@"count %d", [sections count]);
        } else {
            [(NSMutableArray *)[dopeCards objectForKey:currentDopeCard.weapon.description] removeObject:currentDopeCard];
        }
        count--;
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        [self setTitle];
        [[NSManagedObjectContext defaultContext] save];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor colorWithRed:0.855 green:0.812 blue:0.682 alpha:1.000];
}  

#pragma mark FetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;

    NSPredicate *typeFilter = (self.selectedWeapon) ? [NSPredicate predicateWithFormat:@"weapon = %@", self.selectedWeapon] : nil;
    NSFetchRequest *fetchRequest = [DopeCard requestAllSortedBy:@"name" ascending:YES withPredicate:typeFilter];
    
    [fetchRequest setFetchBatchSize:20];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                        managedObjectContext:[NSManagedObjectContext MR_defaultContext] 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:@"DopeCards"];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
