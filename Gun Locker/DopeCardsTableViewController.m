//
//  DopeCardsTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DopeCardsTableViewController.h"

@implementation DopeCardsTableViewController
@synthesize selectedWeapon;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //Register addNewDopeCardToArray to recieve "addNewDopeCard" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDopeCard:) name:@"newDopeCard" object:nil];
    
    self.navigationItem.rightBarButtonItem.enabled = self.selectedWeapon ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadDopeCards];
    [self.tableView reloadData];  
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setTitle {
    int count = self.selectedWeapon ? [self.selectedWeapon.dope_cards count] : [DopeCard countOfEntities];
    self.title = [NSString stringWithFormat:@"Dope Card%@ (%d)", (count == 1) ? @"" : @"s", count];
}

- (void)loadDopeCards {
    dopeCards = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];

    if (self.selectedWeapon) {
        sections = [[self.selectedWeapon.dope_cards sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    } else {
        for(DopeCard *dopeCard in [DopeCard findAllSortedBy:@"name" ascending:YES]) {
            if ([dopeCards objectForKey:dopeCard.weapon] != nil) {
                [(NSMutableArray *)[dopeCards objectForKey:dopeCard.weapon] addObject:dopeCard];
            } else {
                [sections addObject:dopeCard.weapon];
                [dopeCards setObject:[NSMutableArray arrayWithObject:dopeCard] forKey:dopeCard.weapon];
            }
        }
        [sections sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"model" ascending:YES]]];
        sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
    }
    
    [self setTitle];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        self.navigationItem.title = @"Dope Cards";
        dst.selectedDopeCard = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[dopeCards objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
}

- (void) addNewDopeCard:(NSNotification*) notification {
    DopeCard *newDopeCard = [notification object];
    newDopeCard.weapon = self.selectedWeapon;
    [[NSManagedObjectContext defaultContext] save];  
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.selectedWeapon) ? 1 : [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.selectedWeapon) ? [sections count] : [[dopeCards objectForKey:[sections objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (self.selectedWeapon) ? nil : [sections objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DopeCardSummaryCell"];
        
    DopeCard *dopeCard = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[dopeCards objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    cell.textLabel.text = dopeCard.name;
    NSString *zero_unit = dopeCard.range_unit;
    zero_unit = ([zero_unit isEqualToString:@"Feet"]) ? @"foot": [[zero_unit substringToIndex:[zero_unit length] -1] lowercaseString];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ zero / Wind %@", dopeCard.zero, zero_unit, dopeCard.wind_info];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DopeCard *currentDopeCard = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[dopeCards objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [currentDopeCard deleteEntity];
        [[NSManagedObjectContext defaultContext] save];  
        
        // update table data
        if(self.selectedWeapon) {
            [sections removeObject:currentDopeCard];
        } else {
            [(NSMutableArray *)[dopeCards objectForKey:currentDopeCard.weapon] removeObject:currentDopeCard];
        }
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setTitle];
    }
}

@end
