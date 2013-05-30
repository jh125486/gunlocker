//
//  MagazineByCaliberListViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagazineListByCaliberViewController.h"

@implementation MagazineListByCaliberViewController
@synthesize noMagazineImageView;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // dictionary of caliber keys and caliber summed values
    magazineByCaliberDict = [[NSMutableDictionary alloc] init];
    for (Magazine *magazine in [Magazine findAll]) {
        NSNumber *count = [[magazineByCaliberDict objectsForKeys:[NSArray arrayWithObject:magazine.caliber] 
                                                   notFoundMarker:[NSNumber numberWithInt:0] ] objectAtIndex:0];
        [magazineByCaliberDict setValue:[NSNumber numberWithInt:[count intValue] + [magazine.count intValue]] forKey:magazine.caliber];
    }
    calibers = [magazineByCaliberDict keysSortedByValueUsingSelector:@selector(compare:)];

    [self updateTitle];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)updateTitle {
    int count = [calibers count];
    self.title = [NSString stringWithFormat:@"Calibers (%d)", count];
    
    // change to Table/Magazine
    self.noMagazineImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Images/Table/Blanks/Magazines"]];
    self.noMagazineImageView.hidden = (count != 0);
    self.tableView.hidden = (count == 0);    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;

	if ([segueID isEqualToString:@"MagazineByBrand"]) {
        MagazineListByBrandViewController *dst = segue.destinationViewController;
        dst.selectedCaliber = [calibers objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Calibers" 
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:nil 
                                                                            action:nil];
}

# pragma mark UITableviewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [calibers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MagazineByCaliberCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *caliber = [calibers objectAtIndex:indexPath.row];
    cell.textLabel.text = caliber;
    cell.detailTextLabel.text = [[magazineByCaliberDict valueForKey:caliber] stringValue];
}

@end
