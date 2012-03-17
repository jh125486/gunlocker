//
//  WeaponCell.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 2/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeaponCell.h"

@implementation WeaponCell

@synthesize manufacturerLabel;
@synthesize modelLabel;
@synthesize barrelLengthLabel;
@synthesize finishLabel;
@synthesize roundCountLabel;
@synthesize serialNumberLabel;
@synthesize malfunctionNumberLabel;
@synthesize caliberLabel;
@synthesize purchaseDatePromptLabel;
@synthesize purchaseDateLabel;
@synthesize photoImageView;
@synthesize weapon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
