//
//  BulletChooserViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bullet.h"

@interface BulletChooserViewController : UITableViewController <UIActionSheetDelegate, UISearchDisplayDelegate, UISearchBarDelegate> {
    UILocalizedIndexedCollation *collation;
    NSArray *items;
    NSCountedSet *categories;
    NSArray *sections;
    NSUInteger selectedIndex;
}

@property (nonatomic, strong) Bullet *selectedBullet;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, weak) NSString *selectedCategory;

@property (nonatomic, retain) UILocalizedIndexedCollation *collation;

- (void)configureSections;
- (IBAction)cancelTapped:(id)sender;

@end
