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
@synthesize editModeButton, editModeOn;
@synthesize fetchedResultsController;
@synthesize firstInsert = _firstInsert;
@synthesize segmentedTypeControl, selectedType;
@synthesize weapons;
@synthesize showPasscodeFlag;

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

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"locker_tableview_background.png"]];
    
    self.selectedType = [self.segmentedTypeControl titleForSegmentAtIndex:self.segmentedTypeControl.selectedSegmentIndex];
    
    // sets initial segment
    [self segmentedTypeControlClicked];
    
    int segmentedUnitHeight = 37;
	[self.segmentedTypeControl setFrame: CGRectMake(self.segmentedTypeControl.frame.origin.x,
                                                    self.segmentedTypeControl.frame.origin.y,
                                                    self.segmentedTypeControl.frame.size.width, 
                                                    segmentedUnitHeight)];

    if([Weapon countOfEntities] == 0)
        self.navigationItem.leftBarButtonItem.enabled = NO;
    
    
    self.editModeOn = NO;
    self.editModeButton.possibleTitles = [NSSet setWithObjects:@"Edit", @"Done", nil];
    self.editModeButton.title = @"Edit";

    showPasscodeFlag = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPasscodeModal)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [self setEditModeButton:nil];
    [super viewDidUnload];
}

-(void)viewDidAppear:(BOOL)animated {
    if(showPasscodeFlag)
        [self showPasscodeModal];
}

-(void)viewWillDisappear:(BOOL)animated {
    // turn off editing mode if tabbar is switched
    if(self.editModeOn)
        [self editMode:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showPasscodeModal {
    if (([[KKPasscodeLock sharedLock] isPasscodeRequired])) {
        KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil] ;
        vc.mode = KKPasscodeModeEnter;
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(),^ {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            nav.navigationBar.barStyle = UIBarStyleBlack;
            nav.navigationBar.opaque = NO;
            
            [self presentViewController:nav animated:YES completion:^{showPasscodeFlag = NO;}];
        });
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];

    self.navigationItem.title = [@"Cards (" stringByAppendingString: [NSString stringWithFormat:@"%d)", count]];
    return count;
}

- (void)configureCell:(WeaponCell *)cell withWeapon:(Weapon *)weapon {
    cell.manufacturerLabel.text = weapon.manufacturer;
	cell.modelLabel.text = [NSString stringWithFormat:@"%@", weapon.model];
    if (weapon.caliber)
        cell.caliberLabel.text = weapon.caliber;

    if (weapon.barrel_length)
        cell.barrelLengthLabel.text = [NSString stringWithFormat:@"%@\"", weapon.barrel_length];
    if (weapon.finish) {
        cell.finishLabel.text = weapon.finish;
    }
    cell.serialNumberLabel.text = weapon.serial_number;

    if(weapon.purchased_date) {
        cell.purchaseDateLabel.text = [[weapon.purchased_date distanceOfTimeInWords] lowercaseString]; 
    } else {
        cell.purchaseDatePromptLabel.hidden = YES;
    }
    
    cell.malfunctionNumberLabel.text = [NSString stringWithFormat:@"%d", [weapon.malfunctions count]];
    
    cell.roundCountLabel.text = [NSString stringWithFormat:@"%d rounds fired", arc4random() % 10000];
	cell.photoImageView.image = [UIImage imageWithData:weapon.photo_thumbnail];
    cell.weapon = weapon;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[fetchedResultsController objectAtIndexPath:indexPath] deleteEntity];
        [[NSManagedObjectContext defaultContext] save];
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
        if([Weapon countOfEntities] == 0)
            self.navigationItem.leftBarButtonItem.enabled = NO;

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
    
    [self configureCell:cell withWeapon:[fetchedResultsController objectAtIndexPath:indexPath]];
    
    return cell;
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    NSPredicate *typeFilter = [NSPredicate predicateWithFormat:@"type = %@", self.selectedType];
    NSFetchRequest *weaponsRequest = [Weapon requestAllSortedBy:@"manufacturer,model" ascending:YES withPredicate:typeFilter];

    NSFetchedResultsController *aFRC = [[NSFetchedResultsController alloc] initWithFetchRequest:weaponsRequest 
                                                                           managedObjectContext:[NSManagedObjectContext MR_defaultContext] 
                                                                             sectionNameKeyPath:nil 
                                                                                      cacheName:nil];
    
    aFRC.delegate = self;
    self.fetchedResultsController = aFRC;
    
    return fetchedResultsController;
}

// determine whether to edit or show the weapon
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editModeOn) {
        [self performSegueWithIdentifier:@"AddEditWeapon" sender:self];
    } else {
        [self performSegueWithIdentifier:@"ShowWeapon" sender:self];
    }    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"AddEditWeapon"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		WeaponAddEditViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
		dst.delegate = self;
        dst.weaponType = self.selectedType;
        if(editModeOn)
            dst.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
	} else if ([segueID isEqualToString:@"ShowWeapon"]) {
        WeaponShowViewController *dst = segue.destinationViewController;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.selectedType style:UIBarButtonItemStyleBordered target:nil action:nil];
        dst.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    }
}

#pragma mark - WeaponAddViewControllerDelegate

- (void)WeaponAddViewControllerDidCancel:(WeaponAddEditViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)WeaponAddViewControllerDidSave:(WeaponAddEditViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
    self.navigationItem.leftBarButtonItem.enabled = YES;
}


- (IBAction)editMode:(id)sender {
    if(self.editModeOn) {
        self.editModeButton.title = @"Edit";
        self.editModeButton.tintColor = nil;
    } else {
        [self.editModeButton setTitle:@"Editing"];
        self.editModeButton.tintColor =  [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000];
    }
    self.editModeOn ^= YES;
}

# pragma segmented control
- (IBAction)segmentedTypeControlClicked
{
    self.selectedType = [self.segmentedTypeControl titleForSegmentAtIndex:self.segmentedTypeControl.selectedSegmentIndex];
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type = %@", self.selectedType];

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // handle error!
    }
    
    [self.tableView reloadData];
}

# pragma KKPasscodeViewControllerDelegate
- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController {
    // TODO delete all data
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                    message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted." 
                                                   delegate:self 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                    message:@"You have entered an incorrect passcode too many times." 
                                                   delegate:self 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
}

@end
