//
//  PhoneAction.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface PhoneAction : RLMObject

@property NSInteger phoneActionID;
@property NSString *phoneNumber;
@property NSString *phoneName;
@property NSString *script;

@end

RLM_ARRAY_TYPE(PhoneAction) // Defines an RLMArray<Action> type
