//
//  UserDataManager.m
//  TransitVibe
//
//  Created by Beaudry Kock on 3/3/16.
//  Copyright © 2016 RideScout. All rights reserved.

#import "UserDataManager.h"



@implementation UserDataManager
+ (UserDataManager *)sharedInstance
{
    static UserDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserDataManager alloc] init];
        [sharedInstance setup];
    });
    return sharedInstance;
}

- (void)setup
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];
    
    if (!user)
    {
        User *user = [[User alloc] init];
        [Utilities createNewUDID];
        user.uuid = [Utilities UDID];
        [realm beginWriteTransaction];
        [realm addObject:user];
        [realm commitWriteTransaction];
    }
    
    // sets if doesn't exist
    [self setUserVotingZipcode];
 }

// only for setting if zipcode doesn't already exist, based on location
- (void)setUserVotingZipcode
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];

    if (!user.zipcode)
    {
        INTULocationManager *locMgr = [INTULocationManager sharedInstance];
        
        [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                           timeout:10.0
                              delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                             block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                 if (status == INTULocationStatusSuccess) {
                                                     // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                     // currentLocation contains the device's current location.
                                                     [self updateUserZipFromLocation:currentLocation];
                                                 }
                                                 else if (status == INTULocationStatusTimedOut) {
                                                     // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                     // However, currentLocation contains the best location available (if any) as of right now,
                                                     // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                                 }
                                                 else {
                                                     // An error occurred, more info is available by looking at the specific status returned.
                                                 }
                                             }];
    }
}

// writes over zip whether set or not
- (void)updateUserVotingZipcode:(NSString*)zipcode
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];
    
    if (user)
    {
        [realm beginWriteTransaction];
        user.zipcode = zipcode;
        [realm addOrUpdateObject:user];
        [realm commitWriteTransaction];
    }
}

// writes over locality whether set or not
- (void)updateUserVotingLocality:(NSString*)locality
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];
    
    if (user)
    {
        [realm beginWriteTransaction];
        user.city = locality;
        [realm addOrUpdateObject:user];
        [realm commitWriteTransaction];
    }
}

// writes over location source whether set or not
- (void)updateUserLocationSource:(NSString*)source
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];
    
    if (user)
    {
        [realm beginWriteTransaction];
        user.locationSource = source;
        [realm addOrUpdateObject:user];
        [realm commitWriteTransaction];
    }
}

// call when user has manually corrected zip
- (void)updateUserVotingLocalityFromZipcode:(NSString*)zipcode
{
    [[CLGeocoder new] geocodeAddressString:zipcode completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count) {
            CLPlacemark *placemark = placemarks.firstObject;
            
            NSString *city = placemark.locality;
            
            [self updateUserVotingLocality:city];
            
             [[NSNotificationCenter defaultCenter] postNotificationName:UPDATED_USER_LOCATION object:nil];
        }
    }];
}

- (void)updateUserZipFromLocation:(CLLocation*)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString *zipcode = [[NSString alloc]initWithString:placemark.postalCode];
             NSString *shortZip;
             if (zipcode.length>5)
                 shortZip = [zipcode substringToIndex:5];
             else
                 shortZip = zipcode;
             NSLog(@"Zipcode: %@",shortZip);
             
             [self updateUserVotingZipcode:shortZip];
             [self updateUserVotingLocality:placemark.locality];
             [self updateUserLocationSource:AUTO];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:UPDATED_USER_LOCATION object:nil];
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error); // Error handling must required
         }
     }];
}

- (NSString*)userVotingZip
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];
    
    if (user)
        return user.zipcode;
    return nil;
}

- (NSString*)userLocationSource
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];
    
    if (user)
        return user.locationSource;
    return nil;
}

- (NSString*)userVotingLocality
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    User *user = [self currentUserInRealm:realm];
    
    if (user)
        return user.city;
    return nil;
}


//
//- (void)awardPointsForRouteUID:(NSString *)route_uid
//{
//    // base points award is 10 points
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    Rider *rider = [self currentRiderInRealm:realm];
//
//    [realm beginWriteTransaction];
//    rider.last_points_award = @10;
//    
//    if (![[NSCalendar currentCalendar] isDateInToday:rider.date_last_points_awarded])
//    {
//        // reset count of points today
//        rider.points_today = @10;
//        rider.date_last_points_awarded = [NSDate date];
//    }
//    else
//    {
//        rider.points_today = [NSNumber numberWithInteger:rider.points_today.integerValue+rider.last_points_award.integerValue];
//    }
//    
//    rider.points = [NSNumber numberWithInteger:rider.points.integerValue + 10];
//    [realm addOrUpdateObject:rider];
//    [realm commitWriteTransaction];
//    
//    // updates badges
//    [self updateBadgesForRouteUID:route_uid];
//}
//
//- (void)updateRiderLevel
//{
//    // base points award is 10 points
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    Rider *rider = [self currentRiderInRealm:realm];
//    
//    // check for any levels change
//    RLMResults <Level*> *levels = [Level allObjectsInRealm:realm];
//    
//    Level *candidate;
//    for (Level *level in levels)
//    {
//        if (rider.points.integerValue > level.level_points_threshold.integerValue)
//            candidate = level;
//    }
//    
//    [realm beginWriteTransaction];
//    if (candidate)
//        rider.level_description = candidate.level_description;
//    [realm addOrUpdateObject:rider];
//    [realm commitWriteTransaction];
//}
//
//- (NSInteger)pointsForRider
//{
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    
//    Rider *rider = [self currentRiderInRealm:realm];
//    
//    if (rider)
//        return rider.points.integerValue;
//    return 0;
//}
//
//- (NSInteger)lastPointsAwardForRider
//{
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    
//    Rider *rider = [self currentRiderInRealm:realm];
//    
//    if (rider)
//        return rider.last_points_award.integerValue;
//    return 0;
//}
//
//- (void)updateBadgesForRouteUID:(NSString*)route_uid
//{
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    
//    RLMResults <BadgeAward*> *badgeAwards = [self badgesForRiderInRealm:realm];
//    
//    Rider *rider = [self currentRiderInRealm:realm];
//    
//    BOOL firstOnRoute = YES;
//    BOOL firstToday = YES;
//    
//    [realm beginWriteTransaction];
//    
//    // check for previously awarded badges and if they meet award conditions
//    for (BadgeAward *badgeAward in badgeAwards)
//    {
//        if ([badgeAward.route_uid isEqualToString:route_uid])
//            firstOnRoute = NO;
//        
//        if ([[NSCalendar currentCalendar] isDateInToday:badgeAward.awarded_at])
//            firstToday = NO;
//        
//        badgeAward.newly_awarded = @NO;
//    }
//    
//    [realm addOrUpdateObjectsFromArray:badgeAwards];
//    [realm commitWriteTransaction];
//    
//    NSMutableArray *badgesToAward = [NSMutableArray arrayWithCapacity:10];
//    NSInteger additionalPoints = 0;
//    
//    // now award badges
//    if (firstOnRoute)
//    {
//        // first get badge template
//        BadgeTemplate *template = [self badgeTemplateWithID:BADGE_ID_firstReportOnRoute inRealm:realm];
//        
//        BadgeAward *newBadgeAward = [[BadgeAward alloc] init];
//        newBadgeAward.badge_description = template.badge_description;
//        newBadgeAward.badge_image_filename = template.badge_image_filename;
//        newBadgeAward.badge_points = template.badge_points;
//        newBadgeAward.awarded_at = [NSDate date];
//        newBadgeAward.route_uid = route_uid;
//        newBadgeAward.newly_awarded = @YES;
//        newBadgeAward.badge_type = BADGE_ID_firstReportOnRoute;
//        newBadgeAward.rider_uuid = rider.uuid;
//        newBadgeAward.badge_uid = [[NSUUID UUID] UUIDString];
//        additionalPoints += template.badge_points.integerValue;
//        [badgesToAward addObject:newBadgeAward];
//        
//        [realm beginWriteTransaction];
//        [realm addObject:newBadgeAward];
//        [realm commitWriteTransaction];
//    }
//    
//    if (firstToday)
//    {
//        // first get badge template
//        BadgeTemplate *template = [self badgeTemplateWithID:BADGE_ID_firstReportOfDay inRealm:realm];
//        
//        BadgeAward *newBadgeAward = [[BadgeAward alloc] init];
//        newBadgeAward.badge_description = template.badge_description;
//        newBadgeAward.badge_image_filename = template.badge_image_filename;
//        newBadgeAward.badge_points = template.badge_points;
//        newBadgeAward.awarded_at = [NSDate date];
//        newBadgeAward.newly_awarded = @YES;
//        newBadgeAward.route_uid = route_uid;
//        newBadgeAward.badge_type = BADGE_ID_firstReportOfDay;
//        newBadgeAward.rider_uuid = rider.uuid;
//        newBadgeAward.badge_uid = [[NSUUID UUID] UUIDString];
//        additionalPoints += template.badge_points.integerValue;
//        [badgesToAward addObject:newBadgeAward];
//        
//        [realm beginWriteTransaction];
//        [realm addObject:newBadgeAward];
//        [realm commitWriteTransaction];
//    }
//    
////    NSLog(@"Before badge award - ");
////    NSLog(@"Rider last points award = %i", rider.last_points_award.intValue);
////    NSLog(@"Rider points today = %i", rider.points_today.intValue);
////    NSLog(@"Rider points = %i", rider.points.intValue);
//    
//    
//    if (badgesToAward.count>0)
//    {
//        [realm beginWriteTransaction];
//        rider.last_points_award = [NSNumber numberWithInteger:additionalPoints];
//        rider.points_today = [NSNumber numberWithInteger:rider.points_today.integerValue+rider.last_points_award.integerValue];
//        rider.points = [NSNumber numberWithInteger:rider.points.integerValue + additionalPoints];
//        
//        [realm commitWriteTransaction];
//    }
//    
////    NSLog(@"After badge award - ");
////    NSLog(@"Rider last points award = %i", rider.last_points_award.intValue);
////    NSLog(@"Rider points today = %i", rider.points_today.intValue);
////    NSLog(@"Rider points = %i", rider.points.intValue);
//
//
//    [self updateRiderLevel];
//}
//
//- (BadgeTemplate*)badgeTemplateWithID:(NSString*)badge_id inRealm:(RLMRealm*)realm
//{
//    RLMResults <BadgeTemplate*> *badges = [BadgeTemplate objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"badge_id = %@", badge_id]];
//    
//    if (badges.count>=1)
//        return badges[0];
//    
//    return nil;
//}
//
//-(NSInteger)pointsForRiderToday
//{
//    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
//    
//    Rider *rider = [self currentRiderInRealm:defaultRealm];
//    
//    return rider.points_today.integerValue;
//}
//
//- (Level *)levelForRider
//{
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    
//    Rider *rider = [self currentRiderInRealm:realm];
//    
//    RLMResults <Level*> *levels = [Level objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"level_description = %@", rider.level_description]];
//    
//    if (levels.count>=1)
//        return levels[0];
//    
//    return nil;
//}
//
//- (NSArray*)newBadgesAwardedToRider
//{
//    RLMRealm *realm = [RLMRealm defaultRealm];
//    
//    RLMResults<BadgeAward*> *badgeAwards = [self badgesForRiderInRealm:realm];
//    
//    NSMutableArray *newBadges = [NSMutableArray arrayWithCapacity:100];
//    
//    for (BadgeAward *badge in badgeAwards)
//    {
//        if (badge.newly_awarded.boolValue)
//            [newBadges addObject:badge];
//    }
//    
//    return newBadges;
//}
//
//- (RLMResults*)badgesForRiderInRealm:(RLMRealm *)realm
//{
//    Rider *rider = [self currentRiderInRealm:realm];
//    
//    RLMResults<BadgeAward*> *badgeAwards = [BadgeAward objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"rider_uuid = %@", rider.uuid]];
//    
//    return badgeAwards;
//}
//
- (User*)currentUserInRealm:(RLMRealm*)realm
{
    RLMResults <User*> *users = [User objectsInRealm: realm withPredicate:[NSPredicate predicateWithFormat:@"uuid = %@", [Utilities UDID]]];
    
    if (users.count >= 1)
        return users[0];
    
    return nil;
}
//
//- (Level *)levelWithDescription:(NSString*)description inRealm: (RLMRealm*)realm
//{
//    RLMResults <Level*> *levels = [Level objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"level_description = %@", description]];
//    
//    if (levels.count>=1)
//        return levels[0];
//    
//    return nil;
//}
//
//- (NSString *)createRiderWithUsername:(NSString*)username andPassword:(NSString*)password andUdid:(NSString*)udid
//{
//    RLMRealm *defaultRealm = [RLMRealm defaultRealm];
//    
//    Rider *rider = [[Rider alloc] init];
//    rider.username = username;
//    rider.password = password;
//    rider.uuid = udid;
//    rider.points = @0;
//    rider.last_points_award = @0;
//    Level *level = [self levelWithDescription: @"Friendly Suggestion" inRealm: defaultRealm];
//    rider.level_description = level.level_description;
//    rider.logged_in = @YES;
//    
//    [defaultRealm beginWriteTransaction];
//    [defaultRealm addOrUpdateObject:rider];
//    [defaultRealm commitWriteTransaction];
//
//    [Answers logLoginWithMethod:@"Automatic"
//                        success:@YES
//               customAttributes:@{@"username" : username}];
//    
//    return udid;
//}
//
//- (void)readInBadges
//{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"gamification" ofType:@"json"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    NSData *allGamificationData = [NSData dataWithContentsOfURL:url];
//    
//    NSArray *badges = [[JSONParser sharedInstance] badgesFromData:allGamificationData];
//    
//    // only proceed if badges don't exist
//    RLMResults <BadgeTemplate*> *existingBadges = [BadgeTemplate allObjects];
//    
//    NSMutableArray *badgesToAdd = [NSMutableArray arrayWithCapacity:10];
//    
//    if (existingBadges.count == 0)
//    {
//        for (NSDictionary *badge in badges)
//        {
//            BadgeTemplate *newBadge = [[BadgeTemplate alloc] init];
//            newBadge.badge_description = badge[@"badge_description"];
//            newBadge.badge_image_filename = badge[@"badge_image_filename"];
//            newBadge.badge_points = badge[@"badge_points"];
//            newBadge.badge_id = badge[@"badge_id"];
//            
//            [badgesToAdd addObject:newBadge];
//        }
//        
//        RLMRealm *realm = [RLMRealm defaultRealm];
//        [realm beginWriteTransaction];
//        [realm addOrUpdateObjectsFromArray:badgesToAdd];
//        [realm commitWriteTransaction];
//    }
//}
//
//- (void)readInLevels
//{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"gamification" ofType:@"json"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    NSData *allGamificationData = [NSData dataWithContentsOfURL:url];
//    
//    NSArray *levels = [[JSONParser sharedInstance] levelsFromData:allGamificationData];
//    
//    // only proceed if badges don't exist
//    RLMResults <Level*> *existingLevels = [Level allObjects];
//    
//    NSMutableArray *levelsToAdd = [NSMutableArray arrayWithCapacity:10];
//    
//    if (existingLevels.count == 0)
//    {
//        for (NSDictionary *level in levels)
//        {
//            Level *newLevel = [[Level alloc] init];
//            newLevel.level_description = level[@"level_description"];
//            newLevel.level_image_filename = level[@"level_image_filename"];
//            newLevel.level_points_threshold = level[@"level_points_threshold"];
//            newLevel.color_red = level[@"level_color_R"];
//            newLevel.color_blue = level[@"level_color_B"];
//            newLevel.color_green = level[@"level_color_G"];
//            [levelsToAdd addObject:newLevel];
//        }
//        
//        RLMRealm *realm = [RLMRealm defaultRealm];
//        [realm beginWriteTransaction];
//        [realm addOrUpdateObjectsFromArray:levelsToAdd];
//        [realm commitWriteTransaction];
//    }
//}

@end
