//
//  Weapon.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Weapon.h"
#import "BallisticProfile.h"
#import "DopeCard.h"
#import "Maintenance.h"
#import "Malfunction.h"
#import "Manufacturer.h"
#import "Note.h"
#import "Photo.h"
#import "StampInfo.h"


@implementation Weapon

@dynamic barrel_length;
@dynamic caliber;
@dynamic finish;
@dynamic indexLetter;
@dynamic last_cleaned_date;
@dynamic last_cleaned_round_count;
@dynamic model;
@dynamic note;
@dynamic purchased_date;
@dynamic purchased_price;
@dynamic round_count;
@dynamic serial_number;
@dynamic threaded_barrel;
@dynamic threaded_barrel_pitch;
@dynamic type;
@dynamic ballistic_profile;
@dynamic dope_cards;
@dynamic maintenances;
@dynamic malfunctions;
@dynamic manufacturer;
@dynamic notes;
@dynamic photos;
@dynamic preferred_load;
@dynamic stamp;
@dynamic primary_photo;

@end
