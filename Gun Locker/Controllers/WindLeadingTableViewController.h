//
//  WindLeadingTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WindLeadingTableViewController;

@protocol WindLeadingTableViewControllerDelegate <NSObject>
- (void)windLeadingTableViewController:(WindLeadingTableViewController *)controller didSelectWindLeading:(NSString *)selectedWindLeading;
@end


@interface WindLeadingTableViewController : UITableViewController
@property (nonatomic, weak) id <WindLeadingTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedWindLeading;
@end
