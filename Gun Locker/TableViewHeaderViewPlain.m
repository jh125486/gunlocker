//
//  TableViewHeaderViewPlain.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableViewHeaderViewPlain.h"

@implementation TableViewHeaderViewPlain
@synthesize headerTitleLabel;

-(void)awakeFromNib {
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Table/tableView_header_background"]];    
}

@end
