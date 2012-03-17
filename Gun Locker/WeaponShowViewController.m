//
//  WeaponShowViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeaponShowViewController.h"

@interface WeaponShowViewController ()

@end

@implementation WeaponShowViewController
@synthesize maintenanceButton;
@synthesize malfunctionsButton;
@synthesize dopeCardsButton;
@synthesize quickCleanButton;
@synthesize thumbnailImageView;
@synthesize selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set title for navigation back button
    self.title = selectedWeapon.model;
    
    // replace titleView with a title and subtitle
    float titleViewWidth = 320 - ([selectedWeapon.type sizeWithFont:[UIFont boldSystemFontOfSize:12]].width + 26 + 20);
    CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, titleViewWidth, 44);    
    UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    _headerTitleSubtitleView.autoresizesSubviews = YES;
    
    CGRect titleFrame = CGRectMake(0, 0, titleViewWidth, 24);  
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
    
    CGRect subtitleFrame = CGRectMake(0, 24, titleViewWidth, 44-24);   
    UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.font = [UIFont boldSystemFontOfSize:16];
    subtitleView.textAlignment = UITextAlignmentRight;
    subtitleView.textColor = [UIColor whiteColor];
    subtitleView.shadowColor = [UIColor darkGrayColor];
    subtitleView.shadowOffset = CGSizeMake(0, -1);
    subtitleView.text = selectedWeapon.manufacturer;
    subtitleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:subtitleView];
    
    self.navigationItem.titleView = _headerTitleSubtitleView;

    [self.maintenanceButton  setTitle:[NSString stringWithFormat:@"Maintenance (%d)", [self.selectedWeapon.maintenances count]] forState: UIControlStateNormal];
    [self.malfunctionsButton setTitle:[NSString stringWithFormat:@"Malfunctions (%d)", [self.selectedWeapon.maintenances count]] forState: UIControlStateNormal];
    [self.dopeCardsButton    setTitle:[NSString stringWithFormat:@"Dope Cards (%d)", [self.selectedWeapon.maintenances count]] forState: UIControlStateNormal];
    
}

- (void)viewDidUnload
{
    [self setMaintenanceButton:nil];
    [self setMalfunctionsButton:nil];
    [self setQuickCleanButton:nil];
    [self setThumbnailImageView:nil];
    [self setDopeCardsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
