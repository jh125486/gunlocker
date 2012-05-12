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
    self.mvLabel.text = [[self.profile.muzzle_velocity stringValue] stringByAppendingString:@" fps"];
    self.sightHeightLabel.text = [[self.profile.sight_height_inches stringValue] stringByAppendingString:@"\""];
    self.zeroLabel.text = [[self.profile.zero stringValue] stringByAppendingString:@" yards"];
    self.bulletDiameterLabel.text = [[self.profile.bullet_diameter_inches stringValue] stringByAppendingString:@"\""];
    self.bulletWeightLabel.text = [[self.profile.bullet_weight stringValue] stringByAppendingString:@" grains"];
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 60.0f;
    } else {
        return 30.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    if (section == 0) { // weapon
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        UILabel *manufacturer = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 22)];
        manufacturer.adjustsFontSizeToFitWidth = YES;
        manufacturer.text = self.profile.weapon.manufacturer.name;
        manufacturer.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
        manufacturer.minimumFontSize = 14.0f;
        manufacturer.shadowColor = [UIColor clearColor];
        manufacturer.backgroundColor = [UIColor clearColor];
        manufacturer.textColor = [UIColor blackColor];
        
        UILabel *model = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, headerView.frame.size.width - 20, 22)];
        model.adjustsFontSizeToFitWidth = YES;
        model.text = [self.profile.weapon.description substringFromIndex:manufacturer.text.length + 1];
        model.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
        model.minimumFontSize = 14.0f;
        model.shadowColor = [UIColor clearColor];
        model.backgroundColor = [UIColor clearColor];
        model.textColor = [UIColor blackColor];

        [headerView addSubview:manufacturer];
        [headerView addSubview:model];
        return headerView;
        
    } else { // bullet
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        UILabel *bullet = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 24)];
        bullet.adjustsFontSizeToFitWidth = YES;
        bullet.text =  (self.profile.bullet) ? self.profile.bullet.description : @"Bullet";
        bullet.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
        bullet.minimumFontSize = 14.0f;
        bullet.shadowColor = [UIColor clearColor];
        bullet.backgroundColor = [UIColor clearColor];
        bullet.textColor = [UIColor blackColor];
        
        [headerView addSubview:bullet];
        return headerView;
    }
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
