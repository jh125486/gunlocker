//
//  AmmunitionListViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AmmunitionListByCaliberViewController.h"

@implementation AmmunitionListByCaliberViewController
@synthesize noAmmunitionImageView;
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
    ammunitionByCaliberDict = [[NSMutableDictionary alloc] init];
    for (Ammunition *ammo in [Ammunition findAll]) {
        NSNumber *count = [[ammunitionByCaliberDict objectsForKeys:[NSArray arrayWithObject:ammo.caliber] 
                                                    notFoundMarker:[NSNumber numberWithInt:0] ] objectAtIndex:0];
        [ammunitionByCaliberDict setValue:[NSNumber numberWithInt:[count intValue] + [ammo.count intValue]] forKey:ammo.caliber];
    }
    calibers = [ammunitionByCaliberDict keysSortedByValueUsingSelector:@selector(compare:)];

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
    
    // change to Table/Ammunition
    self.noAmmunitionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Table/Ammunition"]];
    self.noAmmunitionImageView.hidden = (count != 0);
    self.tableView.hidden = (count == 0);    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueID = segue.identifier;

	if ([segueID isEqualToString:@"AmmunitionByBrand"]) {
        AmmunitionListByBrandViewController *dst = segue.destinationViewController;
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
    static NSString *CellIdentifier = @"AmmunitionByCaliberCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];    
    return cell;
}

-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *caliber = [calibers objectAtIndex:indexPath.row];
    cell.textLabel.text = caliber;
    cell.detailTextLabel.text = [[ammunitionByCaliberDict valueForKey:caliber] stringValue];
}

@end
