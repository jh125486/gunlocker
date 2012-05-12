//
//  NotesTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotesTableViewController.h"

@implementation NotesTableViewController
@synthesize selectedWeapon;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Register addNewNoteToArray to recieve "newNote" notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewNote:) name:@"newNote" object:nil];

    self.navigationItem.rightBarButtonItem.enabled = self.selectedWeapon ? YES : NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadNotes];
    [self.tableView reloadData];  
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setTitle {
    int count = self.selectedWeapon ? [self.selectedWeapon.notes count] : [Note countOfEntities];
    self.title = [NSString stringWithFormat:@"Note%@ (%d)", (count == 1) ? @"" : @"s", count];
}

- (void)loadNotes {
    notes = [[NSMutableDictionary alloc] init];
    sections = [[NSMutableArray alloc] init];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    
    if (self.selectedWeapon) {
        sections = [[self.selectedWeapon.notes sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
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
        dst.passedNote = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[notes objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.selectedWeapon) ? 1 : [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return (self.selectedWeapon) ? [sections count] : [[notes objectForKey:[sections objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (self.selectedWeapon) ? nil : [[sections objectAtIndex:section] distanceOfTimeInWordsOnlyDate];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NoteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

    
    Note *currentNote = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[notes objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    cell.textLabel.text = currentNote.title;
    
    cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:currentNote.date
                                                               dateStyle:NSDateFormatterShortStyle 
                                                               timeStyle:NSDateFormatterShortStyle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Note *currentNote = (self.selectedWeapon) ? [sections objectAtIndex:indexPath.row] : [[notes objectForKey:[sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        [currentNote deleteEntity];
        [[NSManagedObjectContext defaultContext] save];  

        // update table data
        if(self.selectedWeapon) {
            [sections removeObject:currentNote];            
        } else {
            [(NSMutableArray *)[notes objectForKey:currentNote.weapon] removeObject:currentNote];
        }

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setTitle];
    }
}

- (void) addNewNote:(NSNotification*) notification {
    Note *newNote = [notification object];
    newNote.weapon = self.selectedWeapon;
    [[NSManagedObjectContext defaultContext] save];  
}

@end
