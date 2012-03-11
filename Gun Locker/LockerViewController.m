//
//  LockerViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LockerViewController.h"

@interface LockerViewController()
@property(nonatomic, assign) BOOL firstInsert;
@end

@implementation LockerViewController

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize firstInsert = _firstInsert;
@synthesize segmentedTypeControl;


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

    self.navigationItem.title = [@"Locker (" stringByAppendingString: [NSString stringWithFormat:@"%d)", count]];;
    return count;
}

- (void)configureCell:(WeaponCell *)cell withWeapon:(Weapon *)weapon {
    cell.manufacturerLabel.text = weapon.manufacturer;
	cell.modelLabel.text = [NSString stringWithFormat:@"%@", weapon.model];
//    if (weapon.caliber) {
//        cell.modelLabel.text = [cell.modelLabel.text stringByAppendingFormat:@" [%@]", weapon.caliber];
//    }
    cell.barrelLengthLabel.text = weapon.barrel_length_in_inches;
    cell.serialNumberLabel.text = weapon.serial_number;
    
    cell.roundCountLabel.text = [NSString stringWithFormat:@"%d rounds fired", arc4random() % 10000];
	cell.photoImageView.image = [UIImage imageWithData:weapon.photo_thumbnail];
    cell.weapon = weapon;
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"!did select row");
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    Weapon* weapon = [fetchedResultsController objectAtIndexPath:indexPath];
//    NSLog(@"! weapon %@", [weapon description]);
//    [self performSegueWithIdentifier:@"ShowWeapon" sender:weapon];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"AddWeapon"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		WeaponAddViewController *addController = [[destinationController viewControllers] objectAtIndex:0];
		addController.delegate = self;
	} else if ([segueID isEqualToString:@"ShowWeapon"]) {
        WeaponShowViewController *showController = segue.destinationViewController;
        showController.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
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

# pragma segmented control

- (IBAction)segmentedTypeControlClicked
{
    NSLog(@"%d", self.segmentedTypeControl.selectedSegmentIndex);
}

@end
