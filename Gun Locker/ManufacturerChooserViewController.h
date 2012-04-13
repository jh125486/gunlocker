//
//  ManufacturerChooserViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Manufacturer.h"

@class ManufacturerChooserViewController;

@protocol ManufacturerChooserViewControllerDelegate <NSObject>
- (void)manufacturerChooserViewController:(ManufacturerChooserViewController *)controller didSelectManufacturer:(Manufacturer *)selectedManufacturer;
@end

@interface ManufacturerChooserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
    UILocalizedIndexedCollation *collation;
    NSArray *manufacturers;
	NSUInteger selectedIndex;
}

@property (nonatomic, weak) id <ManufacturerChooserViewControllerDelegate> delegate;
@property (nonatomic, strong) Manufacturer *selectedManufacturer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, retain) NSMutableArray *sectionsArray;

@property (nonatomic, retain) UILocalizedIndexedCollation *collation;
- (void)configureSections;

@end
