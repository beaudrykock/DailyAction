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
#import "Action.h"
#import "PhoneAction.h"
#import "EmailAction.h"

@interface OpportunityDataManager : NSObject
+ (OpportunityDataManager *) sharedInstance;

- (void)createOpportunitiesWithData:(NSDictionary*)opportunities;
- (void)createActionsWithData:(NSDictionary*)actions;
- (void)createPhoneActionsWithData:(NSDictionary*)phoneActions;
- (void)createEmailActionsWithData:(NSDictionary*)emailActions;
- (RLMResults<Opportunity*>*)actedOnOpportunities;
- (Opportunity*)todaysOpportunity;
- (NSInteger)countOfActedOnOpportunities;

@end
