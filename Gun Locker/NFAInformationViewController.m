//
//  NFAInformationViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NFAInformationViewController.h"

@implementation NFAInformationViewController
@synthesize editRoot;
@synthesize selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    if (!self.root) {
        // replace titleView with a title and subtitle
        // dont show if coming from weapon controller
        if (![self.navigationController.navigationBar.topItem.title isEqualToString:selectedWeapon.model]) {
            float titleViewWidth = 226 - ([self.navigationController.navigationBar.topItem.title sizeWithFont:[UIFont boldSystemFontOfSize:12]].width);
            CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, titleViewWidth, 44);    
            UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
            _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
            _headerTitleSubtitleView.autoresizesSubviews = YES;
            
            CGRect titleFrame = CGRectMake(0, 2, titleViewWidth, 22);  
            UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
            titleView.backgroundColor = [UIColor clearColor];
            titleView.font = [UIFont boldSystemFontOfSize:20];
            titleView.textAlignment = UITextAlignmentRight;
            titleView.textColor = [UIColor whiteColor];
            titleView.shadowColor = [UIColor darkGrayColor];
            titleView.shadowOffset = CGSizeMake(0, -1);
            titleView.text = self.title;
            titleView.adjustsFontSizeToFitWidth = YES;
            [_headerTitleSubtitleView addSubview:titleView];
            
            CGRect subtitleFrame = CGRectMake(0, 22, titleViewWidth, 44-24);   
            UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
            subtitleView.backgroundColor = [UIColor clearColor];
            subtitleView.font = [UIFont boldSystemFontOfSize:16];
            subtitleView.textAlignment = UITextAlignmentRight;
            subtitleView.textColor = [UIColor whiteColor];
            subtitleView.shadowColor = [UIColor darkGrayColor];
            subtitleView.shadowOffset = CGSizeMake(0, -1);
            subtitleView.text = selectedWeapon.model;
            subtitleView.adjustsFontSizeToFitWidth = YES;
            [_headerTitleSubtitleView addSubview:subtitleView];
            
            self.navigationItem.titleView = _headerTitleSubtitleView;
        }
        
        StampInfo *stamp = self.selectedWeapon.stamp;

        nfa_types  = [[NSArray alloc] initWithObjects:@"SBR", @"SBS", @"Suppressor", @"Machinegun", @"DD", @"AOW",nil];
        transfer_types = [[NSArray alloc] initWithObjects:@"Form 1", @"Form 4", nil];
        
        QRootElement *_root = [[QRootElement alloc] init];
        
        _root.grouped = YES;
        _root.title = @"NFA Details";
        
        QSection *infoSection = [[QSection alloc] init];
        QSection *timelineSection = [[QSection alloc] initWithTitle:@"Process Timeline"];
        
        QLabelElement *nfaType = [[QLabelElement alloc] initWithTitle:@"NFA type" 
                                                                Value:stamp.nfa_type ? [nfa_types objectAtIndex:[stamp.nfa_type intValue]] : nil];
        nfaType.key = @"nfa_type";
        
        QLabelElement *transferType = [[QLabelElement alloc] initWithTitle:@"Transfer type" 
                                                                     Value:stamp.transfer_type ? [transfer_types objectAtIndex:[stamp.transfer_type intValue]] : nil];
        transferType.key = @"transfer_type";

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];

        QLabelElement *formSent = [[QLabelElement alloc] initWithTitle:@"Form sent" 
                                                                     Value:[dateFormat stringFromDate:stamp.form_sent]];
        formSent.key = @"form_sent";
        
        QLabelElement *checkCashed = [[QLabelElement alloc] initWithTitle:@"Check cashed" 
                                                                        Value:[dateFormat stringFromDate:stamp.check_cashed]];
        checkCashed.key = @"check_cashed";
        
        QLabelElement *wentPending = [[QLabelElement alloc] initWithTitle:@"Went pending" 
                                                                        Value:[dateFormat stringFromDate:stamp.went_pending]];
        wentPending.key = @"went_pending";
        
        QLabelElement *stampReceived = [[QLabelElement alloc] initWithTitle:@"Stamp received" 
                                                                          Value:[dateFormat stringFromDate:stamp.stamp_received]];
        stampReceived.key = @"stamp_received";
        
        [infoSection addElement:nfaType];
        [infoSection addElement:transferType];
        
        [timelineSection addElement:formSent];
        [timelineSection addElement:checkCashed];
        [timelineSection addElement:wentPending];
        [timelineSection addElement:stampReceived];
        
        if (stamp.form_sent && stamp.stamp_received)
            timelineSection.footer = [NSString stringWithFormat:@"%.0f day wait", [stamp.stamp_received timeIntervalSinceDate:stamp.form_sent] / (60*60*24.0)];
            
        [_root addSection:infoSection];
        [_root addSection:timelineSection];
            
        self.root = _root;

        [self loadView];
    }
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setEditRoot:nil];
    [self setSelectedWeapon:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (QRootElement *)editNFA {
    StampInfo *stamp = self.selectedWeapon.stamp;
    editRoot = [[QRootElement alloc] init];
    
    editRoot.grouped = YES;
    editRoot.title = @"NFA Details";
    
    QSection *infoSection = [[QSection alloc] init];
    QSection *timelineSection = [[QSection alloc] initWithTitle:@"Process Timeline"];
    
    QRadioElement *nfaType = [[QRadioElement alloc] initWithItems:nfa_types 
                                                         selected:stamp.nfa_type ? [stamp.nfa_type intValue] : -1
                                                            title:@"NFA type"];
    
	nfaType.key = @"nfa_type";

    QRadioElement *transferType = [[QRadioElement alloc] initWithItems:transfer_types
                                                              selected:stamp.transfer_type ? [stamp.transfer_type intValue] : -1
                                                                 title:@"Transfer type"];
	transferType.key = @"transfer_type";
    
    QDateTimeInlineElement *formSentDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Form sent" 
                                                                                    date:stamp.form_sent];
    formSentDate.mode = UIDatePickerModeDate;
    formSentDate.key = @"form_sent";
    
    QDateTimeInlineElement *checkCashedDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Check cashed" 
                                                                                       date:stamp.check_cashed];
    checkCashedDate.mode = UIDatePickerModeDate;
    checkCashedDate.key = @"check_cashed";
    
    QDateTimeInlineElement *wentPendingDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Went pending" 
                                                                                       date:stamp.went_pending];
    wentPendingDate.mode = UIDatePickerModeDate;
    wentPendingDate.key = @"went_pending";
    
    QDateTimeInlineElement *stampReceivedDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Stamp received" 
                                                                                         date:stamp.stamp_received];
    stampReceivedDate.mode = UIDatePickerModeDate;
    stampReceivedDate.key = @"stamp_received";
    
    [infoSection addElement:nfaType];
    [infoSection addElement:transferType];
    
    [timelineSection addElement:formSentDate];
    [timelineSection addElement:checkCashedDate];
    [timelineSection addElement:wentPendingDate];
    [timelineSection addElement:stampReceivedDate];
    
    [editRoot addSection:infoSection];
    [editRoot addSection:timelineSection];

    QSection *buttonSection = [[QSection alloc] init];
    QButtonElement *button = [[QButtonElement alloc] initWithTitle:@"Delete NFA Details"];
	button.onSelected = ^{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Delete"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
	};
    
    [buttonSection addElement:button];
    [editRoot addSection:buttonSection];
    
    return editRoot;
}
- (IBAction)editButtonTapped:(id)sender {
    QuickDialogController *editController = [[NFAInformationViewController alloc] initWithRoot:[self editNFA]];
    [editController loadView];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editController];
    
    UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self 
                                                                action:@selector(doneTapped:)];  
    UIBarButtonItem *cancelButton=[[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
                                                                   style:UIBarButtonSystemItemCancel
                                                                  target:self 
                                                                  action:@selector(dismissEditView:)];  
    
    editController.navigationItem.leftBarButtonItem = cancelButton;
    editController.navigationItem.rightBarButtonItem = doneButton;   
    editController.navigationItem.title=@"Editing";

    [self presentModalViewController:navigationController animated:NO];
}


- (void)doneTapped:(id)sender {
    StampInfo *stamp =  (self.selectedWeapon.stamp) ? self.selectedWeapon.stamp: [StampInfo createEntity];
    [editRoot fetchValueIntoObject:stamp];
    
    self.selectedWeapon.stamp = stamp;
    
    [[NSManagedObjectContext defaultContext] save];
    
    [self reloadTableWith:stamp];
    [self dismissEditView:nil];
}

- (void)dismissEditView:(id)sender {
    [self dismissModalViewControllerAnimated:NO];    
}

- (void)reloadTableWith:(StampInfo *)stamp {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];

    ((QLabelElement *)[self.root elementWithKey:@"nfa_type"]).value = stamp.nfa_type ? [nfa_types objectAtIndex:[stamp.nfa_type intValue]] : nil;
    ((QLabelElement *)[self.root elementWithKey:@"transfer_type"]).value = stamp.transfer_type ? [transfer_types objectAtIndex:[stamp.transfer_type intValue]] : nil;
    ((QLabelElement *)[self.root elementWithKey:@"form_sent"]).value        = [dateFormat stringFromDate:stamp.form_sent];
    ((QLabelElement *)[self.root elementWithKey:@"check_cashed"]).value     = [dateFormat stringFromDate:stamp.check_cashed];
    ((QLabelElement *)[self.root elementWithKey:@"went_pending"]).value     = [dateFormat stringFromDate:stamp.went_pending];
    ((QLabelElement *)[self.root elementWithKey:@"stamp_received"]).value   = [dateFormat stringFromDate:stamp.stamp_received];

    QSection *timeLineSecton = [[self.root sections] objectAtIndex:1];
    if (stamp.form_sent && stamp.stamp_received) {
        timeLineSecton.footer = [NSString stringWithFormat:@"%.0f day wait", [stamp.stamp_received timeIntervalSinceDate:stamp.form_sent] / (60*60*24.0)];
    } else {
        timeLineSecton.footer = @"";
    }
        
    [self.quickDialogTableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(int)index {
    if (index == sender.destructiveButtonIndex) {
        [self.selectedWeapon.stamp deleteEntity];
        [[NSManagedObjectContext defaultContext] save];
        [self reloadTableWith:self.selectedWeapon.stamp];
        [self dismissEditView:nil];
    }
}

-(void) cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath{
    if ([element isKindOfClass:[QButtonElement class]]){
        UIImage *background = [[UIImage imageNamed:@"delete_button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
        cell.backgroundColor = [UIColor colorWithPatternImage:background];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.shadowColor = [UIColor lightGrayColor];
        cell.textLabel.shadowOffset = CGSizeMake(0, -1);
    } else if ([element isKindOfClass:[QRadioElement class]] || [element isKindOfClass:[QDateTimeInlineElement class]]) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
//        self.quickDialogTableView.separatorColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor lightTextColor];
    }
}

- (void)setQuickDialogTableView:(QuickDialogTableView *)aQuickDialogTableView {
    [super setQuickDialogTableView:aQuickDialogTableView];
    
//    self.quickDialogTableView.backgroundColor = [UIColor lightTextColor];
    self.quickDialogTableView.bounces = NO;
    self.quickDialogTableView.styleProvider = self;
}

@end
