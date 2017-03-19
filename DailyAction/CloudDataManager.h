//
//  CloudDataManager.h
//

#import <Foundation/Foundation.h>
#import "UserDataManager.h"
#import "ActionDataManager.h"
#import "OpportunityDataManager.h"
#import "Constants.h"
#import "User.h"
#import "Opportunity.h"
#import "PhoneAction.h"
#import "EmailAction.h"
#import "Issue.h"
#import "AFNetworking.h"

@interface CloudDataManager : NSObject

+ (CloudDataManager *) sharedInstance;

//- (void)postUDID;
//- (void)loginUserWithUsername:(NSString*)username andPassword:(NSString*)password onSuccess:(void (^)(void))success onFailure:(void (^)(NSError *))failure;
//- (void)createUserWithUsername:(NSString*)username andPassword:(NSString*)password onSuccess:(void (^)(void))success onFailure:(void (^)(NSError *))failure;
//- (void)syncReport:(Report*)report;
//- (void)syncMostRecentReport;
//- (void)downloadReportsForRouteWithID:(NSString *)routeID onSuccess:(void (^)(NSDictionary* reports))success onFailure:(void (^)(NSError *))failure;
//- (void)reportsForRouteWithUID:(NSString *)routeUID withPage:(NSInteger)page onSuccess:(void (^)(NSArray *))success onFailure:(void (^)(NSError *))failure;
//- (void)updateReportWithReasons:(NSArray*)reasons;
//- (void)downloadAllRoutesFromServerWithDataOnSuccess:(void (^)(NSDictionary* routesDictionary))success;
//- (void)downloadAllAgenciesFromServerWithDataOnSuccess:(void (^)(NSDictionary* agenciesDictionary))success  onFailure:(void (^)(NSError *))failure;
//- (void)addEmailToMailingList:(NSString*)email;
//- (void)downloadRouteWithUID:(NSString*)routeID onSuccess:(void (^)(NSDictionary *))downloadedRoute onFailure:(void (^)(NSError *))failure;
//- (void)downloadLogosForAgencies:(NSArray*)agencies;

@end
