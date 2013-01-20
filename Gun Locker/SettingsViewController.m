//
//  SettingsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "KKPasscodeLock.h"

@implementation SettingsViewController
@synthesize nightModeControl = _nightModeControl;
@synthesize rangeUnitsControl = _rangeUnitsControl;
@synthesize rangeStartStepper = _rangeStartStepper, rangeEndStepper = _rangeEndStepper, rangeStepStepper = _rangeStepStepper;
@synthesize reticleUnitsControl = _reticleUnitsControl;
@synthesize windLeadingLabel = _windLeadingLabel;
@synthesize exportWeaponsButton = _exportWeaponsButton;
@synthesize exportMagazinesButton = _exportMagazinesButton;
@synthesize exportAmmunitionButton = _exportAmmunitionButton;
@synthesize directionControl = _directionControl;
@synthesize showNFAInformationSwitch = _showNFAInformationSwitch;
@synthesize passcodeCell = _passcodeCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataManager = [DataManager sharedManager];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    _showNFAInformationSwitch.on = [defaults boolForKey: kGLShowNFADetailsKey];
    _passcodeCell.detailTextLabel.text   = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";
    _rangeUnitsControl.selectedSegmentIndex   = [defaults integerForKey:kGLRangeUnitsControlKey];
    _reticleUnitsControl.selectedSegmentIndex = [defaults integerForKey:kGLReticleUnitsControlKey];

    _rangeStartStepper.Current = [defaults integerForKey:kGLRangeStartKey];
    _rangeEndStepper.Current   = [defaults integerForKey:kGLRangeEndKey];
    _rangeStepStepper.Current  = [defaults integerForKey:kGLRangeStepKey];
    _rangeStartStepper.Minimum = 5;
    _rangeStartStepper.Maximum = 500;
    _rangeEndStepper.Minimum   = 100;
    _rangeEndStepper.Maximum   = 2000;
    _rangeStepStepper.Minimum  = 1;
    _rangeStepStepper.Maximum  = 250;
    _rangeStartStepper.VariableSteps  = _rangeEndStepper.VariableSteps  = _rangeStepStepper.VariableSteps = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:5],  [NSNumber numberWithInt:50], nil];
    _rangeStartStepper.VariableRanges = _rangeEndStepper.VariableRanges = _rangeStepStepper.VariableRanges = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:10], [NSNumber numberWithInt:50], nil];
    _rangeStartStepper.NumDecimals    = _rangeEndStepper.NumDecimals    = _rangeStepStepper.NumDecimals = 0;
    _rangeStartStepper.IsEditableTextField = _rangeEndStepper.IsEditableTextField = _rangeStepStepper.IsEditableTextField = NO;
    
    _windLeadingLabel.text = [NSString stringWithFormat:@"%@ %@", [defaults stringForKey:@"speedType"], [defaults stringForKey:@"speedUnit"]];
    _directionControl.selectedSegmentIndex = [defaults integerForKey:kGLDirectionControlKey];
    _nightModeControl.selectedSegmentIndex = [defaults integerForKey:kGLNightModeControlKey];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    int weaponCount     = [Weapon countOfEntities];
    int magazinesCount  = [Magazine countOfEntities];
    int ammunitionCount = [Ammunition countOfEntities];
    
    [_exportWeaponsButton setTitle:[NSString stringWithFormat:@"Export Weapons (%d)", weaponCount] 
                          forState:UIControlStateNormal];
    [_exportMagazinesButton setTitle:[NSString stringWithFormat:@"Export Magazines (%d)", magazinesCount] 
                            forState:UIControlStateNormal];
    [_exportAmmunitionButton setTitle:[NSString stringWithFormat:@"Export Ammunition (%d)", ammunitionCount] 
                             forState:UIControlStateNormal];
    
    [_exportWeaponsButton setEnabled:weaponCount];
    [_exportMagazinesButton setEnabled:magazinesCount];
    [_exportAmmunitionButton setEnabled:ammunitionCount];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [TestFlight passCheckpoint:@"Settings disappeared"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"WindLeadingTable"])
        [[segue destinationViewController] setDelegate:self];
}

#pragma mark Method Delegates

- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController {
    _passcodeCell.detailTextLabel.text = ([[KKPasscodeLock sharedLock] isPasscodeRequired]) ? @"On" : @"Off";
}

- (void)windLeadingTableViewController:(WindLeadingTableViewController *)controller didSelectWindLeading:(NSString *)selectedWindLeading {
	_windLeadingLabel.text = selectedWindLeading;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Actions

- (IBAction)showNFAInformationTapped:(UISwitch *)nfaSwitch {
    if (nfaSwitch.isOn) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Showing 'NFA Information'"
                                                          message:@"Look for NFA information in each weapon's 'Details' section."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }

    [TestFlight passCheckpoint:[NSString stringWithFormat:@"NFAInformation switched %@", nfaSwitch.isOn ? @"on" : @"off" ]];
}

- (IBAction)saveSettings:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:_showNFAInformationSwitch.on forKey: kGLShowNFADetailsKey];
    [defaults setInteger:[_nightModeControl selectedSegmentIndex] forKey: kGLNightModeControlKey];
    [defaults setInteger:[_rangeUnitsControl selectedSegmentIndex] forKey:kGLRangeUnitsControlKey];
    [defaults setInteger:[_reticleUnitsControl selectedSegmentIndex] forKey:kGLReticleUnitsControlKey];
    [defaults setInteger:[_directionControl selectedSegmentIndex] forKey:kGLDirectionControlKey];
    [defaults setInteger:(int)_rangeStartStepper.Current forKey:kGLRangeStartKey];
    [defaults setInteger:(int)_rangeEndStepper.Current forKey:kGLRangeEndKey];
    [defaults setInteger:(int)_rangeStepStepper.Current forKey:kGLRangeStepKey];
}

- (IBAction)cardSortingChanged:(UISegmentedControl *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sender.selectedSegmentIndex ? @"make" : @"model" forKey:kGLCardSortByTypeKey];
}

- (IBAction)updateStepperRanges:(id)sender {
    _rangeStartStepper.Maximum = _rangeEndStepper.Current - _rangeStepStepper.Current;
    _rangeEndStepper.Minimum   = _rangeStartStepper.Current + _rangeStepStepper.Current;
    _rangeStepStepper.Maximum  = _rangeEndStepper.Current - _rangeStartStepper.Current;    
}

- (IBAction)exportTapped:(UIButton *)button {
    exportButton = button;
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:kGLCancelText
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Email", @"iTunes File Sharing", nil] 
     showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark Table delegates
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" owner:self options:nil] 
                                              objectAtIndex:0];
    
    headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell == _passcodeCell) {
        KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];        
    }
}


#pragma mark CSV export

-(NSString *)csvDumpWeapons {
    BOOL showNFA = [[NSUserDefaults standardUserDefaults] boolForKey: kGLShowNFADetailsKey];
    
    NSMutableString *tempString = [[NSMutableString alloc] initWithString:@"Type,Manufacturer,Model,Caliber,Finish,Serial #,Barrel Length,Barrel Thread Pitch,Purchased Date,Purchased Price,Round Count"];
    if (showNFA) 
        [tempString appendString:@",NFA Type,NFA Transfer Type,NFA Stamp Number,NFA Form Sent,NFA Check Cashed,NFA Went Pending,NFA Stamp Received"];
    
    [tempString appendString:@"\n"];
    
    NSArray *types = [NSArray arrayWithObjects:@"Handguns", @"Rifles", @"Shotguns", @"Misc.", nil];
    for (NSString *type in types) {
        for (Weapon *weapon in [Weapon findByAttribute:@"type" withValue:type andOrderBy:@"manufacturer,model" ascending:YES]) {
            [tempString appendFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@", 
             weapon.type, 
             weapon.manufacturer.name, 
             weapon.model,
             weapon.caliber ?: @"", 
             weapon.finish ?: @"", 
             weapon.serial_number ?: @"", 
             weapon.barrel_length ?: @"", 
             weapon.threaded_barrel_pitch ?: @"", 
             weapon.purchased_date, 
             weapon.purchased_price, 
             weapon.round_count];
            if (showNFA && weapon.stamp.nfa_type) {
                StampInfo *stamp = weapon.stamp;
                [tempString appendFormat:@",%@,%@,%@,%@,%@,%@,%@", 
                 [dataManager.nfaTypes objectAtIndex:stamp.nfa_type.intValue], 
                 stamp.transfer_type ? [dataManager.transferTypes objectAtIndex:stamp.transfer_type.intValue] : @"", 
                 stamp.number ?: @"",
                 stamp.form_sent ?: @"",
                 stamp.check_cashed ?: @"",
                 stamp.went_pending ?: @"",
                 stamp.stamp_received ?: @""];
            }
            [tempString appendString:@"\n"];            
        }
        
    }
    return [tempString copy];
}

-(NSString *)csvDumpMagazines {
    NSMutableString *tempString = [[NSMutableString alloc] initWithString:@"Brand,Type,Caliber,Capacity,Color,Count\n"];
    
    for (Magazine *magazine in [Magazine findAll]) {
        [tempString appendFormat:@"%@,%@,%@,%@,%@,%@\n",
         magazine.brand,
         magazine.type,
         magazine.caliber,
         magazine.capacity ?: @"",
         magazine.color ?: @"",
         magazine.count];
    }
    return [tempString copy];
}

-(NSString *)csvDumpAmmunition {
    NSMutableString *tempString = [[NSMutableString alloc] initWithString:@"Brand,Type,Caliber,Count,Original Count,Purchase Date,Retailer, Purchase Price,Cost per Round\n"];
    
    for (Ammunition *ammunition in [Magazine findAll]) {
        [tempString appendFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@\n",
         ammunition.brand,
         ammunition.type,
         ammunition.caliber,
         ammunition.count,
         ammunition.count_original,
         ammunition.purchase_date,
         ammunition.retailer,
         ammunition.purchase_price,
         ammunition.cpr];
    }
    return [tempString copy];
}

-(NSString *)csvDumpAll {
    NSMutableString *tempString = [[NSMutableString alloc] init];
    [tempString appendFormat:@"////----  WEAPONS (%d)\n", [Weapon countOfEntities]];
    [tempString appendString:[self csvDumpWeapons]];
    
    [tempString appendFormat:@"////---- MAGAZINES (%d)\n", [Magazine countOfEntities]];
    [tempString appendString:[self csvDumpMagazines]];
    
    [tempString appendFormat:@"////---- AMMUNITION (%d)\n", [Ammunition countOfEntities]];
    [tempString appendString:[self csvDumpAmmunition]];
    
    return [tempString copy];
}

#pragma mark Action Sheet delegates

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 1) return;
  
    NSData *data;
    NSString *title = [[exportButton.titleLabel.text componentsSeparatedByString:@" "] objectAtIndex:1];
    
    if ([title isEqualToString:@"All"]) {
        data = [[self csvDumpAll] dataUsingEncoding:NSUTF8StringEncoding]; 
    } else if ([title isEqualToString:@"Weapons"]) {
        data = [[self csvDumpWeapons]  dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([title isEqualToString:@"Magazines"]) {
        data = [[self csvDumpMagazines] dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([title isEqualToString:@"Ammunition"]) {
        data = [[self csvDumpAmmunition] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"Gun Locker - %@ - %@.csv", title, [NSDate date]];
    
    if (buttonIndex == 0) { // Email       
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        [picker setSubject:[NSString stringWithFormat:@"Gun Locker - %@", title]];
        [picker addAttachmentData:data mimeType:@"text/csv" fileName:fileName];
        [picker setToRecipients:[NSArray array]];
        [picker setMessageBody:@"Attached" isHTML:NO];
        [picker setMailComposeDelegate:self];
        [self presentModalViewController:picker animated:YES];                    
    } else { //iTunes File Sharing
        // write to disk
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];      
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        [data writeToFile:filePath atomically:YES];
        
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Data %@ \nSuccess!", title] 
                                    message:[NSString stringWithFormat:@"Saved as filename:\n %@", fileName] 
                                   delegate:self 
                          cancelButtonTitle:nil 
                          otherButtonTitles:@"Ok", nil] show];
        

        NSLog(@"!%@!", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

@end
