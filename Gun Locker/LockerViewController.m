//
//  LockerViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LockerViewController.h"
#import "Weapon.h"
#import "WeaponCell.h"

@interface LockerViewController()
@property(nonatomic, assign) BOOL firstInsert;
@end

@implementation LockerViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize firstInsert = _firstInsert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
      // handle error!
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];

    self.navigationItem.title = [self.navigationItem.title stringByAppendingString: [NSString stringWithFormat:@" (%d)", count]];;
    return count;
}

- (void)configureCell:(WeaponCell *)cell withWeapon:(Weapon *)weapon {
    cell.manufacturerLabel.text = weapon.manufacturer;
	cell.modelLabel.text = weapon.model;
    cell.serialNumberLabel.text = weapon.serial_number;
	cell.photoImageView.image = [UIImage imageWithData:weapon.photo_thumbnail];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
        Weapon *weapon = [fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:weapon];
        
        NSError *error;
        if (![context save:&error]) {
            // handle error
        }
        
    }
    
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if(NSFetchedResultsChangeUpdate == type) {
        [self configureCell:(WeaponCell *)[self.tableView cellForRowAtIndexPath:indexPath] withWeapon:anObject];
        
    } else if(NSFetchedResultsChangeMove == type) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if(NSFetchedResultsChangeInsert == type) {
        if(!self.firstInsert) {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [self.tableView insertSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        }
        
    } else if(NSFetchedResultsChangeDelete == type) {
        NSInteger sectionCount = [[fetchedResultsController sections] count];
        if(sectionCount == 0) {
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:indexPath.section];
            [self.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeaponCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeaponCell"];
    
    Weapon *weapon = [fetchedResultsController objectAtIndexPath:indexPath];
    
    [self configureCell:cell withWeapon:weapon];
    
    return cell;
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    managedObjectContext = [[DatabaseHelper sharedInstance] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Weapon" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"manufacturer" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:managedObjectContext 
                                                                                                sectionNameKeyPath:nil 
                                                                                                cacheName:@"Locker"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    return fetchedResultsController;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddWeapon"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		WeaponAddViewController *detailsController = [[navigationController viewControllers] objectAtIndex:0];
		detailsController.delegate = self;
	}
}

#pragma mark - WeaponAddViewControllerDelegate

- (void)WeaponAddViewControllerDidCancel:(WeaponAddViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)WeaponAddViewControllerDidSave:(WeaponAddViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
