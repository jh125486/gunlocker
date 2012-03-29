//
//  MaintenanceCell.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MaintenanceCell.h"

@implementation MaintenanceCell
@synthesize dateLabel, roundCountLabel, actionPerformedLabel, malfunctionsTextView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
