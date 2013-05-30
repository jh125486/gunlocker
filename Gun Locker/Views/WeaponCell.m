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
@synthesize barrelInfoLabel;
@synthesize finishLabel;
@synthesize roundCountLabel;
@synthesize serialNumberLabel;
@synthesize malfunctionNumberLabel;
@synthesize caliberLabel;
@synthesize purchaseInfoLabel;
@synthesize photoImageContainer;
@synthesize photoButton;
@synthesize stampViewButton;
@synthesize stampViewContainer;
@synthesize stampSerialNumberLabel;
@synthesize stampDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)configureWithWeapon:(Weapon *)weapon {
    self.manufacturerLabel.text = weapon.manufacturer.displayName;
	self.modelLabel.text = weapon.model;
    self.caliberLabel.text =  weapon.caliber ? weapon.caliber : @"n/a";
    
    if ((weapon.barrel_length > 0) && (weapon.threaded_barrel_pitch.length > 0)) {
        self.barrelInfoLabel.text = [NSString stringWithFormat:@"%@\" threaded %@", weapon.barrel_length, weapon.threaded_barrel_pitch];
    } else if (weapon.barrel_length > 0) {
        self.barrelInfoLabel.text = [NSString stringWithFormat:@"%@\"", weapon.barrel_length];
    } else if (weapon.threaded_barrel_pitch.length > 0) {
        self.barrelInfoLabel.text = [NSString stringWithFormat:@"threaded %@", weapon.threaded_barrel_pitch];
    } else {
        self.barrelInfoLabel.text = @"n/a";
    }
    
    self.finishLabel.text = weapon.finish;
    
    self.serialNumberLabel.text = !weapon.serial_number.length ? @"n/a" : weapon.serial_number;
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [currencyFormatter setLocale:[NSLocale currentLocale]];
    NSString *purchasePrice = [weapon.purchased_price compare:[NSDecimalNumber zero]] ? [NSString stringWithFormat:@" for %@", [currencyFormatter stringFromNumber:weapon.purchased_price]] : @"";
    NSString *purchaseDate = (weapon.purchased_date) ? [[weapon.purchased_date distanceOfTimeInWordsOnlyDate] lowercaseString] : @"";
    
    if ((purchasePrice.length > 0) || (purchaseDate.length > 0)) {
        self.purchaseInfoLabel.text = [NSString stringWithFormat:@"%@%@", purchaseDate, purchasePrice];
    } else {
        self.purchaseInfoLabel.text = @"n/a";
    }
    
    self.malfunctionNumberLabel.text = [NSString stringWithFormat:@"%d", [weapon.malfunctions count]];
    self.malfunctionNumberLabel.textColor = ([weapon.malfunctions count] > 0) ? [UIColor redColor] : [UIColor blackColor];
    
    self.roundCountLabel.text = [weapon.round_count stringValue];
    
    if (weapon.primary_photo) {
        [self.photoImageContainer setHidden:NO];
        [self.photoButton setImage:[UIImage imageWithData:weapon.primary_photo.thumbnail_size] forState:UIControlStateNormal];
    } else {
        [self.photoImageContainer setHidden:YES];
    }
    
    // add S/N and date onto stamp
    if (weapon.stamp.stamp_received) {
        [self.stampViewContainer setHidden:NO];
        switch ([weapon.stamp.nfa_type intValue]) {
            case 5: //AOW
                [self.stampViewButton setImage:[UIImage imageNamed:@"Images/Stamps/AOW"] forState:UIControlStateNormal];
                self.stampDateLabel.transform = CGAffineTransformMakeRotation(-0.6);
                self.stampSerialNumberLabel.frame = CGRectMake(13, 15, 60, 21);
                self.stampDateLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:17.0];
                break;
                
            default:
                [self.stampViewButton setImage:[UIImage imageNamed:@"Images/Stamps/NFA"] forState:UIControlStateNormal];
                self.stampDateLabel.transform = CGAffineTransformMakeRotation(-0.8);
                self.stampDateLabel.font = [UIFont fontWithName:@"AmericanTypewriter-CondensedBold" size:17.0];
                self.stampSerialNumberLabel.frame = CGRectMake(14, 11, 58, 21);
                break;
        }
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"LLL dd yyyy"];
        self.stampDateLabel.text = [[dateFormat stringFromDate:weapon.stamp.stamp_received] uppercaseString];        
        
        self.stampSerialNumberLabel.text = weapon.serial_number;
        self.photoImageContainer.frame = CGRectMake(5, 50, 169, 157);
    } else {
        self.photoImageContainer.frame = CGRectMake(74, 50, 169, 157);
        [self.stampViewContainer setHidden:YES];
    }
    
}

@end
