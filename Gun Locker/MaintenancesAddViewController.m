//
//  MaintenancesAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenancesAddViewController.h"

@implementation MaintenancesAddViewController
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
    linkedMalfunctions = [[NSMutableSet alloc] init];
    QRootElement *_root = [[QRootElement alloc] init];
    
    _root.grouped = YES;
    _root.title = @"New Maintenance";
    // action_performed, date, round_count, linked_malfunction
    
    QSection *infoSection = [[QSection alloc] initWithTitle:@"Info"];
    QSection *descriptionSection = [[QSection alloc] initWithTitle:@"Description"];
    
    QDateTimeInlineElement *maintenanceDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Date" date:[NSDate date]];
    maintenanceDate.mode = UIDatePickerModeDate;
    maintenanceDate.key = @"date";
    
    QDecimalElement *roundCount = [[QDecimalElement alloc] initWithTitle:@"Round Count" value:[_selectedWeapon.round_count floatValue]];
    roundCount.fractionDigits = 0;
    roundCount.keyboardType = UIKeyboardTypeNumberPad;
    roundCount.key = @"round_count";
    
    QMultilineElement *actionPerformedText = [QMultilineElement new];
    actionPerformedText.title = @"Action performed";
    actionPerformedText.key = @"action_performed";
    
    [infoSection addElement:maintenanceDate];
    [infoSection addElement:roundCount];
    [_root addSection:infoSection];

    [descriptionSection addElement:actionPerformedText];
    [_root addSection:descriptionSection];
    
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    malfunctions = [_selectedWeapon.malfunctions sortedArrayUsingDescriptors:sortDescriptors];
    if ([malfunctions count] > 0) {
        QSection *malfunctionSection = [[QSection alloc] initWithTitle:@"Related malfunctions"];
        for(Malfunction *malfunction in malfunctions) {
            NSString *title = [NSString stringWithFormat:@"%@ %@", malfunction.failure, [[malfunction.date distanceOfTimeInWords] lowercaseString]];
            QBooleanElement *malfunctionElement = [[QBooleanElement alloc] initWithTitle:title BoolValue:NO];
            malfunctionElement.controllerAction = @"linkedMalfunctionChanged:";
            malfunctionElement.onImage  = [UIImage imageNamed:@"icon_link"];
            malfunctionElement.offImage = [UIImage imageNamed:@"icon_delink"];
            malfunctionElement.key = [NSString stringWithFormat:@"%d", [malfunctions indexOfObject:malfunction]];        
            malfunctionElement.controllerAccessoryAction = @"linkedMalfunctionChanged:";
            [malfunctionSection addElement:malfunctionElement];        
        }
        [_root addSection:malfunctionSection];
    }
    
    self.root = _root;
    [self loadView];
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setSelectedWeapon:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)linkedMalfunctionChanged:(QBooleanElement *)element {
    (element.boolValue) ? [linkedMalfunctions addObject:[malfunctions objectAtIndex:[element.key intValue]]] : 
    [linkedMalfunctions removeObject:[malfunctions objectAtIndex:[element.key intValue]]];
}

#pragma mark Actions
- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init ];
    [self.root fetchValueIntoObject:dict];

    Maintenance *newMaintenance = [Maintenance createEntity];

    // doesnt work because of the use of index keys for boolean elements
//    [self.root fetchValueIntoObject:newMaintenance];
    newMaintenance.weapon       = _selectedWeapon;
    newMaintenance.date         = [dict valueForKey:@"date"];
    newMaintenance.round_count  = [dict valueForKey:@"round_count"];
    newMaintenance.action_performed = [dict valueForKey:@"action_performed"];
    newMaintenance.malfunctions = linkedMalfunctions;
    
    [[NSManagedObjectContext defaultContext] save];
    
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark Quickdialog Style delegate

- (void) cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    if ([element isKindOfClass:[QBooleanElement class]]){
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }   
}

@end
