//
//  ProfileViewTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewTableViewController.h"
#import "TableViewHeaderViewGrouped2Line.h"

@implementation ProfileViewTableViewController
@synthesize elevationAdjustmentLabel = _elevationAdjustmentLabel;
@synthesize windageAdjustmentLabel = _windageAdjustmentLabel;
@synthesize mvLabel = _mvLabel, sightHeightLabel = _sightHeightLabel, zeroLabel = _zeroLabel, bulletDiameterLabel = _bulletDiameterLabel;
@synthesize bulletWeightLabel = _bulletWeightLabel, dragModelLabel = _dragModelLabel, bcLabel = _bcLabel, profile =_profile;
@synthesize sgLabel = _sgLabel;
@synthesize sgDirectionLabel = _sgDirectionLabel;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataManager = [DataManager sharedManager];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Images/Table/tableView_background"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadProfile];
    [self.tableView reloadData];
}

-(void)loadProfile {
    self.title = _profile.name;
    
    _mvLabel.text = [[_profile.muzzle_velocity stringValue] stringByAppendingString:@" fps"];
    _sightHeightLabel.text = [[_profile.sight_height_inches stringValue] stringByAppendingString:@"\""];
    _zeroLabel.text = [NSString  stringWithFormat:@"%d %@",
                       _profile.zero.intValue,
                       [dataManager.rangeUnits objectAtIndex:_profile.zero_unit.intValue]];
    
    _elevationAdjustmentLabel.text = [NSString stringWithFormat:@"%@ %@ per click", 
                                      _profile.elevation_click, _profile.scope_click_unit];
    _windageAdjustmentLabel.text = [NSString stringWithFormat:@"%@ %@ per click", 
                                      _profile.windage_click, _profile.scope_click_unit];
    
    _bulletDiameterLabel.text = [[_profile.bullet_diameter_inches stringValue] stringByAppendingString:@"\""];
    _bulletWeightLabel.text = [[_profile.bullet_weight stringValue] stringByAppendingString:@" grains"];
    _dragModelLabel.text = _profile.drag_model;
    _bcLabel.text = [[Bullet bcToString:_profile.bullet_bc] substringFromIndex:4];
    _sgLabel.text = [_profile.sg stringValue];
    _sgDirectionLabel.text = _profile.sg_twist_direction;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"EditProfile"]) {
        UINavigationController *destinationController = segue.destinationViewController;
		ProfileAddEditViewController *dst = [[destinationController viewControllers] objectAtIndex:0];
        dst.selectedProfile = _profile;
    }
}

- (IBAction)deleteTapped:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:kGLCancelText
                   destructiveButtonTitle:@"Delete Profile"
                        otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0) ? 60.0f : 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    if (section == 0) { // weapon
        TableViewHeaderViewGrouped2Line *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped2Line" 
                                                                                     owner:self 
                                                                                   options:nil] 
                                                  objectAtIndex:0];
        headerView.headerTitleLabel.text = _profile.weapon.manufacturer.name;
        headerView.headerTitleLabel2.text = [_profile.weapon.description substringFromIndex:_profile.weapon.manufacturer.displayName.length + 1];
        
        return headerView;
    } else {
        TableViewHeaderViewGrouped *headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeaderViewGrouped" 
                                                                                owner:self 
                                                                              options:nil] 
                                                  objectAtIndex:0];
        if (section == 1) {
            headerView.headerTitleLabel.text = (_profile.bullet) ? _profile.bullet.description : @"Bullet";            
        } else {
            headerView.headerTitleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        }
        return headerView;
    }
}


# pragma mark UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [_profile deleteEntity];
        [[DataManager sharedManager] saveAppDatabase];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
