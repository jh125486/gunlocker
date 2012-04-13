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
        
    if([Weapon countOfEntities] == 0) // enable for deletions?
        self.navigationItem.leftBarButtonItem.enabled = NO;
    
    
    showPasscodeFlag = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPasscodeModal)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self segmentedTypeControlClicked];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.fetchedResultsController.delegate = nil;
    [self setFetchedResultsController:nil];
    [self setSegmentedTypeControl:nil];
    [self setTableView:nil];
    [self setSelectedType:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    NSPredicate *typeFilter = [NSPredicate predicateWithFormat:@"type = %@", self.selectedType];
    NSFetchRequest *weaponsRequest = [Weapon requestAllSortedBy:@"manufacturer.name,model" ascending:YES withPredicate:typeFilter];
    
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
        [dst setCardsViewController:self];
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

- (IBAction)segmentedTypeControlClicked {
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
        [((WeaponCell*)[self.tableView cellForRowAtIndexPath:indexPath])configureWithWeapon:anObject];        
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
    WeaponCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"WeaponCell"];
    [cell configureWithWeapon:[fetchedResultsController objectAtIndexPath:indexPath]];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[[fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    self.navigationItem.title = [NSString stringWithFormat:@"%d card%@ in folder", count, (count == 1) ? @"" : @"s"];

    return count;
}


@end
