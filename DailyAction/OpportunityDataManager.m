//
//  OpportunityDataManager.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "OpportunityDataManager.h"

@implementation OpportunityDataManager
+ (OpportunityDataManager *)sharedInstance
{
    static OpportunityDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OpportunityDataManager alloc] init];
        [sharedInstance setup];
    });
    return sharedInstance;
}

- (void)setup
{
    
}

- (Opportunity*)opportunityForDay:(NSInteger)day
{
    // TODO
    return nil;
}

// returns total number of opportunities for the current issue area
- (NSInteger)countOfOpportunities
{
    return 7; // TODO - complete with actual count of stored opportunities
}

@end
