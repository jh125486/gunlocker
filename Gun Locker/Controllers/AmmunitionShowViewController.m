//
//  AmmunitionShowViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmmunitionShowViewController.h"

@implementation AmmunitionShowViewController
@synthesize brandLabel = _brandLabel;
@synthesize typeLabel = _typeLabel;
@synthesize caliberLabel = _caliberLabel;
@synthesize countLabel = _countLabel;
@synthesize cprLabel = _cprLabel;
@synthesize purchasedFromLabel = _purchasedFromLabel;
@synthesize purchaseDateLabel = _purchaseDateLabel;
@synthesize roundsFiredButton = _roundsFiredButton;
@synthesize selectedAmmunition = _selectedAmmunition;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Iamges/Table/tableView_background"]];
    
    roundsFiredAlertView = [[UIAlertView alloc] initWithTitle:@"Rounds Fired" 
                                                      message:nil 
                                                     delegate:self 
                                            cancelButtonTitle:kGLCancelText 
                                            otherButtonTitles:@"Fire!", nil];
    
    roundsBoughtAlertView = [[UIAlertView alloc] initWithTitle:@"Rounds Bought" 
                                                       message:nil 
                                                      delegate:self 
                                             cancelButtonTitle:kGLCancelText 
                                             otherButtonTitles:@"Buy!", nil];
    
    roundsFiredAlertView.alertViewStyle = roundsBoughtAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [roundsFiredAlertView textFieldAtIndex:0].placeholder   = [roundsBoughtAlertView textFieldAtIndex:0].placeholder = @"Number of Rounds";
    [roundsFiredAlertView textFieldAtIndex:0].keyboardType  = [roundsBoughtAlertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [roundsFiredAlertView textFieldAtIndex:0].textAlignment = [roundsBoughtAlertView textFieldAtIndex:0].textAlignment = UITextAlignmentCenter;
    
    currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:[NSLocale currentLocale]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAmmo];
}

-(void)loadAmmo {
    _brandLabel.text   = _selectedAmmunition.brand;
    _typeLabel.text    = _selectedAmmunition.type;
    _caliberLabel.text = _selectedAmmunition.caliber;
    _cprLabel.text     = [currencyFormatter stringFromNumber:_selectedAmmunition.cpr];
    _purchasedFromLabel.text = _selectedAmmunition.retailer;
    _purchaseDateLabel.text = [_selectedAmmunition.purchase_date onlyDate];
    [self updateCount];
}

-(void)updateCount {
    _countLabel.text = [NSString stringWithFormat:@"%@/%@", _selectedAmmunition.count, _selectedAmmunition.count_original];
    _roundsFiredButton.enabled = ([_selectedAmmunition.count intValue] != 0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"EditAmmunition"]) {
        AmmunitionAddEditViewController *dst = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        dst.selectedAmmunition = _selectedAmmunition;
    }
}

#pragma mark UIAlertView

- (IBAction)roundsFiredTapped:(id)sender {
    [roundsFiredAlertView show];
}

- (IBAction)roundsBoughtTapped:(id)sender {
    [roundsBoughtAlertView show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        int count = [[alertView textFieldAtIndex:0].text intValue];
        
        if (alertView == roundsFiredAlertView) {
            _selectedAmmunition.count = [NSNumber numberWithInt:[_selectedAmmunition.count intValue] - count];
            if ([_selectedAmmunition.count intValue] < 0) _selectedAmmunition.count = [NSNumber numberWithInt:0];
        } else if (alertView == roundsBoughtAlertView) {
            _selectedAmmunition.count = [NSNumber numberWithInt:[_selectedAmmunition.count intValue] + count];
        }
        [[DataManager sharedManager] saveAppDatabase];

        [self updateCount];
    }
    [[alertView textFieldAtIndex:0] setText:nil];    
}

#pragma mark UIActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {         // delete if pressed delete button
        [_selectedAmmunition deleteEntity];
        [[DataManager sharedManager] saveAppDatabase];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteTapped:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:kGLCancelText
                   destructiveButtonTitle:@"Delete"
                        otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
}

@end
