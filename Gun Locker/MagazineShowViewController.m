//
//  MagazineShowViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazineShowViewController.h"

@implementation MagazineShowViewController
@synthesize brandLabel = _brandLabel;
@synthesize typeLabel = _typeLabel;
@synthesize colorLabel = _colorLabel;
@synthesize caliberLabel = _caliberLabel;
@synthesize countLabel = _countLabel;
@synthesize sellMagazinesButton = _sellMagazinesButton;
@synthesize selectedMagazine = _selectedMagazine;

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

    sellMagazinesAlertView = [[UIAlertView alloc] initWithTitle:@"Sell Magazines" 
                                                      message:nil 
                                                     delegate:self 
                                            cancelButtonTitle:@"Cancel" 
                                            otherButtonTitles:@"Sell!", nil];
    
    buyMagazinesAlertView = [[UIAlertView alloc] initWithTitle:@"Buy More Magazines" 
                                                       message:nil 
                                                      delegate:self 
                                             cancelButtonTitle:@"Cancel" 
                                             otherButtonTitles:@"Buy!", nil];
    
    sellMagazinesAlertView.alertViewStyle = buyMagazinesAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [sellMagazinesAlertView textFieldAtIndex:0].placeholder   = [buyMagazinesAlertView textFieldAtIndex:0].placeholder = @"Number of Magazines";
    [sellMagazinesAlertView textFieldAtIndex:0].keyboardType  = [buyMagazinesAlertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [sellMagazinesAlertView textFieldAtIndex:0].textAlignment = [buyMagazinesAlertView textFieldAtIndex:0].textAlignment = UITextAlignmentCenter;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadMagazine];
}

-(void)loadMagazine {
    _brandLabel.text   = _selectedMagazine.brand;
    _typeLabel.text    = _selectedMagazine.type;
    _caliberLabel.text = _selectedMagazine.caliber;
    _colorLabel.text   = _selectedMagazine.color;
    [self setCount];
}

-(void)setCount {
    _countLabel.text   = [_selectedMagazine.count stringValue];
    _sellMagazinesButton.enabled = ([_selectedMagazine.count intValue] != 0);
}

- (void)viewDidUnload {
    [self setBrandLabel:nil];
    [self setTypeLabel:nil];
	[self setColorLabel:nil];
    [self setCaliberLabel:nil];
    [self setCountLabel:nil];
    [self setSellMagazinesButton:nil];
    [self setSelectedMagazine:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"EditMagazine"]) {
        MagazineAddEditViewController *dst = [[segue.destinationViewController viewControllers] objectAtIndex:0];
        dst.selectedMagazine = _selectedMagazine;
    }
}

#pragma mark UIAlertView

- (IBAction)sellMagazinesTapped:(id)sender {
    [sellMagazinesAlertView show];
}

- (IBAction)buyMagazinesTapped:(id)sender {
    [buyMagazinesAlertView show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        int count = [[alertView textFieldAtIndex:0].text intValue];
        
        if (alertView == sellMagazinesAlertView) {
            _selectedMagazine.count = [NSNumber numberWithInt:[_selectedMagazine.count intValue] - count];
            if ([_selectedMagazine.count intValue] < 0) _selectedMagazine.count = [NSNumber numberWithInt:0];
        } else if (alertView == buyMagazinesAlertView) {
            _selectedMagazine.count = [NSNumber numberWithInt:[_selectedMagazine.count intValue] + count];
        }
        [[NSManagedObjectContext defaultContext] save];
        
        [self setCount];
    }
    [[alertView textFieldAtIndex:0] setText:nil];    
}

#pragma mark UIActionSheet

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {         // delete if pressed delete button
        [_selectedMagazine deleteEntity];
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
