//
//  NotesTableViewController.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Models/Weapon.h"
#import "../Models/Note.h"
#import "NoteAddEditTableViewController.h"

@interface NotesListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableDictionary *notes;
    NSMutableArray *sections;
}

@property (weak, nonatomic) IBOutlet UIImageView *noNotesImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) Weapon *selectedWeapon;
@end
