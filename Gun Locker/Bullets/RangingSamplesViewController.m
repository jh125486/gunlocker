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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:(indexPath.section == 0) ? @"didSelectSize" : @"didSelectSpans" object:components];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) return nil;

	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Table/tableView_header_background"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, headerView.frame.size.width - 20, tableView.sectionHeaderHeight)];
	label.text = sectionTitle;
	label.font = [UIFont fontWithName:@"AmericanTypewriter" size:18.0];
	label.shadowColor = [UIColor lightTextColor];
    label.shadowOffset = CGSizeMake(0, 1);
	label.backgroundColor = [UIColor clearColor];    
	label.textColor = [UIColor blackColor];
    
	[headerView addSubview:label];
	return headerView;
}

@end
