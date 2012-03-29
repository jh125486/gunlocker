//
//  CardsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CardsViewController.h"

@interface CardsViewController ()
@property(nonatomic, assign) BOOL firstInsert;
@end

@implementation CardsViewController
@synthesize fetchedResultsController;
@synthesize firstInsert = _firstInsert;
@synthesize segmentedTypeControl, selectedType;
@synthesize tableView;
@synthesize showPasscodeFlag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *segmentSelected = [[UIImage imageNamed:@"selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage *segmentUnselected = [[UIImage imageNamed:@"unselected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"selected_unselected"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"unselected_selected"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"unselected_unselected"];
    
    [self.segmentedTypeControl setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedTypeControl setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.segmentedTypeControl setDividerImage:segmentUnselectedUnselected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedTypeControl setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedTypeControl setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:24.0],UITextAttributeFont,
                                      [UIColor darkGrayColor], UITextAttributeTextColor, 
                                      [UIColor clearColor], UITextAttributeTextShadowColor,
                                      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                      nil];
    [self.segmentedTypeControl setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    
    NSDictionary *selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:24.0],UITextAttributeFont,
                                        [UIColor blackColor], UITextAttributeTextColor, 
                                        [UIColor clearColor], UITextAttributeTextShadowColor,
                                        [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                        nil] ;
    [self.segmentedTypeControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    
    self.selectedType = [self.segmentedTypeControl titleForSegmentAtIndex:self.segmentedTypeControl.selectedSegmentIndex];
    
    // sets initial segment
    [self segmentedTypeControlClicked];
    self.segmentedTypeControl.apportionsSegmentWidthsByContent = YES;
    
    int segmentedUnitHeight = 32;
	[self.segmentedTypeControl setFrame: CGRectMake(self.segmentedTypeControl.frame.origin.x,
                                                    self.segmentedTypeControl.frame.origin.y,
                                                    self.segmentedTypeControl.frame.size.width, 
                                                    segmentedUnitHeight)];
    [self.segmentedTypeControl setContentOffset:CGSizeMake(0, 3) forSegmentAtIndex:0];
    [self.segmentedTypeControl setContentOffset:CGSizeMake(0, 3) forSegmentAtIndex:1];
    [self.segmentedTypeControl setContentOffset:CGSizeMake(0, 3) forSegmentAtIndex:2];
    [self.segmentedTypeControl setContentOffset:CGSizeMake(0, 3) forSegmentAtIndex:3];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.757 green:0.710 blue:0.588 alpha:1.000];
    
    
    if([Weapon countOfEntities] == 0)
        self.navigationItem.leftBarButtonItem.enabled = NO;
    
    
    showPasscodeFlag = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPasscodeModal)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    int count = [[[fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
    if (count == 1) {
        self.navigationItem.title = [NSString stringWithFormat:@"Showing %d card of %d total", count, [Weapon countOfEntities]];
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"Showing %d cards of %d total", count, [Weapon countOfEntities]];
    }
}
- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)configureCell:(WeaponCell *)cell withWeapon:(Weapon *)weapon {
    cell.manufacturerLabel.text = weapon.manufacturer;
	cell.modelLabel.text = [NSString stringWithFormat:@"%@", weapon.model];
    cell.caliberLabel.text =  weapon.caliber ? weapon.caliber : @"";
    
    if (weapon.barrel_length && weapon.threaded_barrel_pitch) {
        cell.barrelInfoLabel.text = [NSString stringWithFormat:@"%@\" barrel threaded %@", weapon.barrel_length, weapon.threaded_barrel_pitch];
    } else if (weapon.barrel_length) {
        cell.barrelInfoLabel.text = [NSString stringWithFormat:@"%@\" barrel", weapon.barrel_length];
    } else if (weapon.threaded_barrel_pitch) {
        cell.barrelInfoLabel.text = [NSString stringWithFormat:@"Barrel threaded %@", weapon.threaded_barrel_pitch];
    } else {
        cell.barrelInfoLabel.text = @"";
    }
    
    cell.finishLabel.text = weapon.finish;
    
    cell.serialNumberLabel.text = [weapon.serial_number isEqualToString:@""] ? @"" : [NSString stringWithFormat:@"Serial number %@", weapon.serial_number];
    
    cell.purchaseDateLabel.text = weapon.purchased_date ? [NSString stringWithFormat:@"Purchased %@", [[weapon.purchased_date distanceOfTimeInWordsOnlyDate] lowercaseString]] : @""; 
    
    cell.malfunctionNumberLabel.text = [NSString stringWithFormat:@"%d", [weapon.malfunctions count]];
    cell.malfunctionNumberLabel.textColor = ([weapon.malfunctions count] > 0) ? [UIColor redColor] : [UIColor blackColor];
    
    cell.roundCountLabel.text = [NSString stringWithFormat:@"%@ rounds fired", weapon.round_count];
    
    if (weapon.photo_thumbnail) {
        [cell.photoImageContainer setHidden:NO];
        cell.photoImageView.image = [UIImage imageWithData:weapon.photo_thumbnail];
    } else {
        [cell.photoImageContainer setHidden:YES];
    }
    
    // add S/N and date onto stamp
    if (weapon.stamp.stamp_received) {
        [cell.stampViewContainer setHidden:NO];
        switch ([weapon.stamp.nfa_type intValue]) {
            case 5: //AOW
                [cell.stampViewButton setImage:[UIImage imageNamed:@"Stamp_AOW"] forState:UIControlStateNormal];
                cell.stampDateLabel.transform = CGAffineTransformMakeRotation(-0.6);
                cell.stampSerialNumberLabel.frame = CGRectMake(15, 15, 56, 21);
                cell.stampDateLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:17.0];
                break;
                
            default:
                [cell.stampViewButton setImage:[UIImage imageNamed:@"Stamp_NFA"] forState:UIControlStateNormal];
                cell.stampDateLabel.transform = CGAffineTransformMakeRotation(-0.8);
                cell.stampDateLabel.font = [UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:17.0];
                cell.stampSerialNumberLabel.frame = CGRectMake(15, 12, 56, 21);
                break;
        }
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"LLL dd yyyy"];
        cell.stampDateLabel.text = [[dateFormat stringFromDate:weapon.stamp.stamp_received] uppercaseString];        
        
        cell.stampSerialNumberLabel.text = weapon.serial_number;
    } else {
        [cell.stampViewContainer setHidden:YES];
    }
    
    cell.weapon = weapon;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"AddEditWeapon"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		WeaponAddEditViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
		dst.delegate = self;
        dst.weaponType = self.selectedType;
	} else if ([segueID isEqualToString:@"ShowWeapon"]) {
        WeaponShowViewController *dst = segue.destinationViewController;
        self.navigationItem.title = self.selectedType;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.selectedType style:UIBarButtonItemStyleBordered target:nil action:nil];
        dst.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    } else if ([segueID isEqualToString:@"NFADetails"]) {
        UIButton *button = (UIButton *)sender;
        NSIndexPath *index = [self.tableView indexPathForRowAtPoint:CGPointMake(button.frame.origin.x, button.frame.origin.y)];
        self.navigationItem.title = self.selectedType;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.selectedType style:UIBarButtonItemStyleBordered target:nil action:nil];
        NFAInformationViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:index];;        
    }
}

#pragma mark - WeaponAddViewControllerDelegate

- (void)WeaponAddViewControllerDidCancel:(WeaponAddEditViewController *)controller {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)WeaponAddViewControllerDidSave:(WeaponAddEditViewController *)controller {
	[self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - segmented control

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

# pragma mark - KKPasscodeViewControllerDelegate

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

#pragma mark - TableView

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
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WeaponCell";
    WeaponCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[WeaponCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [self configureCell:cell withWeapon:[fetchedResultsController objectAtIndexPath:indexPath]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    if (count == 1) {
        self.navigationItem.title = [NSString stringWithFormat:@"Showing %d card of %d total", count, [Weapon countOfEntities]];
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"Showing %d cards of %d total", count, [Weapon countOfEntities]];
    }
    return count;
}


@end
