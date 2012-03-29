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

    //Register addNewMalfunctionToArray to recieve "newMalfunction" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewMaintenanceToArray:) name:@"newMaintenance" object:nil];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    tableDataArray = [[self.selectedWeapon.maintenances sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MaintenanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MaintenanceCell"];

    if (cell == nil)
        cell = [[MaintenanceCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MaintenanceCell"];

    // Configure the cell...
    Maintenance *currentMaintenance = [tableDataArray objectAtIndex:indexPath.row];
    cell.dateLabel.text = [currentMaintenance.date distanceOfTimeInWords];
    cell.roundCountLabel.text = [currentMaintenance.round_count stringValue];
    cell.actionPerformedLabel.text = currentMaintenance.action_performed;
    NSMutableString *malfunctions = [[NSMutableString alloc] initWithString:@""];
    for (Malfunction *malfunction in currentMaintenance.malfunctions)
        [malfunctions appendFormat:@"• %@\n", malfunction.failure];
    
    NSLog(@"failures %@ - %d", malfunctions, [currentMaintenance.malfunctions count]);
    cell.malfunctionsTextView.text = malfunctions;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Maintenance *newMaintenance = [tableDataArray objectAtIndex:indexPath.row];
        [newMaintenance deleteEntity];
        [tableDataArray removeObjectAtIndex:indexPath.row];
        
//        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView endUpdates];
    }    
}

- (void) addNewMaintenanceToArray:(NSNotification*) notification {
    Maintenance *newMaintenance = [notification object];
    [tableDataArray addObject:newMaintenance];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [tableDataArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSUInteger index = [tableDataArray indexOfObject:newMaintenance];
    
    [self.tableView beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *destinationController = segue.destinationViewController;
    // dig past navigationcontroller to get to AddViewController
    MaintenancesAddViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
    [dst setSelectedWeapon:self.selectedWeapon];
}

@end
