//
//  CaliberChooserViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseHelper.h"

@class CaliberChooserViewController;

@protocol CaliberChooserViewControllerDelegate <NSObject>
- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)caliber;
@end

@interface CaliberChooserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>{
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <CaliberChooserViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *caliber;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) NSArray *searchResults;

@end
