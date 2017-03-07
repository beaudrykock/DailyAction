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

@property NSInteger opportunityID;
@property NSString * title;
@property NSString * sponsor;
@property NSDate * dueDate;
@property NSInteger difficulty;
@property NSInteger criticality;
@property NSString * summary;
@property NSString * detail;
@property Action * action;
@property NSInteger parentIssueID;

@end
