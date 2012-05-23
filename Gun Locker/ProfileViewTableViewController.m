//
//  ProfileViewTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewTableViewController.h"

@implementation ProfileViewTableViewController
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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
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
    _bulletDiameterLabel.text = [[_profile.bullet_diameter_inches stringValue] stringByAppendingString:@"\""];
    _bulletWeightLabel.text = [[_profile.bullet_weight stringValue] stringByAppendingString:@" grains"];
    _dragModelLabel.text = _profile.drag_model;
    _bcLabel.text = [[Bullet bcToString:_profile.bullet_bc] substringFromIndex:4];
    _sgLabel.text = [_profile.sg stringValue];
    _sgDirectionLabel.text = _profile.sg_twist_direction;
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
    [self setSgLabel:nil];
    [self setSgDirectionLabel:nil];
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
        dst.selectedProfile = _profile;
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
    return (section == 0) ? 60.0f : 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section  {
    if (section == 0) { // weapon
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        UILabel *manufacturer = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 22)];
        manufacturer.adjustsFontSizeToFitWidth = YES;
        manufacturer.text = _profile.weapon.manufacturer.name;
        manufacturer.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
        manufacturer.minimumFontSize = 14.0f;
        manufacturer.shadowColor = [UIColor clearColor];
        manufacturer.backgroundColor = [UIColor clearColor];
        manufacturer.textColor = [UIColor blackColor];
        
        UILabel *model = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, headerView.frame.size.width - 20, 22)];
        model.adjustsFontSizeToFitWidth = YES;
        model.text = [_profile.weapon.description substringFromIndex:_profile.weapon.manufacturer.displayName.length + 1];
        model.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
        model.minimumFontSize = 14.0f;
        model.shadowColor = [UIColor clearColor];
        model.backgroundColor = [UIColor clearColor];
        model.textColor = [UIColor blackColor];

        [headerView addSubview:manufacturer];
        [headerView addSubview:model];
        return headerView;
        
    } else if (section == 1) { // bullet
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        UILabel *bullet = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, headerView.frame.size.width - 20, 24)];
        bullet.adjustsFontSizeToFitWidth = YES;
        bullet.text =  (_profile.bullet) ? _profile.bullet.description : @"Bullet";
        bullet.font = [UIFont fontWithName:@"AmericanTypewriter" size:22.0];
        bullet.minimumFontSize = 14.0f;
        bullet.shadowColor = [UIColor clearColor];
        bullet.backgroundColor = [UIColor clearColor];
        bullet.textColor = [UIColor blackColor];
        
        [headerView addSubview:bullet];
        return headerView;
    } else {
        return nil;
    }
}


# pragma mark UIActionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [_profile deleteEntity];
        [[NSManagedObjectContext defaultContext] save];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
