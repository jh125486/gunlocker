//
//  MalfunctionsAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MalfunctionsAddViewController.h"

@implementation MalfunctionsAddViewController
@synthesize selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    QRootElement *_root = [[QRootElement alloc] init];

    _root.grouped = YES;
    _root.title = @"New Malfunction";
    
    QSection *infoSection = [[QSection alloc] initWithTitle:@"Info"];
    QSection *descriptionSection = [[QSection alloc] initWithTitle:@"Description"];

    QDateTimeInlineElement *malfunctionDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Date" date:[NSDate date]];
    malfunctionDate.mode = UIDatePickerModeDate;
    malfunctionDate.key = @"date";

    QDecimalElement *roundCount = [[QDecimalElement alloc] initWithTitle:@"Round count" value:[self.selectedWeapon.round_count floatValue]];
    roundCount.fractionDigits = 0;
    roundCount.keyboardType = UIKeyboardTypeNumberPad;
    roundCount.key = @"round_count";
    
    QMultilineElement *failureText = [QMultilineElement new];
    failureText.title = @"Failure";
    failureText.key = @"failure";

    QMultilineElement *fixText = [QMultilineElement new];
    fixText.title = @"Fix action";
    fixText.key = @"fix";
    
    [infoSection addElement:malfunctionDate];
    [infoSection addElement:roundCount];
    
    [descriptionSection addElement:failureText];
    [descriptionSection addElement:fixText];
    
    [_root addSection:infoSection];
    [_root addSection:descriptionSection];

    self.root = _root;
    [self loadView];
    self.quickDialogTableView.bounces = NO;

    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setSelectedWeapon:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {
    Malfunction *newMalfunction = [Malfunction createEntity];

    [self.root fetchValueIntoObject:newMalfunction];
    newMalfunction.weapon = self.selectedWeapon;
    [[NSManagedObjectContext defaultContext] save];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newMalfunction" object:newMalfunction];

    [self dismissModalViewControllerAnimated:YES];
}

@end
