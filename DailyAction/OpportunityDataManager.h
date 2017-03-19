//
//  OpportunityDataManager.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Opportunity.h"
#import "Constants.h"
#import "Utilities.h"

@interface OpportunityDataManager : NSObject
+ (OpportunityDataManager *) sharedInstance;

- (Opportunity*)opportunityForDay:(NSInteger)day;
- (NSMutableArray*)opportunitiesWithCount:(NSInteger)count;
- (NSInteger)countOfOpportunities;
- (void)createOpportunitiesWithData:(NSDictionary*)opportunities;
- (RLMResults<Opportunity*>*)opportunities;

@end
