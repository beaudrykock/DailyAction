//
//  OpportunityDataManager.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "OpportunityDataManager.h"

@implementation OpportunityDataManager
+ (OpportunityDataManager *)sharedInstance
{
    static OpportunityDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OpportunityDataManager alloc] init];
        [sharedInstance setup];
    });
    return sharedInstance;
}

- (void)setup
{
    
}

- (RLMResults<Opportunity*>*)opportunities
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"dueDate > %@", [NSDate date]]];
    
    return opportunities;
}

// returns total number of opportunities for the current issue area
- (NSInteger)countOfOpportunities
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"dueDate > %@", [NSDate date]]];
    
    return opportunities.count;
}

- (void)createOpportunitiesWithData:(NSDictionary*)opportunities
{
    NSLog(@"Creating opportunities");
    
    RLMRealm *realm = [RLMRealm defaultRealm];

    
    for (NSDictionary *opportunity in opportunities)
    {
        NSNumber *oppID = opportunity[K_OPPORTUNITY_ID];
        
        // check if exists
        RLMResults<Opportunity*> *unsyncedOpps = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"opportunityID = %@", oppID]];
        
        if (unsyncedOpps.count == 0)
        {
            // create
            Opportunity *newOpp = [[Opportunity alloc] init];
            newOpp.title = opportunity[K_OPPORTUNITY_TITLE];
            newOpp.criticality = opportunity[K_OPPORTUNITY_CRITICALITY];
            newOpp.summary = opportunity[K_OPPORTUNITY_SUMMARY];
            newOpp.sponsor = opportunity[K_OPPORTUNITY_SPONSOR];
            newOpp.difficulty = opportunity[K_OPPORTUNITY_DIFFICULTY];
            newOpp.opportunityID = opportunity[K_OPPORTUNITY_ID];
            newOpp.detail = opportunity[K_OPPORTUNITY_DETAIL];
            newOpp.dueDate = [Utilities dateFromUTCString:opportunity[K_OPPORTUNITY_DUE_DATE]];
            
            [realm beginWriteTransaction];
            [realm addObject:newOpp];
            [realm commitWriteTransaction];
            // TODO: get action and issue ID and hook up
        }
    }
    
    // diagnostics
    RLMResults<Opportunity*> *opps = [Opportunity allObjects];
    for (Opportunity *opp in opps)
    {
        NSLog(@"Opp = %@", opp.description);
    }
}

//
//- (void)syncOpportunity:(Opportunity *)report
//{
//    //[report printAllFields];
//
//    AFHTTPSessionManager *manager = [self newSessionManager];
//
////    NSString *q = [NSString stringWithFormat:@"{\"rider_id\":\"%@\",\"sentiment\":%li, \"reason\":%li, \"latitude\":%f,\"longitude\":%f, \"agency_id\":\"%@\", \"route_id\":\"%@\", \"id\":\"%@\"}", report.user_id, report.sentiment.integerValue, report.reason.integerValue, report.latitude.floatValue, report.longitude.floatValue, report.agency_id, report.route_id, report.report_id];
//
////    NSDictionary *params = @{@"q": q};
//
//    NSDictionary *params = @{@"rider_id" : report.user_id, @"sentiment":report.sentiment, @"latitude" : report.latitude, @"longitude" : report.longitude, @"reason": report.reason, @"route_id": report.route_id, @"agency_id" : report.agency_id, @"id" : report.report_id };
//    NSLog(@"syncReport params = %@", params.debugDescription);
//
//    [manager POST:URL_report parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"Successfully saved report to cloud, with sentiment %li for route %@", report.sentiment.integerValue, report.route_id);
//
//        [[TransitDataManager sharedInstance] markReportSynced:report.report_id];
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error: %@", error);
//        [CrashlyticsKit recordError:error];
//    }];
//
//}

@end
