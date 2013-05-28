//
//  DropCardRowEditCell.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DopeCardRowEditCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField *rangeField;
@property (nonatomic, strong) IBOutlet UITextField *dropField;
@property (nonatomic, strong) IBOutlet UITextField *driftField;

@end
