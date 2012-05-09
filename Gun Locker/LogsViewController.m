//
//  LogsViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogsViewController.h"

@implementation LogsViewController
@synthesize maintenanceCountLabel;
@synthesize malfunctionCountLabel;
@synthesize dopeCardsCountLabel;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableView_background"]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    maintenanceCountLabel.text = [NSString stringWithFormat:@"%d", [Maintenance countOfEntities]];
    malfunctionCountLabel.text = [NSString stringWithFormat:@"%d", [Malfunction countOfEntities]];
    dopeCardsCountLabel.text = [NSString stringWithFormat:@"%d",    [DopeCard countOfEntities]];
}

- (void)viewDidUnload {
    [self setMalfunctionCountLabel:nil];
    [self setMaintenanceCountLabel:nil];
    [self setDopeCardsCountLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
