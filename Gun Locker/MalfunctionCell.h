//
//  MalfunctionCell.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MalfunctionCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *roundCountLabel;
@property (nonatomic, strong) IBOutlet UITextView *failtureText;
@property (nonatomic, strong) IBOutlet UITextView *fixText;
@property (nonatomic, strong) IBOutlet UILabel *modelLabel;

@end
