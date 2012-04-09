//
//  MaintenanceCell.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintenanceCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *roundCountLabel;
@property (nonatomic, strong) IBOutlet UITextView *actionPerformedText;
@property (nonatomic, strong) IBOutlet UIButton *viewMalfunctions;
@property (nonatomic, strong) IBOutlet UILabel *malfunctionCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *malfunctionLabel;
@property (nonatomic, strong) IBOutlet UILabel *modelLabel;

@end
