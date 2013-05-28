//
//  PhotosTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Photo.h"
#import "../Models/Weapon.h"
#import "../Views/PhotoTableCell.h"
#import "PhotoViewController.h"

@interface PhotosTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSIndexPath *lastIndexPath;
}

@property (weak, nonatomic) IBOutlet UIImageView *noPhotosImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) Weapon *selectedWeapon;
@property (nonatomic, strong) UIActionSheet *addPhotoSheet;

- (IBAction)addPhotoTapped:(id)sender;
- (IBAction)setPrimaryButtonTapped:(id)sender;
- (IBAction)deleteTapped:(id)sender;

@end
