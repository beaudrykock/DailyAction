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
    [self checkContentAvailability];
}

- (void)checkContentAvailability
{
    if ([self allContentCreationCompleted])
    {
        self.contentAvailable = [self opportunityAvailable];
    }
    // if no internet, or content creation not being undertaken for some
    // reason, check the state of opportunity
    else
    {
        self.contentAvailable = [self opportunityAvailable] && [self actionAvailable];
    }
}

// most imminent opportunity that hasn't yet been acted on
- (Opportunity*)todaysOpportunity
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    RLMResults<Opportunity*> *opportunities = [[Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"dueDate >= %@ AND actedOn = NO", [NSDate date]]] sortedResultsUsingKeyPath:@"dueDate" ascending:NO];
    
    if (opportunities.count>0)
        return [opportunities objectAtIndex:0];
    
    return nil;
}

- (Opportunity*)opportunityWithID:(NSNumber *)opportunityID
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"opportunityID = %@", opportunityID]];
    
    if (opportunities.count>0)
        return [opportunities objectAtIndex:0];
    
    return nil;
}

- (BOOL)opportunityAvailable
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [[Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"dueDate >= %@ AND actedOn = NO", [NSDate date]]] sortedResultsUsingKeyPath:@"dueDate" ascending:NO];
    
    return opportunities.count>0 || [self countOfActedOnOpportunities] >0;
}
                                                                
- (BOOL)actionAvailable
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Action*> *actions = [Action allObjectsInRealm:realm];
    
    return actions.count>0;
}

- (RLMResults<Opportunity*>*)actedOnOpportunities
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [[Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"actedOn = YES"]] sortedResultsUsingKeyPath:@"dueDate" ascending:NO];
    
    return opportunities;
}

// returns total number of opportunities for the current issue area, that have already been acted on
- (NSInteger)countOfActedOnOpportunities
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"actedOn = YES"]];
    
    return opportunities.count;
}

- (Action*)actionForOpportunityWithID:(NSNumber*)opportunityID
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"opportunityID = %@", opportunityID]];
    
    if (opportunities.count >= 1)
    {
        NSNumber *actionID = opportunities[0].actionID;
        RLMResults<Action*> *actions = [Action objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"actionID = %@", actionID]];
        
        if (actions.count>=1)
        {
            return actions[0];
        }
    }
    
    return nil;
}

- (void)markOpportunityAsActedOnWithID:(NSNumber*)opportunityID
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults<Opportunity*> *opportunities = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"opportunityID = %@", opportunityID]];
    if (opportunities.count >= 1)
    {
        [realm beginWriteTransaction];
        opportunities[0].actedOn = YES;
        opportunities[0].actedOnDate = [NSDate date];
        [realm addOrUpdateObject:opportunities[0]];
        [realm commitWriteTransaction];
    }
}

- (PhoneAction*)phoneActionForActionWithID:(NSNumber*)actionID
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<Action*> *actions = [Action objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"actionID = %@", actionID]];
    
    if (actions.count >= 1)
    {
        RLMResults<PhoneAction*> *phoneActions = [PhoneAction objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"phoneActionID = %@", actions[0].subActionID]];
        
        if (phoneActions.count >= 1)
            return phoneActions[0];
        
        return nil;
    }
    
    return nil;
}

- (EmailAction*)emailActionForActionWithID:(NSNumber*)actionID
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults<Action*> *actions = [Action objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"actionID = %@", actionID]];
    
    if (actions.count >= 1)
    {
        RLMResults<EmailAction*> *emailActions = [EmailAction objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"emailActionID = %@", actions[0].subActionID]];
        
        if (emailActions.count >= 1)
            return emailActions[0];
        
        return nil;
    }
    
    return nil;
}

- (void)createOpportunitiesWithData:(NSDictionary*)opportunities
{
    NSLog(@"Creating opportunities");
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    BOOL freshContent = NO;
    for (NSDictionary *opportunity in opportunities)
    {
        NSNumber *oppID = opportunity[K_OPPORTUNITY_ID];
        
        // check if exists
        RLMResults<Opportunity*> *unsyncedOpps = [Opportunity objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"opportunityID = %@", oppID]];
        
        if (unsyncedOpps.count == 0)
        {
            // create
            Opportunity *newOpp = [[Opportunity alloc] init];
            newOpp.opportunityID = opportunity[K_OPPORTUNITY_ID];
            newOpp.title = opportunity[K_OPPORTUNITY_TITLE];
            newOpp.criticality = opportunity[K_OPPORTUNITY_CRITICALITY];
            newOpp.summary = opportunity[K_OPPORTUNITY_SUMMARY];
            newOpp.sponsor = opportunity[K_OPPORTUNITY_SPONSOR];
            newOpp.difficulty = opportunity[K_OPPORTUNITY_DIFFICULTY];
            newOpp.opportunityID = opportunity[K_OPPORTUNITY_ID];
            newOpp.actionID = opportunity[K_OPPORTUNITY_ACTION_ID];
            newOpp.issueID = opportunity[K_OPPORTUNITY_ISSUE_ID];
            newOpp.detail = opportunity[K_OPPORTUNITY_DETAIL];
            newOpp.dueDate = [Utilities dateFromUTCString:opportunity[K_OPPORTUNITY_DUE_DATE]];
            newOpp.actedOn = NO;
            
            [realm beginWriteTransaction];
            [realm addObject:newOpp];
            [realm commitWriteTransaction];
           
            freshContent = YES;
        }
    }
    
    self.contentCreationCount++;
    self.contentUpdated = freshContent;
    
    // diagnostics
    RLMResults<Opportunity*> *opps = [Opportunity allObjects];
    for (Opportunity *opp in opps)
    {
        NSLog(@"Opp = %@", opp.description);
    }
}

- (BOOL)allContentCreationCompleted
{
    return self.contentCreationCount == CONTENT_CREATION_COUNT;
}

- (void)createActionsWithData:(NSDictionary*)actions
{
    NSLog(@"Creating actions");
    
    RLMRealm *realm = [RLMRealm defaultRealm];
        BOOL freshContent = NO;
    for (NSDictionary *action in actions)
    {
        NSNumber *actionID = action[K_ACTION_ID];
        
        // check if exists
        RLMResults<Action*> *unsyncedActions = [Action objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"actionID = %@", actionID]];
        
        if (unsyncedActions.count == 0)
        {
            // create
            Action *newAction = [[Action alloc] init];
            newAction.actionID = action[K_ACTION_ID];
            newAction.actionType = action[K_ACTION_TYPE];
            newAction.subActionID = action[K_SUBACTION_ID];
            
            [realm beginWriteTransaction];
            [realm addObject:newAction];
            [realm commitWriteTransaction];
            
            freshContent = YES;
        }
    }
    
    self.contentCreationCount++;
    self.contentUpdated = freshContent;

    // diagnostics
    RLMResults<Action*> *actionDiags = [Action allObjects];
    for (Action *action in actionDiags)
    {
        NSLog(@"Action = %@", action.description);
    }
}

- (void)createEmailActionsWithData:(NSDictionary*)emailActions
{
    NSLog(@"Creating email actions");
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    BOOL freshContent = NO;
    for (NSDictionary *emailAction in emailActions)
    {
        NSNumber *emailActionID = emailAction[K_EMAIL_ACTION_ID];
        
        // check if exists
        RLMResults<EmailAction*> *unsyncedActions = [EmailAction objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"emailActionID = %@", emailActionID]];
        
        if (unsyncedActions.count == 0)
        {
            // create
            EmailAction *newAction = [[EmailAction alloc] init];
            newAction.emailActionID = emailAction[K_EMAIL_ACTION_ID];
            newAction.emailAddress = emailAction[K_EMAIL_ACTION_EMAIL];
            newAction.emailName = emailAction[K_EMAIL_ACTION_NAME_TO_EMAIL];
            newAction.emailScript = emailAction[K_EMAIL_ACTION_SCRIPT];
            
            [realm beginWriteTransaction];
            [realm addObject:newAction];
            [realm commitWriteTransaction];
            
           freshContent = YES;
        }
    }
    self.contentCreationCount++;
    self.contentUpdated = freshContent;
    // diagnostics
    RLMResults<EmailAction*> *actionDiags = [EmailAction allObjects];
    for (Action *action in actionDiags)
    {
        NSLog(@"Email action = %@", action.description);
    }
}

- (void)createPhoneActionsWithData:(NSDictionary*)phoneActions
{
    NSLog(@"Creating phone actions");
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    BOOL freshContent = NO;
    for (NSDictionary *phoneAction in phoneActions)
    {
        NSNumber *phoneActionID = phoneAction[K_PHONE_ACTION_ID];
        
        // check if exists
        RLMResults<PhoneAction*> *unsyncedActions = [PhoneAction objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:@"phoneActionID = %@", phoneActionID]];
        
        if (unsyncedActions.count == 0)
        {
            // create
            PhoneAction *newAction = [[PhoneAction alloc] init];
            newAction.phoneActionID = phoneAction[K_PHONE_ACTION_ID];
            newAction.phoneNumber = phoneAction[K_PHONE_ACTION_PHONE_NUMBER];
            newAction.phoneName = phoneAction[K_PHONE_ACTION_NAME_TO_CALL];
            newAction.phoneScript = phoneAction[K_PHONE_ACTION_SCRIPT];
            
            [realm beginWriteTransaction];
            [realm addObject:newAction];
            [realm commitWriteTransaction];
           freshContent = YES;
        }
    }
    self.contentCreationCount++;
    self.contentUpdated = freshContent;
    
    // diagnostics
    RLMResults<PhoneAction*> *actionDiags = [PhoneAction allObjects];
    for (Action *action in actionDiags)
    {
        NSLog(@"Phone action = %@", action.description);
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
