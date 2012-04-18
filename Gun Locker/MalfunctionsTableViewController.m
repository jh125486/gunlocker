//
//  MalfunctionsTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MalfunctionsTableViewController.h"

@implementation MalfunctionsTableViewController
@synthesize selectedWeapon, selectedMaintenance;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    // pass in an already sorted array of Malfunctions
    // on newMalfunction, add in radio field for weapon if no weapon is passed
    // on save of newMalfunction, make sure to set .weapon if self.selectedWeapon
    
    [super viewDidLoad];
    malfunctions = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    
    //Register addNewMalfunctionToArray to recieve "newMalfunction" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewMalfunctionToArray:) name:@"newMalfunction" object:nil];
    
    // just use the date for collating the malfunctions into sections
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    NSArray *tempMalfunctions;
    if (self.selectedMaintenance) {
        tempMalfunctions = [self.selectedMaintenance.malfunctions sortedArrayUsingDescriptors:sortDescriptors];
    } else if (self.selectedWeapon) {
        tempMalfunctions = [self.selectedWeapon.malfunctions sortedArrayUsingDescriptors:sortDescriptors];
    } else {
        tempMalfunctions = [Malfunction findAllSortedBy:@"date" ascending:YES];
    }
    count = [tempMalfunctions count];
    
    for(Malfunction *malfunction in tempMalfunctions) {
        NSDateComponents* components = [calendar components:flags fromDate:malfunction.date];
        NSDate *date = [[calendar dateFromComponents:components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]]; 
        if ([malfunctions objectForKey:date] != nil) {
            [(NSMutableArray *)[malfunctions objectForKey:date] addObject:malfunction];
        } else {
            [sections addObject:date];
            [malfunctions setObject:[NSMutableArray arrayWithObject:malfunction] forKey:date];
        }
    }
    
    [sections sortUsingSelector:@selector(compare:)];
    sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
    [self.tableView reloadData];
    
    if (!selectedWeapon) self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = [NSString stringWithFormat:@"Malfunctions (%d)", count];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSelectedMaintenance:nil];
    [self setSelectedWeapon:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[malfunctions objectForKey:[sections objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[sections objectAtIndex:section] distanceOfTimeInWordsOnlyDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MalfunctionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MalfunctionCell"];

    Malfunction *currentMalfunction = [[malfunctions objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.roundCountLabel.text = [NSString stringWithFormat:@"Occurred at %@", currentMalfunction.round_count];
    cell.failtureText.text = currentMalfunction.failure;
    cell.fixText.text      = currentMalfunction.fix; 
    cell.modelLabel.text = (self.selectedWeapon) ? nil : currentMalfunction.weapon.description;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Malfunction *currentMalfunction = [[malfunctions objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [currentMalfunction deleteEntity];
        NSDate *section = [sections objectAtIndex:indexPath.section];

        [[malfunctions objectForKey:section] removeObjectAtIndex:indexPath.row];

        [self.tableView beginUpdates];
        if([[malfunctions objectForKey:section] count] == 0) {
            [malfunctions removeObjectForKey:section];
            [sections removeObject:section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
        
    }    
    [[NSManagedObjectContext defaultContext] save];    
}


- (void) addNewMalfunctionToArray:(NSNotification*) notification {
    Malfunction *newMalfunction = [notification object];
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:newMalfunction.date];
    NSDate *section = [[calendar dateFromComponents:components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]]; 

    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];

    [self.tableView beginUpdates];
    if([sections containsObject:section]) {
        [[malfunctions objectForKey:section] insertObject:newMalfunction atIndex:0];
        [[malfunctions objectForKey:section] sortUsingDescriptors:sortDescriptors];
    } else {
        [sections addObject:section];
        [sections sortUsingSelector:@selector(compare:)];
        sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
        
        [malfunctions setObject:[NSMutableArray arrayWithObject:newMalfunction] forKey:section];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[sections indexOfObject:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[malfunctions objectForKey:section] indexOfObject:newMalfunction] inSection:[sections indexOfObject:section]];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"AddNewMalfunction"]) {
        UINavigationController *destinationController = segue.destinationViewController;
        // dig past navigationcontroller to get to AddViewController
        MalfunctionsAddViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        [dst setSelectedWeapon:self.selectedWeapon];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Malfunction *currentMalfunction = [[malfunctions objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]; 
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
    
    [self.navigationController pushViewController:[[QuickDialogController alloc] initWithRoot:root] animated:YES];
}

@end
