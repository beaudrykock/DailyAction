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

- (void)createOpportunitiesWithData:(NSDictionary*)opportunities;
- (RLMResults<Opportunity*>*)actedOnOpportunities;
- (Opportunity*)todaysOpportunity;
- (NSInteger)countOfActedOnOpportunities;

@end
