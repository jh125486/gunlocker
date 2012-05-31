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
@synthesize segmentedTypeControl = _segmentedTypeControl, selectedType = _selectedType;
@synthesize noFilesImageView = _noFilesImageView;
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
    
    #ifdef DEBUG
        if([Weapon countOfEntities] == 0) [self loadTestWeapons];
    #endif
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    UIImage *segmentSelected = [[UIImage imageNamed:@"selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    UIImage *segmentUnselected = [[UIImage imageNamed:@"unselected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    UIImage *segmentSelectedUnselected = [UIImage imageNamed:@"selected_unselected"];
    UIImage *segUnselectedSelected = [UIImage imageNamed:@"unselected_selected"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"unselected_unselected"];
    
    [_segmentedTypeControl setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedTypeControl setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedTypeControl setDividerImage:segmentUnselectedUnselected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedTypeControl setDividerImage:segmentSelectedUnselected forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedTypeControl setDividerImage:segUnselectedSelected forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:22.0f], UITextAttributeFont,
                                      [UIColor darkGrayColor], UITextAttributeTextColor, 
                                      [UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                      [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                      nil];
    [_segmentedTypeControl setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    
    NSDictionary *selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:22.0f],UITextAttributeFont,
                                        [UIColor blackColor], UITextAttributeTextColor, 
                                        [UIColor lightTextColor], UITextAttributeTextShadowColor,
                                        [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                        nil] ;
    [_segmentedTypeControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    
    _selectedType = [_segmentedTypeControl titleForSegmentAtIndex:_segmentedTypeControl.selectedSegmentIndex];
    
    // sets initial segment
    _segmentedTypeControl.apportionsSegmentWidthsByContent = YES;
    
    int segmentedUnitHeight = 32;
	[_segmentedTypeControl setFrame: CGRectMake(_segmentedTypeControl.frame.origin.x,
                                                    _segmentedTypeControl.frame.origin.y,
                                                    _segmentedTypeControl.frame.size.width, 
                                                    segmentedUnitHeight)];
    [_segmentedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:0];
    [_segmentedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:1];
    [_segmentedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:2];
    [_segmentedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:3];
        
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

-(void)viewDidDisappear:(BOOL)animated {
    [TestFlight passCheckpoint:@"CardsView disappeared"];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.fetchedResultsController.delegate = nil;
    [self setFetchedResultsController:nil];
    [self setSegmentedTypeControl:nil];
    [self setTableView:nil];
    [self setSelectedType:nil];
    [self setNoFilesImageView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != nil) return fetchedResultsController;
    
    NSPredicate *typeFilter = [NSPredicate predicateWithFormat:@"type = %@", _selectedType];
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
        dst.weaponType = _selectedType;
	} else if ([segueID isEqualToString:@"ShowWeapon"]) {
        WeaponShowViewController *dst = segue.destinationViewController;
        self.navigationItem.title = _selectedType;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_selectedType style:UIBarButtonItemStyleBordered target:nil action:nil];
        dst.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        [dst setCardsViewController:self];
    } else if ([segueID isEqualToString:@"NFADetails"]) {
        CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView]; 
        NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
        self.navigationItem.title = _selectedType;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_selectedType style:UIBarButtonItemStyleBordered target:nil action:nil];
        NFAInformationViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:index];
    } else if ([segueID isEqualToString:@"ShowPhoto"]) {
        CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView]; 
        NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
        PhotoViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = [self.fetchedResultsController objectAtIndexPath:index];
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
    _selectedType = [_segmentedTypeControl titleForSegmentAtIndex:_segmentedTypeControl.selectedSegmentIndex];
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type = %@", _selectedType];
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // handle error!
    }
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Cards viewed: %@", _selectedType]];

    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
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
    self.navigationItem.title = [NSString stringWithFormat:@"%d file%@ in folder", count, (count == 1) ? @"" : @"s"];

    _noFilesImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Table/%@", _selectedType]];
    _noFilesImageView.hidden = (count != 0);
    
    return count;
}
                       
#pragma mark TESTING WEAPONS below

-(void)loadTestWeapons {
   dispatch_async(dispatch_get_main_queue(), ^{
       // only load test weapons on first load
       NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
       if ([preferences boolForKey:@"TestWeaponsLoaded"]) return;

       [BallisticProfile truncateAll];
       [[NSManagedObjectContext defaultContext] save];
       
       NSArray *calibers = [Caliber findAllSortedBy:@"diameter_inches" ascending:YES];
       
       DebugLog(@"Creating Test Weapon 1");
       Weapon *newWeapon1 = [Weapon createEntity];
       newWeapon1.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
       newWeapon1.model = @"Test Rifle 1";
       newWeapon1.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
       newWeapon1.type = @"Rifles";
       newWeapon1.barrel_length = [NSNumber numberWithDouble:18.0f];
       newWeapon1.finish = @"FDE";
       newWeapon1.threaded_barrel_pitch = @"5/8 x 24 LH";
       newWeapon1.serial_number = [NSString randomStringWithLength:12];
       newWeapon1.purchased_price = [NSDecimalNumber decimalNumberWithString:@"1800.00"];
       newWeapon1.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
       
       UIImage *photo = [UIImage imageNamed:@"Test/test1.jpg"];
       newWeapon1.photo = UIImagePNGRepresentation(photo);
       // Create a thumbnail version of the image for the object.
       CGSize size = photo.size;
       CGFloat ratio = 0;
       ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
       CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
       UIGraphicsBeginImageContext(rect.size);
       [photo drawInRect:rect];
       newWeapon1.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
       UIGraphicsEndImageContext();   
       
       [[NSManagedObjectContext defaultContext] save];

       DebugLog(@"Creating Test Weapon 2");
       Weapon *newWeapon2 = [Weapon createEntity];
       newWeapon2.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
       newWeapon2.model = @"Test Rifle 2";
       newWeapon2.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
       newWeapon2.type = @"Rifles";
       newWeapon2.barrel_length = [NSNumber numberWithDouble:16.0f];
       newWeapon2.finish = @"Wood Furniture";
       newWeapon2.threaded_barrel_pitch = @"1/2 x 28 LH";
       newWeapon2.serial_number = [NSString randomStringWithLength:12];
       newWeapon2.purchased_price = [NSDecimalNumber decimalNumberWithString:@"900.00"];
       newWeapon2.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
       
       photo = [UIImage imageNamed:@"Test/test2.jpg"];
       newWeapon2.photo = UIImagePNGRepresentation(photo);
       // Create a thumbnail version of the image for the object.
       size = photo.size;
       ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
       rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
       UIGraphicsBeginImageContext(rect.size);
       [photo drawInRect:rect];
       newWeapon2.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
       UIGraphicsEndImageContext();
       
       [[NSManagedObjectContext defaultContext] save];

       DebugLog(@"Creating Test Weapon 3");
       Weapon *newWeapon3 = [Weapon createEntity];
       newWeapon3.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
       newWeapon3.model = @"Test Handgun 1";
       newWeapon3.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
       newWeapon3.type = @"Handguns";
       newWeapon3.barrel_length = [NSNumber numberWithDouble:5.2f];
       newWeapon3.finish = @"Stainless/Black";
       newWeapon3.threaded_barrel_pitch = @"3 lug";
       newWeapon3.serial_number = [NSString randomStringWithLength:12];
       newWeapon3.purchased_price = [NSDecimalNumber decimalNumberWithString:@"13000.00"];
       newWeapon3.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
       
       photo = [UIImage imageNamed:@"Test/test3.jpg"];
       newWeapon3.photo = UIImagePNGRepresentation(photo);
       // Create a thumbnail version of the image for the object.
       size = photo.size;
       ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
       rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
       UIGraphicsBeginImageContext(rect.size);
       [photo drawInRect:rect];
       newWeapon3.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
       UIGraphicsEndImageContext();
       
       [[NSManagedObjectContext defaultContext] save];

       DebugLog(@"Creating Test Weapon 4");
       Weapon *newWeapon4 = [Weapon createEntity];
       newWeapon4.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
       newWeapon4.model = @"Test Shotgun";
       newWeapon4.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
       newWeapon4.type = @"Shotguns";
       newWeapon4.barrel_length = [NSNumber numberWithDouble:9.5f];
       newWeapon4.finish = @"Stainless/Black";
       newWeapon4.serial_number = [NSString randomStringWithLength:12];
       newWeapon4.purchased_price = [NSDecimalNumber decimalNumberWithString:@"13000.00"];
       newWeapon4.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
       
       photo = [UIImage imageNamed:@"Test/test4.jpg"];
       newWeapon4.photo = UIImagePNGRepresentation(photo);
       // Create a thumbnail version of the image for the object.
       size = photo.size;
       ratio = (size.width > size.height) ? 320.0 / size.width : 240.0 / size.height;
       rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
       UIGraphicsBeginImageContext(rect.size);
       [photo drawInRect:rect];
       newWeapon4.photo_thumbnail = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
       UIGraphicsEndImageContext();
       
       [[NSManagedObjectContext defaultContext] save];
       
       [preferences setBool:YES forKey:@"TestWeaponsLoaded"];
       [preferences synchronize];
   });
}                       

@end
