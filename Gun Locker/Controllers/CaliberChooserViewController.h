//
//  CaliberChooserViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Caliber.h"

@class CaliberChooserViewController;

@protocol CaliberChooserViewControllerDelegate <NSObject>
- (void)caliberChooserViewController:(CaliberChooserViewController *)controller didSelectCaliber:(NSString *)selectedCaliber;
@end

@interface CaliberChooserViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
    NSArray *calibers;
    NSArray *sections;
    NSArray *searchResults;
}

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic, weak) id <CaliberChooserViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedCaliber;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;

@end
