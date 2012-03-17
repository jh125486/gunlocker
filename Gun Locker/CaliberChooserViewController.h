//
//  CaliberChooserViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CaliberChooserViewController;

@protocol CaliberChooserViewControllerDelegate <NSObject>
- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)selectedCaliber;
@end

@interface CaliberChooserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, weak) id <CaliberChooserViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedCaliber;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, copy) NSArray *searchResults;

@end
