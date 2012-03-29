//
//  MalfunctionsTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MalfunctionsTableViewController.h"

@implementation MalfunctionsTableViewController
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
    data = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    
    //Register addNewMalfunctionToArray to recieve "newMalfunction" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewMalfunctionToArray:) name:@"newMalfunction" object:nil];

    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    // just use the date for collating the malfunctions into sections
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    for(Malfunction *malfunction in [self.selectedWeapon.malfunctions sortedArrayUsingDescriptors:sortDescriptors]) {
        NSDateComponents* components = [calendar components:flags fromDate:malfunction.date];
        NSDate *date = [[calendar dateFromComponents:components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]]; 
        if ([data objectForKey:date] != nil) {
            [(NSMutableArray *)[data objectForKey:date] addObject:malfunction];
        } else {
            [sections addObject:date];
            [data setObject:[NSMutableArray arrayWithObject:malfunction] forKey:date];
        }
    }
    ;
    [sections sortUsingSelector:@selector(compare:)];
    sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)viewDidUnload {
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
    return [[data objectForKey:[sections objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[sections objectAtIndex:section] distanceOfTimeInWordsOnlyDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    // Configure the cell...
    Malfunction *currentMalfunction = [[data objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.textLabel.text = currentMalfunction.failure;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"at %@ rounds", currentMalfunction.round_count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Malfunction *currentMalfunction = [[data objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [currentMalfunction deleteEntity];
        NSDate *section = [sections objectAtIndex:indexPath.section];

        [[data objectForKey:section] removeObjectAtIndex:indexPath.row];

        [self.tableView beginUpdates];
        if([[data objectForKey:section] count] == 0) {
            [data removeObjectForKey:section];
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
        [[data objectForKey:section] insertObject:newMalfunction atIndex:0];
        [[data objectForKey:section] sortUsingDescriptors:sortDescriptors];
    } else {
        [sections addObject:section];
        [sections sortUsingSelector:@selector(compare:)];
        sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
        
        [data setObject:[NSMutableArray arrayWithObject:newMalfunction] forKey:section];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[sections indexOfObject:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[data objectForKey:section] indexOfObject:newMalfunction] inSection:[sections indexOfObject:section]];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *destinationController = segue.destinationViewController;
    // dig past navigationcontroller to get to AddViewController
    MalfunctionsAddViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
    [dst setSelectedWeapon:self.selectedWeapon];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Malfunction *currentMalfunction = [[data objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]; 
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
