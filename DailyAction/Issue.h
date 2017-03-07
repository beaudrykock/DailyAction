//
//  Issue.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <Realm/Realm.h>

@interface Issue : RLMObject

@property NSInteger issueID;
@property NSString *title;
@property NSString *issueDescription;

@end
