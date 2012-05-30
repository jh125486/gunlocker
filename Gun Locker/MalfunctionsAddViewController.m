//
//  MalfunctionsAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MalfunctionsAddViewController.h"

@implementation MalfunctionsAddViewController
@synthesize selectedWeapon = _selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    
    self.quickDialogTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    self.quickDialogTableView.bounces = NO;
    self.quickDialogTableView.styleProvider = self;
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

    QDecimalElement *roundCount = [[QDecimalElement alloc] initWithTitle:@"Round Count" value:[_selectedWeapon.round_count intValue]];
    roundCount.fractionDigits = 0;
    roundCount.keyboardType = UIKeyboardTypeNumberPad;
    roundCount.key = @"round_count";
    
    QMultilineElement *failureText = [QMultilineElement new];
    failureText.title = @"Failure";
    failureText.key = @"failure";

    QMultilineElement *fixText = [QMultilineElement new];
    fixText.title = @"Fix action";
    fixText.key = @"fix";
    
    TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" 
                                                                            owner:self 
                                                                          options:nil] 
                                              objectAtIndex:0];
    headerView.headerTitleLabel.text = infoSection.title;
    infoSection.headerView = headerView;
    [infoSection addElement:malfunctionDate];
    [infoSection addElement:roundCount];
    
    TableViewHeaderViewGrouped *headerView2 = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" 
                                                                            owner:self 
                                                                          options:nil] 
                                              objectAtIndex:0];
    headerView2.headerTitleLabel.text = descriptionSection.title;
    descriptionSection.headerView = headerView2;
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
    newMalfunction.weapon = _selectedWeapon;
    [[NSManagedObjectContext defaultContext] save];

    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark Quickdialog Style delegate

-(void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
    // quickdialog styling
}
@end
