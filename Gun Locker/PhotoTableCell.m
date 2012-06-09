//
//  PhotoTableCell.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoTableCell.h"

@implementation PhotoTableCell
@synthesize photo = _photo;
@synthesize setPrimaryButton = _setPrimaryButton;
@synthesize dateTakenLabel = _dateTakenLabel;
@synthesize photoSizeLabel = _photoSizeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
