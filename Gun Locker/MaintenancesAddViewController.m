//
//  MaintenancesAddViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenancesAddViewController.h"

@implementation MaintenancesAddViewController
@synthesize selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    
    self.quickDialogTableView.backgroundColor = [UIColor colorWithRed:0.757 green:0.710 blue:0.588 alpha:1.000];
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
    
    QDecimalElement *roundCount = [[QDecimalElement alloc] initWithTitle:@"Round count" value:[self.selectedWeapon.round_count floatValue]];
    roundCount.fractionDigits = 0;
    roundCount.keyboardType = UIKeyboardTypeNumberPad;
    roundCount.key = @"round_count";
    
    QMultilineElement *actionPerformedText = [QMultilineElement new];
    actionPerformedText.title = @"Action performed";
    actionPerformedText.key = @"action_performed";

    
    [infoSection addElement:maintenanceDate];
    [infoSection addElement:roundCount];
    
    [descriptionSection addElement:actionPerformedText];
    
    QSection *malfunctionSection = [[QSection alloc] initWithTitle:@"Related malfunctions"];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    malfunctions = [self.selectedWeapon.malfunctions sortedArrayUsingDescriptors:sortDescriptors];
    for(Malfunction *malfunction in malfunctions) {
        NSString *title = [NSString stringWithFormat:@"%@ %@", malfunction.failure, [[malfunction.date distanceOfTimeInWords] lowercaseString]];
        QBooleanElement *malfunctionElement = [[QBooleanElement alloc] initWithTitle:title BoolValue:NO];
        malfunctionElement.controllerAction = @"linkedMalfunctionChanged:";
        malfunctionElement.onImage  = [UIImage imageNamed:@"icon_link"];
        malfunctionElement.offImage = [UIImage imageNamed:@"icon_delink"];
        malfunctionElement.key = [NSString stringWithFormat:@"%d", [malfunctions indexOfObject:malfunction]];
//        malfunctionElement.onSelected
        [malfunctionSection addElement:malfunctionElement];
        NSLog(@"%@", malfunctionElement.controllerAction);
    }
    
    [_root addSection:infoSection];
    [_root addSection:descriptionSection];
    [_root addSection:malfunctionSection];
    
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

- (IBAction)cancelTapped:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveTapped:(id)sender {    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init ];
    [self.root fetchValueIntoObject:dict];

    Maintenance *newMaintenance = [Maintenance createEntity];
    // doesnt work because of the use of index keys for boolean elements
//    [self.root fetchValueIntoObject:newMaintenance];
    newMaintenance.weapon       = self.selectedWeapon;
    newMaintenance.date         = [dict valueForKey:@"date"];
    newMaintenance.round_count  = [dict valueForKey:@"round_count"];
    newMaintenance.action_performed = [dict valueForKey:@"action_performed"];
    newMaintenance.malfunctions = linkedMalfunctions;
    NSLog(@"linked %@", linkedMalfunctions);
    [[NSManagedObjectContext defaultContext] save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newMaintenance" object:newMaintenance];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void) cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    if ([element isKindOfClass:[QBooleanElement class]]){
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }   
}

- (void)linkedMalfunctionChanged:(QElement *)element {
    NSLog(@"%d hit", __LINE__);
//    (element.boolValue) ? [linkedMalfunctions addObject:[malfunctions objectAtIndex:[element.key intValue]]] : 
//                          [linkedMalfunctions removeObject:[malfunctions objectAtIndex:[element.key intValue]]];
}

@end
