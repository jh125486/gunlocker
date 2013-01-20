//
//  NFAInformationViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NFAInformationViewController.h"

@implementation NFAInformationViewController
@synthesize line1Label = _line1Label, line2Label = _line2Label;
@synthesize selectedWeapon = _selectedWeapon;
@synthesize timeLineFooterLabel = _timeLineFooterLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.root) {
        DataManager *dataManager = [DataManager sharedManager];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 31)];
        footerView.backgroundColor = [UIColor clearColor];
        footerView.autoresizesSubviews = YES;
        _timeLineFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        _timeLineFooterLabel.backgroundColor = [UIColor clearColor];
        _timeLineFooterLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        _timeLineFooterLabel.textAlignment = UITextAlignmentCenter;
        _timeLineFooterLabel.textColor = [UIColor blackColor];
        _timeLineFooterLabel.shadowColor = [UIColor whiteColor];
        _timeLineFooterLabel.shadowOffset = CGSizeMake(0, 1);
        _timeLineFooterLabel.text = @"";
        _timeLineFooterLabel.adjustsFontSizeToFitWidth = YES;
        [footerView addSubview:_timeLineFooterLabel];
        
        [self setTitle];
        
        StampInfo *stamp = _selectedWeapon.stamp;
        
        QRootElement *_root = [[QRootElement alloc] init];
        
        _root.grouped = YES;
        
        QSection *infoSection = [[QSection alloc] init];
        QSection *timeLineSection = [[QSection alloc] initWithTitle:@"Process Timeline"];
        timeLineSection.footerView = footerView;
        
        QRadioElement *nfaType = [[QRadioElement alloc] initWithItems:dataManager.nfaTypes
                                                             selected:stamp.nfa_type ? [stamp.nfa_type intValue] : -1
                                                                title:@"NFA Type"];
        
        nfaType.key = @"nfa_type";
        
        QRadioElement *transferType = [[QRadioElement alloc] initWithItems:dataManager.transferTypes
                                                                  selected:stamp.transfer_type ? [stamp.transfer_type intValue] : -1
                                                                     title:@"Transfer Type"];
        transferType.key = @"transfer_type";

        QEntryElement *stampNumber = [[QEntryElement alloc] initWithTitle:@"Stamp Number" Value:stamp.number Placeholder:@"n/a"];
        stampNumber.key = @"number";

        [infoSection addElement:nfaType];
        [infoSection addElement:transferType];
        [infoSection addElement:stampNumber];

        QDateTimeInlineElement *formSentDateElement = [[QDateTimeInlineElement alloc] initWithTitle:@"Form Sent" date:stamp.form_sent];
        formSentDateElement.key = @"form_sent";
        
        QDateTimeInlineElement *checkCashedDateElement = [[QDateTimeInlineElement alloc] initWithTitle:@"Check Cashed" date:stamp.check_cashed];
        checkCashedDateElement.key = @"check_cashed";
        
        QDateTimeInlineElement *wentPendingDateElement = [[QDateTimeInlineElement alloc] initWithTitle:@"Went Pending" date:stamp.went_pending];
        wentPendingDateElement.key = @"went_pending";
        
        QDateTimeInlineElement *stampReceivedDateElement = [[QDateTimeInlineElement alloc] initWithTitle:@"Stamp Received" date:stamp.stamp_received];
        stampReceivedDateElement.key = @"stamp_received";

        stampReceivedDateElement.onValueChanged = formSentDateElement.onValueChanged = ^(QRootElement *element){[self setTimeLineFooter];};
        formSentDateElement.maximumDate = checkCashedDateElement.maximumDate = wentPendingDateElement.maximumDate = stampReceivedDateElement.maximumDate = [NSDate date];
        formSentDateElement.mode = checkCashedDateElement.mode = wentPendingDateElement.mode = stampReceivedDateElement.mode = UIDatePickerModeDate;
        
        formSentDateElement.placeholder = checkCashedDateElement.placeholder = wentPendingDateElement.placeholder = stampReceivedDateElement.placeholder = @"n/a";
        
        TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" 
                                                                                owner:self 
                                                                              options:nil] 
                                                  objectAtIndex:0];
        headerView.headerTitleLabel.text = timeLineSection.title;
        timeLineSection.headerView = headerView;
        
        [timeLineSection addElement:formSentDateElement];
        [timeLineSection addElement:checkCashedDateElement];
        [timeLineSection addElement:wentPendingDateElement];
        [timeLineSection addElement:stampReceivedDateElement];

        timeLineSection.key = @"timeLineSection";
                
        QSection *buttonSection = [[QSection alloc] init];
        QButtonElement *button = [[QButtonElement alloc] initWithTitle:@"Clear NFA Information"];
        button.onSelected = ^{
            [[[UIActionSheet alloc] initWithTitle:nil
                                         delegate:self
                                cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Clear"
                                otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
        };
        
        [buttonSection addElement:button];
        
        [_root addSection:infoSection];
        [_root addSection:timeLineSection];
        [_root addSection:buttonSection];

        self.root = _root;
                
        [self setTimeLineFooter];
    }    
    [self loadView];
}

- (void)setTitle {
    // replace titleView with a title and subtitle
    // dont show if coming from weapon controller
    if (![self.navigationController.navigationBar.topItem.title isEqualToString:_selectedWeapon.model]) {
        _line1Label.text = @"NFA Information";
        _line2Label.text = _selectedWeapon.model;
    } else {
        _line1Label.text = @"NFA";
        _line2Label.text = @"Information";
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [TestFlight passCheckpoint:@"NFAInformation disappeared"];
}

- (void)viewDidUnload {
    [self setSelectedWeapon:nil];
    [self setLine1Label:nil];
    [self setLine2Label:nil];
    [self setTimeLineFooterLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setTimeLineFooter {
    NSDate *formSent = ((QDateTimeInlineElement*)[self.root elementWithKey:@"form_sent"]).dateValue;
    NSDate *stampReceived = ((QDateTimeInlineElement*)[self.root elementWithKey:@"stamp_received"]).dateValue;
    _timeLineFooterLabel.text = (formSent && stampReceived) ? [NSString stringWithFormat:@"%.0f day wait", [stampReceived timeIntervalSinceDate:formSent] / (60*60*24.0)] : @"";
}

- (void)actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(int)index {
    if (index == sender.destructiveButtonIndex) {
        [_selectedWeapon.stamp deleteEntity];
        [[DataManager sharedManager] saveAppDatabase];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    if ([element isKindOfClass:[QButtonElement class]]){
        UIImage *background = [[UIImage imageNamed:@"delete_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        cell.backgroundColor = [UIColor colorWithPatternImage:background];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.shadowColor = [UIColor darkGrayColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, -1);
    } else if ([element isKindOfClass:[QRadioElement class]] || [element isKindOfClass:[QDateTimeInlineElement class]]) {
        cell.backgroundColor = [UIColor whiteColor];
    } else if ([element isKindOfClass:[QEntryElement class]]){
        QEntryTableViewCell *c = (QEntryTableViewCell *)cell;
        [c.textField setTextAlignment:UITextAlignmentRight];
        cell.backgroundColor = [UIColor whiteColor];
    } else if ([element isKindOfClass:[QRadioItemElement class]]){
        // do nothing
    } else {
        self.quickDialogTableView.separatorColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor lightTextColor];
    }
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    if (self.root.grouped) {
        self.quickDialogTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
    } else {
        self.quickDialogTableView.backgroundColor = [UIColor whiteColor];
    }
    self.quickDialogTableView.bounces = YES;
    self.quickDialogTableView.styleProvider = self;
}

- (IBAction)saveButtonTapped:(id)sender {
    StampInfo *stamp =  (_selectedWeapon.stamp) ? _selectedWeapon.stamp : [StampInfo createEntity];
    [self.root fetchValueIntoObject:stamp];
    
    _selectedWeapon.stamp = stamp;
        
    [[DataManager sharedManager] saveAppDatabase];
    
    [TestFlight passCheckpoint:@"NFAInformation saved"];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
