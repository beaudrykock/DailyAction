//
//  UserDataManager.h
//  TransitVibe
//
//  Created by Beaudry Kock on 3/3/16.
//  Copyright © 2016 RideScout. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JSONParser.h"
#import "User.h"
#import "Utilities.h"
//#import <Crashlytics/Crashlytics.h>
#import <Realm/Realm.h>

@interface UserDataManager : NSObject
+ (UserDataManager *) sharedInstance;

- (void)storeUserVotingZipcode:(NSString*)zipcode;

//
//- (NSInteger)lastPointsAwardForRider;
//- (NSInteger)pointsForRider;
//- (void)awardPointsForRouteUID:(NSString*)route_uid;
//- (RLMResults*)badgesForRiderInRealm:(RLMRealm*)realm;
//- (Level *)levelForRider;
//- (NSArray *)newBadgesAwardedToRider;
//- (NSString *)createRiderWithUsername:(NSString*)username andPassword:(NSString*)password andUdid:(NSString*)udid;
//-(NSInteger)pointsForRiderToday;

@end
