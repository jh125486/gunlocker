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
        _timeLineFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 31)];
        _timeLineFooterLabel.backgroundColor = [UIColor clearColor];
        _timeLineFooterLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        _timeLineFooterLabel.textAlignment = UITextAlignmentCenter;
        _timeLineFooterLabel.textColor = [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1];
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
        
        QDateTimeInlineElement *formSentDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Form Sent" date:stamp.form_sent];
        formSentDate.key = @"form_sent";
        
        QDateTimeInlineElement *checkCashedDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Check Cashed" date:stamp.check_cashed];
        checkCashedDate.key = @"check_cashed";
        
        QDateTimeInlineElement *wentPendingDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Went Pending" date:stamp.went_pending];
        wentPendingDate.key = @"went_pending";
        
        QDateTimeInlineElement *stampReceivedDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Stamp Received" date:stamp.stamp_received];
        stampReceivedDate.key = @"stamp_received";

        stampReceivedDate.onValueChanged = formSentDate.onValueChanged = ^{[self setTimeLineFooter];};
        formSentDate.maximumDate = checkCashedDate.maximumDate = wentPendingDate.maximumDate = stampReceivedDate.maximumDate = [NSDate date];
        formSentDate.mode = checkCashedDate.mode = wentPendingDate.mode = stampReceivedDate.mode = UIDatePickerModeDate;
        
        [infoSection addElement:nfaType];
        [infoSection addElement:transferType];
        
        
        TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" 
                                                                                owner:self 
                                                                              options:nil] 
                                                  objectAtIndex:0];
        headerView.headerTitleLabel.text = timeLineSection.title;
        timeLineSection.headerView = headerView;
        [timeLineSection addElement:formSentDate];
        [timeLineSection addElement:checkCashedDate];
        [timeLineSection addElement:wentPendingDate];
        [timeLineSection addElement:stampReceivedDate];
        timeLineSection.key = @"timeLineSection";
                
        QSection *buttonSection = [[QSection alloc] init];
        QButtonElement *button = [[QButtonElement alloc] initWithTitle:@"Clear NFA Information"];
        button.onSelected = ^{
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:@"Clear"
                                                            otherButtonTitles:nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
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
        [[NSManagedObjectContext defaultContext] save];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    if ([element isKindOfClass:[QButtonElement class]]){
        UIImage *background = [[UIImage imageNamed:@"delete_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
        cell.backgroundColor = [UIColor colorWithPatternImage:background];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.shadowColor = [UIColor blackColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, -1);
    } else if ([element isKindOfClass:[QRadioElement class]] || [element isKindOfClass:[QDateTimeInlineElement class]]) {
        cell.backgroundColor = [UIColor whiteColor];
    } else if ([element isKindOfClass:[QRadioItemElement class]]){
//        cell.textLabel.textColor = [UIColor whiteColor];
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
    StampInfo *stamp =  (_selectedWeapon.stamp) ? _selectedWeapon.stamp: [StampInfo createEntity];
    [self.root fetchValueIntoObject:stamp];
    
    _selectedWeapon.stamp = stamp;
    
    [[NSManagedObjectContext defaultContext] save];
    
    [TestFlight passCheckpoint:@"NFAInformation saved"];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
