//
//  RangingSamplesViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RangingSamplesViewController.h"

@implementation RangingSamplesViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    sizeUnits  = [NSArray arrayWithObjects:@"inches", @"feet", @"yards", @"meters", nil];
    spansUnits = [NSArray arrayWithObjects:@"MOA", @"Mils", nil];

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *components = [cell.detailTextLabel.text componentsSeparatedByString:@" "];
    
    if (indexPath.section == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectSize" object:components];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectSpans" object:components];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
