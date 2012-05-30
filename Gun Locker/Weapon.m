//
//  Weapon.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Weapon.h"
#import "BallisticProfile.h"
#import "DopeCard.h"
#import "Maintenance.h"
#import "Malfunction.h"
#import "Manufacturer.h"
#import "Note.h"
#import "StampInfo.h"


@implementation Weapon

@dynamic barrel_length;
@dynamic caliber;
@dynamic finish;
@dynamic indexLetter;
@dynamic model;
@dynamic note;
@dynamic photo;
@dynamic photo_thumbnail;
@dynamic purchased_date;
@dynamic purchased_price;
@dynamic round_count;
@dynamic serial_number;
@dynamic threaded_barrel;
@dynamic threaded_barrel_pitch;
@dynamic type;
@dynamic last_cleaned_date;
@dynamic last_cleaned_round_count;
@dynamic ballistic_profile;
@dynamic dope_cards;
@dynamic maintenances;
@dynamic malfunctions;
@dynamic manufacturer;
@dynamic notes;
@dynamic preferred_load;
@dynamic stamp;

@end
