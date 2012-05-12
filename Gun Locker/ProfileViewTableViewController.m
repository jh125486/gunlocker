//
//  ProfileViewTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewTableViewController.h"

@implementation ProfileViewTableViewController
@synthesize mvLabel, sightHeightLabel, zeroLabel, bulletDiameterLabel;
@synthesize bulletWeightLabel, dragModelLabel, bcLabel, profile;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadProfile];
    [self.tableView reloadData];
}

-(void)loadProfile {
    self.title = self.profile.name;
    
    // TODO set up labels with units
    self.mvLabel.text = [self.profile.muzzle_velocity stringValue];
    self.sightHeightLabel.text = [self.profile.sight_height_inches stringValue];
    self.zeroLabel.text = [self.profile.zero stringValue];
    self.bulletDiameterLabel.text = [self.profile.bullet_diameter_inches stringValue];
    self.bulletWeightLabel.text = [self.profile.bullet_weight stringValue];
    self.dragModelLabel.text = self.profile.drag_model;
    self.bcLabel.text = [[Bullet bcToString:self.profile.bullet_bc] substringFromIndex:4];
}

- (void)viewDidUnload {
    [self setMvLabel:nil];
    [self setSightHeightLabel:nil];
    [self setZeroLabel:nil];
    [self setBulletDiameterLabel:nil];
    [self setBulletWeightLabel:nil];
    [self setDragModelLabel:nil];
    [self setBcLabel:nil];
    [self setProfile:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"EditProfile"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		ProfileAddEditViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        dst.selectedProfile = self.profile;
    }
}

- (IBAction)deleteTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Profile"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.profile.weapon.description;
    } else if (section == 1) {
        if (self.profile.bullet) {
            return self.profile.bullet.description;
        } else {
            return @"Bullet";
        }
    } else {
        return @"";
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 24)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
    label.minimumFontSize = 14.0f;
    label.adjustsFontSizeToFitWidth = YES;
    label.shadowColor = [UIColor clearColor];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    
	[headerView addSubview:label];
	return headerView;
}


# pragma mark UIActionSheet
- (void)actionSheet:(UIActionSheet *)sender clickedButtonAtIndex:(int)index {
    if (index == sender.destructiveButtonIndex) {
        [self.profile deleteEntity];
        [[NSManagedObjectContext defaultContext] save];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
