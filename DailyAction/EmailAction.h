//
//  EmailAction.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <Realm/Realm.h>

@interface EmailAction : RLMObject

@property NSNumber<RLMInt>* emailActionID;
@property NSString *emailAddress;
@property NSString *emailName;
@property NSString *emailScript;

@end
