//
//  EmailAction.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "EmailAction.h"

@implementation EmailAction

+ (NSString *)primaryKey
{
    return @"emailActionID";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"emailActionID": [[NSUUID UUID] UUIDString]};
}


@end
