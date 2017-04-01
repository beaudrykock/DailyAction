//
//  Action.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "Action.h"

@implementation Action

+ (NSString *)primaryKey
{
    return @"actionID";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"actionID": [[NSUUID UUID] UUIDString]};
}

@end
