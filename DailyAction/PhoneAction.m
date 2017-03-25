//
//  PhoneAction.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "PhoneAction.h"

@implementation PhoneAction

+ (NSString *)primaryKey
{
    return @"phoneActionID";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"phoneActionID": [[NSUUID UUID] UUIDString]};
}

@end
