//
//  Opportunity.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Action.h"

@interface Opportunity : RLMObject

@property NSNumber<RLMInt>* opportunityID;
@property NSString * title;
@property NSString * sponsor;
@property NSDate * dueDate;
@property NSNumber<RLMInt>* difficulty;
@property NSNumber<RLMInt>* criticality;
@property NSString * summary;
@property NSString * detail;
@property Action * action;
@property NSNumber<RLMInt>* parentIssueID;

@end
