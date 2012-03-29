//
//  MaintenanceCell.h
//  Gun Locker
//
//  Created by Jacob Hochstetler on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaintenanceCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *actionPerformedLabel;
@property (nonatomic, strong) IBOutlet UILabel *roundCountLabel;
@property (nonatomic, strong) IBOutlet UITextView *malfunctionsTextView;


@end
