//
//  ProfileViewTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewTableViewController.h"

@implementation ProfileViewTableViewController
@synthesize mvLabel;
@synthesize sightHeightLabel;
@synthesize zeroLabel;
@synthesize bulletDiameterLabel;
@synthesize bulletWeightLabel;
@synthesize dragModelLabel;
@synthesize bcLabel;
@synthesize profile;

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
    self.title = self.profile.name;
    
    // TODO set up labels with units
    self.mvLabel.text = [self.profile.muzzle_velocity stringValue];
    self.sightHeightLabel.text = [self.profile.sight_height_inches stringValue];
    self.zeroLabel.text = [self.profile.zero stringValue];
    self.bulletDiameterLabel.text = [self.profile.bullet_diameter_inches stringValue];
    self.bulletWeightLabel.text = [self.profile.bullet_weight stringValue];
    self.dragModelLabel.text = self.profile.drag_model;
    self.bcLabel.text = [self.profile.bullet_bc description];

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

- (IBAction)editTapped:(id)sender {
    NSLog(@"edit tapped");
}

@end
