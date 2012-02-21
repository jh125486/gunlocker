//
//  LockerViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeaponAddViewController.h"
#import "DatabaseHelper.h"
#import "Weapon.h"

@interface LockerViewController : UITableViewController <WeaponAddViewControllerDelegate, NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    BOOL _firstInsert;
}

@property (nonatomic, retain) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext        *managedObjectContext;


@end
