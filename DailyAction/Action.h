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

@property NSInteger actionID;
@property NSInteger type;
@property PhoneAction *phoneAction;
@property EmailAction *emailAction;
@property NSInteger parentOpportunityID;

@end

RLM_ARRAY_TYPE(Action) // Defines an RLMArray<Action> type
