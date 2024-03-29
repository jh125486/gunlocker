//
//  CardsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CardsViewController.h"

@implementation CardsViewController
@synthesize selectedTypeControl = _selectedTypeControl, selectedType = _selectedType;
@synthesize noFilesImageView = _noFilesImageView;
@synthesize tableView;
@synthesize initialLoad = _initialLoad;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _initialLoad = true;
    
    types = [NSArray arrayWithObjects:@"Handguns", @"Rifles", @"Shotguns", @"Misc.", nil];

//    [self setupFRCArray];

    #ifdef DEBUG
    if([Weapon countOfEntities] == 0) [self loadTestWeapons];    
    #endif
    
    self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;

    UIImage *segmentSelected   = [[UIImage imageNamed:@"Images/tabs/selected"]   resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage *segmentUnselected = [[UIImage imageNamed:@"Images/tabs/unselected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage *segmentSelectedUnselected   = [UIImage imageNamed:@"Images/tabs/selected_unselected"];
    UIImage *segUnselectedSelected       = [UIImage imageNamed:@"Images/tabs/unselected_selected"];
    UIImage *segmentUnselectedUnselected = [UIImage imageNamed:@"Images/tabs/unselected_unselected"];
    
    [_selectedTypeControl setBackgroundImage:segmentUnselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_selectedTypeControl setBackgroundImage:segmentSelected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_selectedTypeControl setDividerImage:segmentUnselectedUnselected
                          forLeftSegmentState:UIControlStateNormal
                          rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_selectedTypeControl setDividerImage:segmentSelectedUnselected
                          forLeftSegmentState:UIControlStateSelected
                          rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_selectedTypeControl setDividerImage:segUnselectedSelected
                          forLeftSegmentState:UIControlStateNormal
                          rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:22.0f], UITextAttributeFont,
                                      [UIColor darkGrayColor], UITextAttributeTextColor, 
                                      [UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                      [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                      nil];
    [_selectedTypeControl setTitleTextAttributes:normalAttributes forState:UIControlStateNormal];
    
    NSDictionary *selectedAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:22.0f],UITextAttributeFont,
                                        [UIColor blackColor], UITextAttributeTextColor, 
                                        [UIColor lightTextColor], UITextAttributeTextShadowColor,
                                        [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                        nil] ;
    [_selectedTypeControl setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
    
    _selectedType = [_selectedTypeControl titleForSegmentAtIndex:_selectedTypeControl.selectedSegmentIndex];
    
    // sets initial segment
    _selectedTypeControl.apportionsSegmentWidthsByContent = YES;
    
    [_selectedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:0];
    [_selectedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:1];
    [_selectedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:2];
    [_selectedTypeControl setContentOffset:CGSizeMake(0.0f, 3.0f) forSegmentAtIndex:3];
        
    if([Weapon countOfEntities] == 0) // enable for deletions?
        self.navigationItem.leftBarButtonItem.enabled = NO;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPasscodeModal)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([DataManager sharedManager].cardSortingChanged) {
        [self setupFRCArray];
        [DataManager sharedManager].cardSortingChanged = NO;
    }
    [self segmentedTypeControlClicked];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_initialLoad) [self showPasscodeModal];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TestFlight passCheckpoint:@"CardsView disappeared"];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateTitle {
    NSInteger count = [[[_fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
    self.navigationItem.title = [NSString stringWithFormat:@"%d file%@ in folder", count, (count == 1) ? @"" : @"s"];
    
    _noFilesImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Images/Table/Blanks/%@", _selectedType]];
    _noFilesImageView.hidden = (count != 0);
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        dst.selectedWeapon = [_fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        [dst setCardsViewController:self];
    } else if ([segueID isEqualToString:@"NFADetails"]) {
        CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView]; 
        NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
        self.navigationItem.title = _selectedType;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_selectedType style:UIBarButtonItemStyleBordered target:nil action:nil];
        NFAInformationViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = [_fetchedResultsController objectAtIndexPath:index];
    } else if ([segueID isEqualToString:@"ShowPhoto"]) {
        CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView]; 
        NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
        PhotoViewController *dst = segue.destinationViewController;
        Weapon *weapon = [_fetchedResultsController objectAtIndexPath:index];
        dst.passedPhoto = weapon.primary_photo;
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
    previousType = _selectedType;
    _selectedType = [_selectedTypeControl titleForSegmentAtIndex:_selectedTypeControl.selectedSegmentIndex];
    _fetchedResultsController = [frcArray objectForKey:_selectedType];
    [self updateTitle];
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Cards viewed: %@", _selectedType]];

    [self.tableView flashScrollIndicators];
}

# pragma mark - KKPasscodeViewControllerDelegate

- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController {
    // TODO delete all data
    [[[UIAlertView alloc] initWithTitle:@"" 
                                message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted." 
                               delegate:self 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController {
    [[[UIAlertView alloc] initWithTitle:@"" 
                                message:@"You have entered an incorrect passcode too many times." 
                               delegate:self 
                      cancelButtonTitle:@"OK" 
                      otherButtonTitles:nil] show];
}

- (void)showPasscodeModal {
    if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
        KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil] ;
        vc.mode = KKPasscodeModeEnter;
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(),^ {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            nav.navigationBar.barStyle = UIBarStyleBlack;
            nav.navigationBar.opaque = NO;
            
            [self presentViewController:nav
                               animated:YES
                             completion:^{_initialLoad = NO;}
             ];
        });
    }
}

#pragma mark FRC
-(void)setupFRCArray {
    NSMutableDictionary *frcTemp = [[NSMutableDictionary alloc] initWithCapacity:types.count];
    NSString *sortByString = [[NSUserDefaults standardUserDefaults] integerForKey:kGLCardSortByTypeKey] == 0
                                ? @"manufacturer.name,model"
                                : @"model,manufacturer.name";
    
    for (NSString *type in types) {
    
        NSFetchRequest *weaponsRequest = [Weapon requestAllSortedBy:sortByString
                                                          ascending:YES
                                                      withPredicate:[NSPredicate predicateWithFormat:@"type = %@", type]];
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:weaponsRequest 
                                                                              managedObjectContext:[NSManagedObjectContext defaultContext]
                                                                                sectionNameKeyPath:nil 
                                                                                         cacheName:nil];
        frc.delegate = self;
        NSError *error = nil;
        if (![frc performFetch:&error]) { // handle error!
        }
        frcTemp[type] = frc;
    } 
    
    frcArray = [frcTemp copy];
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The _fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(WeaponCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The _fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self updateTitle];
//    [self.tableView reloadData];
    [self.tableView endUpdates];
}

#pragma mark - TableView

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[_fetchedResultsController objectAtIndexPath:indexPath] deleteEntity];
        [[DataManager sharedManager] saveAppDatabase];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"WeaponCell";
    WeaponCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(WeaponCell*)cell atIndexPath:(NSIndexPath *)indexPath{
    [cell configureWithWeapon:[_fetchedResultsController objectAtIndexPath:indexPath]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_fetchedResultsController sections][section] numberOfObjects];
}

# pragma mark TESTING load Test Weapons
-(void)loadTestWeapons {
    
    // only load test weapons on first load
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if ([preferences boolForKey:@"TestWeaponsLoaded"]) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{        
        NSArray *calibers = [Caliber findAllSortedBy:@"diameter_inches" ascending:YES];
        
        DebugLog(@"Creating Test Weapon 1");

        _fetchedResultsController = frcArray[@"Rifles"];

        Weapon *newWeapon1 = [Weapon createEntity];
        DebugLog(@"count : %d", [Manufacturer countOfEntities]);
        newWeapon1.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon1.model = @"My Rifle 1";
        newWeapon1.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon1.type = @"Rifles";
        newWeapon1.barrel_length = @(18.0f);
        newWeapon1.finish = @"FDE";
        newWeapon1.threaded_barrel_pitch = @"5/8 x 24 LH";
        newWeapon1.serial_number = [NSString randomStringWithLength:12];
        newWeapon1.purchased_price = [NSDecimalNumber decimalNumberWithString:@"1800.00"];
        newWeapon1.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];            
        Photo *photo1 = [Photo createEntity];        
        [photo1 setPhotoAndCreateThumbnailFromImage:[UIImage imageNamed:@"Testing/Images/test1.jpg"]];
        newWeapon1.primary_photo = photo1;
        photo1.weapon = newWeapon1;
        [[DataManager sharedManager] saveAppDatabase];
        
        DebugLog(@"Creating Test Weapon 2");
        _fetchedResultsController = [frcArray objectForKey:@"Rifles"];
        Weapon *newWeapon2 = [Weapon createEntity];
        newWeapon2.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon2.model = @"My Rifle 2";
        newWeapon2.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon2.type = @"Rifles";
        newWeapon2.barrel_length = [NSNumber numberWithDouble:16.0f];
        newWeapon2.finish = @"Wood Furniture";
        newWeapon2.threaded_barrel_pitch = @"3 Lug";
        newWeapon2.serial_number = [NSString randomStringWithLength:12];
        newWeapon2.purchased_price = [NSDecimalNumber decimalNumberWithString:@"900.00"];
        newWeapon2.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        Photo *photo2 = [Photo createEntity];
        [photo2 setPhotoAndCreateThumbnailFromImage:[UIImage imageNamed:@"Testing/Images/test2.jpg"]];
        newWeapon2.primary_photo = photo2;
        photo2.weapon = newWeapon2;
        [[DataManager sharedManager] saveAppDatabase];
        
        DebugLog(@"Creating Test Weapon 4");
        _fetchedResultsController = [frcArray objectForKey:@"Shotguns"];
        Weapon *newWeapon4 = [Weapon createEntity];
        newWeapon4.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon4.model = @"My Shotgun";
        newWeapon4.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon4.type = @"Shotguns";
        newWeapon4.barrel_length = [NSNumber numberWithDouble:9.5f];
        newWeapon4.finish = @"Stainless/Black";
        newWeapon4.serial_number = [NSString randomStringWithLength:12];
        newWeapon4.purchased_price = [NSDecimalNumber decimalNumberWithString:@"13000.00"];
        newWeapon4.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        Photo *photo4 = [Photo createEntity];
        [photo4 setPhotoAndCreateThumbnailFromImage:[UIImage imageNamed:@"Testing/Images/test4.jpg"]];
        newWeapon4.primary_photo = photo4;
        photo4.weapon = newWeapon4;
        [[DataManager sharedManager] saveAppDatabase];
        
        DebugLog(@"Creating Test Weapon 3");
        _fetchedResultsController = [frcArray objectForKey:@"Handguns"];
        Weapon *newWeapon3 = [Weapon createEntity];
        newWeapon3.manufacturer = [[Manufacturer findAll]  objectAtIndex:arc4random() % [Manufacturer countOfEntities]];
        newWeapon3.model = @"My Handgun";
        newWeapon3.caliber = [[calibers objectAtIndex:arc4random() % [calibers count]] name];
        newWeapon3.type = @"Handguns";
        newWeapon3.barrel_length = [NSNumber numberWithDouble:5.2f];
        newWeapon3.finish = @"Stainless/Black";
        newWeapon3.threaded_barrel_pitch = @"16x1 LH";
        newWeapon3.serial_number = [NSString randomStringWithLength:12];
        newWeapon3.purchased_price = [NSDecimalNumber decimalNumberWithString:@"2000.00"];
        newWeapon3.purchased_date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)(60 * 60 * 24 * arc4random_uniform(1000))];
        Photo *photo3 = [Photo createEntity];
        [photo3 setPhotoAndCreateThumbnailFromImage:[UIImage imageNamed:@"Testing/Images/test3.jpg"]];
        newWeapon3.primary_photo = photo3;
        photo3.weapon = newWeapon3;
        [[DataManager sharedManager] saveAppDatabase];
        
        [preferences setBool:YES forKey:@"TestWeaponsLoaded"];
        [preferences synchronize];
                
        _fetchedResultsController = [frcArray objectForKey:@"Handguns"];
        previousType = @"Handguns";
        [_selectedTypeControl setSelectedSegmentIndex:0];
    });
}              

@end
