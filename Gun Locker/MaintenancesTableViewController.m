//
//  MaintenancesTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenancesTableViewController.h"

@implementation MaintenancesTableViewController
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
    maintenances = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];

    //Register addNewMaintenanceToArray to recieve "newMaintenance" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewMaintenanceToArray:) name:@"newMaintenance" object:nil];

    // just use the date for collating the malfunctions into sections
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];

    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];

    for(Maintenance *maintenance in [self.selectedWeapon.maintenances sortedArrayUsingDescriptors:sortDescriptors]) {
        NSDateComponents* components = [calendar components:flags fromDate:maintenance.date];
        NSDate *date = [[calendar dateFromComponents:components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]]; 
        if ([maintenances objectForKey:date] != nil) {
            [(NSMutableArray *)[maintenances objectForKey:date] addObject:maintenance];
        } else {
            [sections addObject:date];
            [maintenances setObject:[NSMutableArray arrayWithObject:maintenance] forKey:date];
        }
    }
    
    [sections sortUsingSelector:@selector(compare:)];
    sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = [NSString stringWithFormat:@"Maintenance (%d)", [self.selectedWeapon.maintenances count]];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setSelectedWeapon:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"AddNewMalfunction"]) {
        // dig past navigationcontroller to get to AddViewController
        MaintenancesAddViewController *dst = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        dst.selectedWeapon = self.selectedWeapon;
    } else if ([segueID isEqualToString:@"ViewRelatedMalfunctions"]) {
        UIButton *button = (UIButton *)sender;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)[[button superview] superview]];        
        Maintenance *currentMaintenance = [[maintenances objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        MalfunctionsTableViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = self.selectedWeapon;
        dst.selectedMaintenance = currentMaintenance;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[maintenances objectForKey:[sections objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[sections objectAtIndex:section] distanceOfTimeInWordsOnlyDate];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MaintenanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MaintenanceCell"];

    Maintenance *currentMaintenance = [[maintenances objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.roundCountLabel.text = [currentMaintenance.round_count stringValue];
    cell.actionPerformedText.text = currentMaintenance.action_performed;
    
    int malfunctionCount = [currentMaintenance.malfunctions count];

    CGRect cellFrame = [cell frame];
    if (malfunctionCount > 0) {
        cell.malfunctionLabel.text      = [NSString stringWithFormat:@"Related Malfunction%@", malfunctionCount == 1 ? @"" : @"s" ];
        cell.malfunctionCountLabel.text = [NSString stringWithFormat:@"%d", malfunctionCount];
        cellFrame.size.height = 186;
    } else {
        cellFrame.size.height = 96;
    }
    [cell setFrame:cellFrame];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Maintenance *currentMaintenance = [[maintenances objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [currentMaintenance deleteEntity];
        NSDate *section = [sections objectAtIndex:indexPath.section];
        
        [[maintenances objectForKey:section] removeObjectAtIndex:indexPath.row];
        
        [self.tableView beginUpdates];
        if([[maintenances objectForKey:section] count] == 0) {
            [maintenances removeObjectForKey:section];
            [sections removeObject:section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableView endUpdates];
        
    }    
    [[NSManagedObjectContext defaultContext] save];      
}

- (void) addNewMaintenanceToArray:(NSNotification*) notification {
    Maintenance *newMaintenance = [notification object];
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:newMaintenance.date];
    NSDate *section = [[calendar dateFromComponents:components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]]; 
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];

    NSLog(@"sections: %@", [sections description]);
    [self.tableView beginUpdates];
    if([sections containsObject:section]) { 
        NSLog(@"adding to section %@", [section description]);
        [[maintenances objectForKey:section] insertObject:newMaintenance atIndex:0];
        [[maintenances objectForKey:section] sortUsingDescriptors:sortDescriptors];
    } else {
        NSLog(@"creating section %@", [section description]);
        [sections addObject:section];
        [sections sortUsingSelector:@selector(compare:)];
        sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
        
        [maintenances setObject:[NSMutableArray arrayWithObject:newMaintenance] forKey:section];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[sections indexOfObject:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[maintenances objectForKey:section] indexOfObject:newMaintenance] inSection:[sections indexOfObject:section]];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

// shorten cell for maintenances without relation malfunctions
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Maintenance *currentMaintenance = [[maintenances objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    return ([currentMaintenance.malfunctions count] > 0) ? 186 : 108;
}

@end
