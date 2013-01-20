//
//  PhotosTableViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotosTableViewController.h"

@implementation PhotosTableViewController
@synthesize noPhotosImageView = _noPhotosImageView;
@synthesize tableView;
@synthesize selectedWeapon = _selectedWeapon;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize addPhotoSheet = _addPhotoSheet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _addPhotoSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                 delegate:self
                                        cancelButtonTitle:kGLCancelText
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:@"Take Photo", @"Choose Existing", nil];
    
    NSError *error = nil;    
    if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
//    NSLog(@"count %d %d", [_selectedWeapon.photos count], [[[_fetchedResultsController sections] objectAtIndex:0] numberOfObjects]);
//
//    NSLog(@"all %d", [[Photo findAllWithPredicate:[NSPredicate predicateWithFormat:@"weapon = %@", _selectedWeapon]] count]);
//    NSLog(@"all %d", [[Photo findAllWithPredicate:[NSPredicate predicateWithFormat:@"(weapon = %@) OR (fromPrimaryToWeapon = %@)", _selectedWeapon,_selectedWeapon]] count]);

}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    [self setTitle];
}

- (void)setTitle {
    int count = [_fetchedResultsController.fetchedObjects count];
    self.title = [NSString stringWithFormat:@"Photos (%d)", count];
    
    _noPhotosImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Table/Photos"]];
    _noPhotosImageView.hidden = (count != 0);
    self.tableView.hidden = (count == 0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;
    
	if ([segueID isEqualToString:@"ViewPhoto"]) {
        PhotoViewController *dst = segue.destinationViewController;
        CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView]; 
        NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
        dst.passedPhoto = [_fetchedResultsController objectAtIndexPath:index];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_fetchedResultsController sections] count];
}

# pragma mark UITableviewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PhotoTableCell";
    PhotoTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];    
    return cell;
}

-(void)configureCell:(PhotoTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Photo *photo  = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.photo.image = [UIImage imageWithData:photo.thumbnail_size];
    cell.dateTakenLabel.text = [NSString stringWithFormat:@"Photo taken %@", [[photo.date_taken distanceOfTimeInWordsOnlyDate] lowercaseString]];
    cell.photoSizeLabel.text = [NSString stringWithFormat:@"Size on disk: %.2f MB", photo.sizeOnDisk];
    if ([photo.weapon.primary_photo isEqual:photo]) {
        cell.setPrimaryButton.enabled = NO;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.setPrimaryButton.enabled = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
    cell.backgroundColor = ((indexPath.row + (indexPath.section % 2))% 2 == 0) ? [UIColor clearColor] : [UIColor colorWithRed:0.855 green:0.812 blue:0.682 alpha:1.000];
}  

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // segue to photo view controller

}

#pragma mark Actions

- (IBAction)addPhotoTapped:(id)sender {    
    [_addPhotoSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)setPrimaryButtonTapped:(id)sender {
    NSIndexPath *newPrimary = [self.tableView indexPathForRowAtPoint:[sender convertPoint:CGPointZero toView:self.tableView]];
    NSIndexPath *oldPrimary = [_fetchedResultsController indexPathForObject:_selectedWeapon.primary_photo];
    
    [_selectedWeapon setPrimary_photo:[_fetchedResultsController objectAtIndexPath:newPrimary]];
    [[DataManager sharedManager] saveAppDatabase];
    
    [self configureCell:(PhotoTableCell *)[self.tableView cellForRowAtIndexPath:oldPrimary] atIndexPath:oldPrimary];
    [self configureCell:(PhotoTableCell *)[self.tableView cellForRowAtIndexPath:newPrimary] atIndexPath:newPrimary];
}

- (IBAction)deleteTapped:(id)sender {
    lastIndexPath = [self.tableView indexPathForRowAtPoint:[sender convertPoint:CGPointZero toView:self.tableView]];

    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:kGLCancelText
                   destructiveButtonTitle:@"Delete Photo"
                        otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark FetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;

    NSPredicate *typeFilter = [NSPredicate predicateWithFormat:@"weapon = %@", _selectedWeapon];
    NSFetchRequest *fetchRequest = [Photo requestAllSortedBy:@"date_taken" ascending:YES 
                                               withPredicate:typeFilter];

    fetchRequest.fetchBatchSize = 20;
    NSString *cacheName = [NSString stringWithFormat:@"Photos%@", _selectedWeapon];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                        managedObjectContext:[NSManagedObjectContext defaultContext] 
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:cacheName];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(PhotoTableCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self setTitle];
    [self.tableView endUpdates];
}

#pragma mark ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return; // sheet cancelled

    if (actionSheet == _addPhotoSheet) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = (buttonIndex == 0) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [[_fetchedResultsController objectAtIndexPath:lastIndexPath] deleteEntity];
        [[DataManager sharedManager] saveAppDatabase];
    }
}

#pragma mark - Image methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
    Photo *newPhoto = [Photo createEntity];
    [newPhoto setPhotoAndCreateThumbnailFromImage:image];
    newPhoto.weapon = _selectedWeapon;
    [[DataManager sharedManager] saveAppDatabase];
    
//    [MagicalRecord saveInBackgroundWithBlock:^(NSManagedObjectContext *localContext){
//        Photo *localPhoto = [newPhoto inContext:localContext];
//        localPhoto.weapon = _selectedWeapon;
//    }];
        
//    [_selectedWeapon addPhotosObject:newPhoto];
}

// disable camera if no camera present
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    if (actionSheet != _addPhotoSheet) return;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
    
    NSString *type = @"Take Photo";
    
    for (UIView* view in [actionSheet subviews]) {
        if ([[[view class] description] isEqualToString:@"UIAlertButton"]) {
            if ([view respondsToSelector:@selector(title)]) {
                if ([[view performSelector:@selector(title)] isEqualToString:type] && [view respondsToSelector:@selector(setEnabled:)]) {
                    [view performSelector:@selector(setEnabled:) withObject:nil];
                }		
            }        
        }   
    }
}

@end
