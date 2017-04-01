//
//  ActionDataManager.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/19/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "ActionDataManager.h"

@implementation ActionDataManager

+ (ActionDataManager *)sharedInstance
{
    static ActionDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ActionDataManager alloc] init];
        [sharedInstance setup];
    });
    return sharedInstance;
}

- (void)setup
{
    
}

@end
