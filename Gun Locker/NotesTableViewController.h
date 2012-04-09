//
//  NotesTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weapon.h"
#import "Note.h"
#import "NoteAddEditTableViewController.h"

@interface NotesTableViewController : UITableViewController {
    NSMutableDictionary *notes;
    NSMutableArray *sections;
}

@property (nonatomic, weak) Weapon *selectedWeapon;
@end
