//
//  NotesTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotesListViewController.h"

@implementation NotesListViewController
@synthesize noNotesImageView = _noNotesImageView;
@synthesize tableView;
@synthesize selectedWeapon = _selectedWeapon;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];

    //Register addNewNoteToArray to recieve "newNote" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewNote:) name:@"newNote" object:nil];

    self.navigationItem.rightBarButtonItem.enabled = _selectedWeapon ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadNotes];
    [self.tableView reloadData];  
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setTitle {
    int count = _selectedWeapon ? [_selectedWeapon.notes count] : [Note countOfEntities];
    self.title = [NSString stringWithFormat:@"Notes (%d)", count];
    
    self.noNotesImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Table/Notes"]];
    self.noNotesImageView.hidden = (count != 0);
    self.tableView.hidden = (count == 0);
}

- (void)loadNotes {
    notes = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    if (_selectedWeapon) {
        sections = [[_selectedWeapon.notes sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    } else {
        for(Note *note in [Note findAllSortedBy:@"date" ascending:YES]) {
            if ([notes objectForKey:note.weapon] != nil) {
                [(NSMutableArray *)[notes objectForKey:note.weapon] addObject:note];
            } else {
                [sections addObject:note.weapon];
                [notes setObject:[NSMutableArray arrayWithObject:note] forKey:note.weapon];
            }
        }
        [sections sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"model" ascending:YES]]];
        sections = [[[sections reverseObjectEnumerator] allObjects] mutableCopy];
    }
    
    [self setTitle];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setTableView:nil];
    [self setNoNotesImageView:nil];
    [self setSelectedWeapon:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
    if ([segueID isEqualToString:@"EditNote"]) {
        NoteAddEditTableViewController *dst = segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        dst.passedNote = (_selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[notes objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (_selectedWeapon) ? 1 : [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (_selectedWeapon) ? [sections count] : [[notes objectForKey:[sections objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (_selectedWeapon) ? nil : [[sections objectAtIndex:section] distanceOfTimeInWordsOnlyDate];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NoteCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

    
    Note *currentNote = (_selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[notes objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.textLabel.text = currentNote.title;
    
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:currentNote.date
                                                               dateStyle:NSDateFormatterShortStyle 
                                                               timeStyle:NSDateFormatterShortStyle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Note *currentNote = (_selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[notes objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [currentNote deleteEntity];
        [[NSManagedObjectContext defaultContext] save];  

        // update table data
        if(self.selectedWeapon) {
            [sections removeObject:currentNote];            
        } else {
            [(NSMutableArray *)[notes objectForKey:currentNote.weapon] removeObject:currentNote];
        }

        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setTitle];
    }
}

- (void) addNewNote:(NSNotification*) notification {
    Note *newNote = [notification object];
    newNote.weapon = _selectedWeapon;
    [[NSManagedObjectContext defaultContext] save];
    [TestFlight passCheckpoint:@"New Note saved"];
}

@end
