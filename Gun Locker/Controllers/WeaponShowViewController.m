//
//  WeaponShowViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeaponShowViewController.h"

@implementation WeaponShowViewController
@synthesize modelLabel = _modelLabel;
@synthesize manufacturerLabel = _manufacturerLabel;
@synthesize photoCountLabel = _photoCountLabel;
@synthesize noteCountLabel = _noteCountLabel;
@synthesize nfaCell = _nfaCell;
@synthesize dopeCardCount = _dopeCardCount;
@synthesize maintenanceCountLabel = _maintenanceCountLabel;
@synthesize malfunctionCountLabel = _malfunctionCountLabel;
@synthesize adjustRoundCountStepper = _adjustRoundCountStepper;
@synthesize quickCleanButton = _quickCleanButton;
@synthesize weaponTypeLabel = _weaponTypeLabel;
@synthesize lastCleanedDateLabel = _lastCleanedDateLabel;
@synthesize lastCleanedCountLabel = _lastCleanedCountLabel;
@synthesize selectedWeapon = _selectedWeapon;
@synthesize cardsViewController = _cardsViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_background"]];
    _weaponTypeLabel.text = _selectedWeapon.type;
    [self updateLastCleanedLabels];
}

- (void)viewWillAppear:(BOOL)animated {
    DataManager *dataManager = [DataManager sharedManager];
    // set title for navigation back button
    self.title = _selectedWeapon.model;
    [self updateTitleView];
    
    _nfaCell.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:kGLShowNFADetailsKey];
    
    _adjustRoundCountStepper.Current = [_selectedWeapon.round_count floatValue];
    _adjustRoundCountStepper.Minimum = 0;
    _adjustRoundCountStepper.Step = 1;
    _adjustRoundCountStepper.NumDecimals = 0;
    _photoCountLabel.text    = [NSString stringWithFormat:@"%d",[_selectedWeapon.photos count]];
    _noteCountLabel.text     = [NSString stringWithFormat:@"%d",[_selectedWeapon.notes count]];
    _nfaCell.detailTextLabel.text       = _selectedWeapon.stamp.nfa_type ? [[dataManager nfaTypes] objectAtIndex:_selectedWeapon.stamp.nfa_type.intValue] : @"n/a";
    
    _dopeCardCount.text              = [NSString stringWithFormat:@"%d",[_selectedWeapon.dope_cards count]];
    _maintenanceCountLabel.text      = [NSString stringWithFormat:@"%d",[_selectedWeapon.maintenances count]];
    _malfunctionCountLabel.text      = [NSString stringWithFormat:@"%d",[_selectedWeapon.malfunctions count]];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)updateTitleView {
    _modelLabel.text = self.title;
    _manufacturerLabel.text = _selectedWeapon.manufacturer.displayName;    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"EditWeapon"]) {
        WeaponAddEditViewController *dst =[[segue.destinationViewController viewControllers] objectAtIndex:0];
		dst.delegate = self;
        dst.weaponType = _selectedWeapon.type;
        dst.selectedWeapon = _selectedWeapon;
        [TestFlight passCheckpoint:@"WeaponAddEdit viewed"];
	} else if ([segueID isEqualToString:@"Malfunctions"]) {
        MalfunctionsViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = _selectedWeapon;
        [TestFlight passCheckpoint:@"Malfunctions viewed"];
	} else if ([segueID isEqualToString:@"Maintenances"]) {
        MaintenancesViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = _selectedWeapon;
        [TestFlight passCheckpoint:@"Maintenance viewed"];
	} else if ([segueID isEqualToString:@"NFA"]) {
        NFAInformationViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = _selectedWeapon;
    } else if ([segueID isEqualToString:@"Notes"]) {
        NotesListViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = _selectedWeapon;
        [TestFlight passCheckpoint:@"Notes viewed"];
    } else if ([segueID isEqualToString:@"DopeCards"]) {
        DopeCardsViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = _selectedWeapon;
        [TestFlight passCheckpoint:@"DopeCards viewed"];
    } else if ([segueID isEqualToString:@"Photos"]) {
        PhotosTableViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = _selectedWeapon;
        [TestFlight passCheckpoint:@"Photos viewed"];
    }    
}

#pragma mark - WeaponAddViewControllerDelegate
- (void)WeaponAddViewControllerDidCancel:(WeaponAddEditViewController *)controller {
	[self dismissViewControllerAnimated:YES completion:nil];
    [TestFlight passCheckpoint:@"WeaponAddEdit cancelled"];
}

- (void)WeaponAddViewControllerDidSave:(WeaponAddEditViewController *)controller {
    [self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
    [TestFlight passCheckpoint:@"WeaponAddEdit saved"];
}

# pragma mark - Tableview 
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" owner:self options:nil] 
                                              objectAtIndex:0];
    
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // manually set cellPath since tableView indexPathForCell: is returning wrong row ??
    NSIndexPath *nfaCellPath = [NSIndexPath indexPathForRow:2 inSection:0];
    // compare row and section since NSIndexPath isEqual:  is broken on ios5
    if((![[NSUserDefaults standardUserDefaults] boolForKey:kGLShowNFADetailsKey]) && 
        nfaCellPath.row == indexPath.row && 
        nfaCellPath.section == indexPath.section) {
        return 0;
    } 
    
    return 44.0;
}

# pragma mark - Actions

- (IBAction)roundCountAdjust:(id)sender {
    _selectedWeapon.round_count = [NSNumber numberWithInt:(int)_adjustRoundCountStepper.Current];
    [[DataManager sharedManager] saveAppDatabase];
    [self updateLastCleanedLabels];
}

- (IBAction)changeWeaponTypeTapped:(id)sender {
    changeCategorySheet = [[UIActionSheet alloc] initWithTitle:@"Change weapon type to"
                                                      delegate:self
                                             cancelButtonTitle:kGLCancelText
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Handgun", @"Rifle", @"Shotgun", @"Miscellaneous", nil];
    [changeCategorySheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)cleanNowTapped:(id)sender {
    _selectedWeapon.last_cleaned_date = [NSDate date];
    _selectedWeapon.last_cleaned_round_count = _selectedWeapon.round_count;
    [[DataManager sharedManager] saveAppDatabase];

    [self updateLastCleanedLabels];
}

- (IBAction)deleteTapped:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:kGLCancelText
                   destructiveButtonTitle:@"Delete Weapon"
                        otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == changeCategorySheet) {
        NSArray *categories =  [NSArray arrayWithObjects:@"Handguns", @"Rifles", @"Shotguns", @"Misc.", nil];
        if (buttonIndex < [categories count]) {
            _selectedWeapon.type = _weaponTypeLabel.text = [categories objectAtIndex:buttonIndex];

            [[DataManager sharedManager] saveAppDatabase];        
            _weaponTypeLabel.text = _selectedWeapon.type;
            [_cardsViewController.selectedTypeControl setSelectedSegmentIndex:[categories indexOfObject:_selectedWeapon.type]];
            _cardsViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:_selectedWeapon.type 
                                                                                                     style:UIBarButtonItemStyleBordered
                                                                                                    target:nil 
                                                                                                    action:nil];
            [self updateTitleView];

            [TestFlight passCheckpoint:@"User changed weapon type"];
        }
    } else { // delete confirmation
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [_selectedWeapon deleteEntity];
            [[DataManager sharedManager] saveAppDatabase];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    NSString *type = _selectedWeapon.type;
    type = ([type isEqualToString:@"Misc."]) ? @"Miscellaneous" : [type substringToIndex:[type length] -1];

    for (UIView* view in [actionSheet subviews]) {
        if ([[[view class] description] isEqualToString:@"UIAlertButton"]) {
            if ([view respondsToSelector:@selector(title)]) {
                if ([[view performSelector:@selector(title)] isEqualToString:type] && [view respondsToSelector:@selector(setEnabled:)]) {
                    [view performSelector:@selector(setEnabled:) withObject:nil];
                }		
            }        
        }   
    }
}

-(void)updateLastCleanedLabels {
    if (_selectedWeapon.last_cleaned_date) {
        _lastCleanedDateLabel.text = [NSString stringWithFormat:@"Last cleaned %@", 
                                      [[_selectedWeapon.last_cleaned_date distanceOfTimeInWords] lowercaseString]];

        _lastCleanedCountLabel.text = [NSString stringWithFormat:@"%d rounds fired since", 
                                       [_selectedWeapon.round_count intValue] - [_selectedWeapon.last_cleaned_round_count intValue]];
    } else {
        _lastCleanedDateLabel.text = @"Never cleaned";
        _lastCleanedCountLabel.text = @"";
    }
}

@end
