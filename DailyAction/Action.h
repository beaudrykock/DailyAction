//
//  Action.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "PhoneAction.h"
#import "EmailAction.h"

@interface Action : RLMObject

@property NSNumber<RLMInt>* actionID;
@property NSNumber<RLMInt>* actionType;
@property NSNumber<RLMInt>* subActionID;
@property NSNumber<RLMInt>* parentOpportunityID;

@end

RLM_ARRAY_TYPE(Action) // Defines an RLMArray<Action> type
