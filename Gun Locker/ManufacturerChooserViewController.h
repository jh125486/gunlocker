//
//  ManufacturerChooserViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"

@class ManufacturerChooserViewController;

@protocol ManufacturerChooserViewControllerDelegate <NSObject>
- (void)manufacturerChooserViewController:(ManufacturerChooserViewController *)controller didSelectManufacturer:(NSString *)selectedManufacturer;
@end

@interface ManufacturerChooserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>{
    UILocalizedIndexedCollation *collation;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <ManufacturerChooserViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedManufacturer;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) NSArray *searchResults;
@property (nonatomic, retain) NSMutableArray *sectionsArray;

@property (nonatomic, retain) UILocalizedIndexedCollation *collation;
- (void)configureSections;

@end
