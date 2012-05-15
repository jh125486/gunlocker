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
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    
    roundsFiredAlertView = [[UIAlertView alloc] initWithTitle:@"Rounds Fired" 
                                                      message:nil 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                            otherButtonTitles:@"Fire!", nil];
    
    roundsBoughtAlertView = [[UIAlertView alloc] initWithTitle:@"Rounds Bought" 
                                                       message:nil 
                                                      delegate:self 
                                             cancelButtonTitle:@"Cancel" 
                                             otherButtonTitles:@"Buy!", nil];
    
    roundsFiredAlertView.alertViewStyle = roundsBoughtAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [roundsFiredAlertView textFieldAtIndex:0].placeholder   = [roundsBoughtAlertView textFieldAtIndex:0].placeholder = @"Number of Rounds";
    [roundsFiredAlertView textFieldAtIndex:0].keyboardType  = [roundsBoughtAlertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [roundsFiredAlertView textFieldAtIndex:0].textAlignment = [roundsBoughtAlertView textFieldAtIndex:0].textAlignment = UITextAlignmentCenter;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAmmo];
}

-(void)loadAmmo {
    _brandLabel.text   = _selectedAmmunition.brand;
    _typeLabel.text    = _selectedAmmunition.type;
    _caliberLabel.text = _selectedAmmunition.caliber;
    [self setCount];    
}

-(void)setCount {
    _countLabel.text = [_selectedAmmunition.count stringValue];
    _roundsFiredButton.enabled = ([_selectedAmmunition.count intValue] != 0);
}

- (void)viewDidUnload {
    [self setRoundsFiredButton:nil];
    [self setBrandLabel:nil];
    [self setTypeLabel:nil];
    [self setCaliberLabel:nil];
    [self setCountLabel:nil];
    [self setSelectedAmmunition:nil];
    [super viewDidUnload];
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
        [[NSManagedObjectContext defaultContext] save];

        [self setCount];
    }
    [[alertView textFieldAtIndex:0] setText:nil];    
}

#pragma mark UIActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {         // delete if pressed delete button
        [_selectedAmmunition deleteEntity];
        [[NSManagedObjectContext defaultContext] save];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteTapped:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:@"Delete"
                        otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
}

@end
