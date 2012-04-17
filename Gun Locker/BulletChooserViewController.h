//
//  BulletChooserViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bullet.h"

@interface BulletChooserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
    UITextField *weightField;
    UITextField *ballisticCoefficientField;
    UILocalizedIndexedCollation *collation;
    NSArray *bullets;
    NSUInteger selectedIndex;
}

@property (nonatomic, strong) Bullet *selectedBullet;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, retain) NSMutableArray *sectionsArray;

@property (nonatomic, retain) UILocalizedIndexedCollation *collation;

- (void)configureSections;
- (IBAction)manuallyEnterBulletTapped:(id)sender;

@end
