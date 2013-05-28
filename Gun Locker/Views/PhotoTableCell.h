//
//  PhotoTableCell.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *dateTakenLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *setPrimaryButton;
@end
