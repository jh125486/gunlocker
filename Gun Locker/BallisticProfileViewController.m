//
//  BallisticProfileAddEditViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BallisticProfileViewController.h"

@implementation BallisticProfileViewController
@synthesize editRoot;
@synthesize selectedProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    if (!self.root) {
        
    }
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setEditRoot:nil];
    [self setSelectedProfile:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (QRootElement *)editProfile {
    editRoot = [[QRootElement alloc] init];
    editRoot.grouped = YES;
    editRoot.title = @"Edit Profile";
    
    QSection *infoSection = [[QSection alloc] init];
    
    
    return editRoot;
}


- (IBAction)editButtonTapped:(id)sender {
    QuickDialogController *editController = [[[self class] alloc] initWithRoot:[self editProfile]];
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
    BallisticProfile *profile =  (self.selectedProfile) ? self.selectedProfile : [BallisticProfile createEntity];
    [editRoot fetchValueIntoObject:profile];
    
    [[NSManagedObjectContext defaultContext] save];
    
    [self reloadTableWith:profile];
    [self dismissEditView:nil];
}

- (void)dismissEditView:(id)sender {
    [self dismissModalViewControllerAnimated:NO];    
}

- (void)reloadTableWith:(BallisticProfile *)profile {


    [self.quickDialogTableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(int)index {
    if (index == sender.destructiveButtonIndex) {
        [self.selectedProfile deleteEntity];
        [[NSManagedObjectContext defaultContext] save];
//        [self reloadTableWith:nil];
//        [self dismissEditView:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark QuickDialog Style
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
        self.quickDialogTableView.backgroundColor = [UIColor colorWithRed:0.757 green:0.710 blue:0.588 alpha:1.000];
    } else {
        self.quickDialogTableView.backgroundColor = [UIColor whiteColor];
    }
    self.quickDialogTableView.bounces = NO;
    self.quickDialogTableView.styleProvider = self;
}

@end
