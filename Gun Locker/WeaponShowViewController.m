//
//  WeaponShowViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeaponShowViewController.h"

@implementation WeaponShowViewController
@synthesize notesCell;
@synthesize modelLabel;
@synthesize manufacturerLabel;
@synthesize nfaCell;
@synthesize dopeCardsCell;
@synthesize maintenanceCountLabel;
@synthesize malfunctionCountLabel;
@synthesize adjustRoundCountStepper;
@synthesize quickCleanButton;
@synthesize weaponTypeLabel;
@synthesize selectedWeapon;
@synthesize cardsViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    weaponTypeLabel.text = self.selectedWeapon.type;
}

- (void)viewWillAppear:(BOOL)animated {
    DataManager *dataManager = [DataManager sharedManager];
    // set title for navigation back button
    self.title = selectedWeapon.model;
    [self setTitleView];
    
    // doesnt do anything
//    nfaCell.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"showNFADetails"];
    
    self.adjustRoundCountStepper.Current = [self.selectedWeapon.round_count floatValue];
    self.adjustRoundCountStepper.Minimum = 0;
    self.adjustRoundCountStepper.Step = 1;
    self.adjustRoundCountStepper.NumDecimals = 0;
    self.notesCell.detailTextLabel.text     = [NSString stringWithFormat:@"%d",[self.selectedWeapon.notes count]];
    self.nfaCell.detailTextLabel.text       = self.selectedWeapon.stamp.nfa_type ? [[dataManager nfaTypes] objectAtIndex:[self.selectedWeapon.stamp.nfa_type integerValue]] : @"n/a";
    self.dopeCardsCell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[self.selectedWeapon.dope_cards count]];
    self.maintenanceCountLabel.text         = [NSString stringWithFormat:@"%d",[self.selectedWeapon.maintenances count]];
    self.malfunctionCountLabel.text         = [NSString stringWithFormat:@"%d",[self.selectedWeapon.malfunctions count]];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)setTitleView {
    self.modelLabel.text = self.title;
    self.manufacturerLabel.text = selectedWeapon.manufacturer.short_name ? selectedWeapon.manufacturer.short_name : selectedWeapon.manufacturer.name;    
}

- (void)viewDidUnload {
    [self setNotesCell:nil];
    [self setNfaCell:nil];
    [self setDopeCardsCell:nil];
    [self setMaintenanceCountLabel:nil];
    [self setMalfunctionCountLabel:nil];
    [self setQuickCleanButton:nil];
    [self setAdjustRoundCountStepper:nil];
    [self setWeaponTypeLabel:nil];
    [self setModelLabel:nil];
    [self setManufacturerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - WeaponAddViewControllerDelegate

- (void)WeaponAddViewControllerDidCancel:(WeaponAddEditViewController *)controller {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)WeaponAddViewControllerDidSave:(WeaponAddEditViewController *)controller {
    [self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 24)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
	label.shadowColor = [UIColor clearColor];
	label.backgroundColor = [UIColor clearColor];
    
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // manually set cellPath since tableView indexPathForCell: is returning wrong row ??
    NSIndexPath *nfaCellPath = [NSIndexPath indexPathForRow:1 inSection:0];
    // compare row and section since NSIndexPath isEqual:  is broken on ios5
    if((![[NSUserDefaults standardUserDefaults] boolForKey:@"showNFADetails"]) && 
        nfaCellPath.row == indexPath.row && 
        nfaCellPath.section == indexPath.section) {
        return 0;
    } 
    
    return 40.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"EditWeapon"]) {
        WeaponAddEditViewController *dst =[[segue.destinationViewController viewControllers] objectAtIndex:0];
		dst.delegate = self;
        dst.weaponType = self.selectedWeapon.type;
        dst.selectedWeapon = self.selectedWeapon;
	} else if ([segueID isEqualToString:@"Malfunctions"]) {
        MalfunctionsTableViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = self.selectedWeapon;
	} else if ([segueID isEqualToString:@"Maintenances"]) {
        MaintenancesTableViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = self.selectedWeapon;
	} else if ([segueID isEqualToString:@"NFA"]) {
        NFAInformationViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = self.selectedWeapon;
    } else if ([segueID isEqualToString:@"Notes"]) {
        NotesTableViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = self.selectedWeapon;
    } else if ([segueID isEqualToString:@"DopeCards"]) {
        DopeCardsTableViewController *dst = segue.destinationViewController;
        dst.selectedWeapon = self.selectedWeapon;
    }

}

# pragma mark - Actions

- (IBAction)roundCountAdjust:(id)sender {
    self.selectedWeapon.round_count = [NSNumber numberWithInt:(int)adjustRoundCountStepper.Current];
    [[NSManagedObjectContext defaultContext] save];
}

- (IBAction)changeWeaponTypeTapped:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Change weapon type to"
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Pistol", @"Rifle", @"Shotgun", @"Miscellaneous", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSArray *categories =  [NSArray arrayWithObjects:@"Pistols", @"Rifles", @"Shotguns", @"Misc.", nil];
    if (buttonIndex < [categories count]) {
        selectedWeapon.type = weaponTypeLabel.text = [categories objectAtIndex:buttonIndex];

        [[NSManagedObjectContext defaultContext] save];        
        weaponTypeLabel.text = selectedWeapon.type;
        [self.cardsViewController.segmentedTypeControl setSelectedSegmentIndex:[categories indexOfObject:selectedWeapon.type]];
        self.cardsViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:selectedWeapon.type 
                                                                                 style:UIBarButtonItemStyleBordered target:nil action:nil];
        [self setTitleView];
    }    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    NSString *type = selectedWeapon.type;
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

@end
