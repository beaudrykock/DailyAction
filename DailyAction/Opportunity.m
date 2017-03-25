//
//  Opportunity.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "Opportunity.h"

@implementation Opportunity

+ (NSString *)primaryKey
{
    return @"opportunityID";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"opportunityID": [[NSUUID UUID] UUIDString]};
}

@end
