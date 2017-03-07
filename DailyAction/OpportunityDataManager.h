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

@interface OpportunityDataManager : NSObject
+ (OpportunityDataManager *) sharedInstance;

- (Opportunity*)opportunityForDay:(NSInteger)day;

@end
