//
//  CloudDataManager.m
//
//

#import "CloudDataManager.h"

@implementation CloudDataManager

+ (CloudDataManager *)sharedInstance
{
    static CloudDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CloudDataManager alloc] init];
        [sharedInstance setup];
    });
    return sharedInstance;
}

- (void)setup
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi ||
            status == AFNetworkReachabilityStatusReachableViaWWAN)
        {
            // TEST
            [self downloadOpportunitiesWithDataOnSuccess:^(NSDictionary *opportunitiesDictionary) {
                NSLog(@"Successfully downloaded opportunities");
                [[OpportunityDataManager sharedInstance] createOpportunitiesWithData:opportunitiesDictionary];
            }];
            
            [self downloadActionsWithDataOnSuccess:^(NSDictionary *actionsDictionary) {
                [[OpportunityDataManager sharedInstance] createActionsWithData:actionsDictionary];
            }];
            
            [self downloadEmailActionsWithDataOnSuccess:^(NSDictionary *actionsDictionary) {
                [[OpportunityDataManager sharedInstance] createEmailActionsWithData:actionsDictionary];
            }];
            
            [self downloadPhoneActionsWithDataOnSuccess:^(NSDictionary *actionsDictionary) {
                [[OpportunityDataManager sharedInstance] createPhoneActionsWithData:actionsDictionary];
            }];
            
//            [self syncCache];
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

}

- (AFHTTPSessionManager*)newSessionManager
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:KUMULOS_API_KEY forHTTPHeaderField:@"Username"];
    [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:KUMULOS_API_KEY password:@"password"];
//    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//    policy.allowInvalidCertificates = YES;
//    [policy setValidatesDomainName:NO];
//    manager.securityPolicy = policy;
    
    return manager;
}

//- (void)downloadRouteWithUID:(NSString*)routeUID onSuccess:(void (^)(NSDictionary *))downloadedRoute onFailure:(void (^)(NSError *))failure
//{
////    q={"filters": [{"name":"agency_id","op":"==","val":"SFMTA"},{"name":"route_id","op":"==","val":"1038"}]}
//    
//    AFHTTPSessionManager *manager = [self newSessionManager];
//    NSString *q = [NSString stringWithFormat:@"{\"filters\": [{\"name\":\"agency_id\",\"op\":\"==\",\"val\":\"%@\"},{\"name\":\"route_id\",\"op\":\"==\",\"val\":\"%@\"}]}", [Utilities agencyIDfromRouteUID:routeUID], [Utilities routeIDfromRouteUID:routeUID]];
//    
//    NSDictionary *params;
//    params = @{@"q": q};
//    
////    NSLog(@"downloadRouteWithUID params = %@", params.description);
//    
//    [manager GET:URL_route parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSArray *routes = ((NSDictionary*)responseObject)[@"objects"];
//        
////        NSLog(@"Downloaded %li routes for downloadRouteWithUID %@", routes.count, routeUID);
//        
//        if (routes.count>0)
//        {
//            for (NSDictionary *route in routes)
//            {
//                if ([route[@"route_id"] isEqualToString:[Utilities routeIDfromRouteUID:routeUID]])
//                {
//                    downloadedRoute(route);
//                    break;
//                }
//            }
//        }
//        else
//            failure([NSError errorWithDomain:@"No route found" code:0 userInfo:nil]);
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error: %@", error);
//        failure(error);
//    }];
//
//    
//}

//- (void)downloadLogosForAgencies:(NSArray *)agencies
//{
//    for (GTFSAgency *agency in agencies)
//    {
//        __block NSString *agencyID = agency.agency_id;
//        
//        NSURL *url = [[TransitDataManager sharedInstance] logoURLforAgencyWithID:(agencyID)];
//        
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:url];
//        
//        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//            NSLog(@"File downloaded to: %@", filePath);
//            
//            [[TransitDataManager sharedInstance] storeLogoFilePath:filePath forAgencyWithID:agencyID];
//        }];
//        [downloadTask resume];
//    }
//}

//- (void)reportsForRouteWithUID:(NSString *)routeUID withPage:(NSInteger)page onSuccess:(void (^)(NSArray *))success onFailure:(void (^)(NSError *))failure
//{
// 
//    AFHTTPSessionManager *manager = [self newSessionManager];
//    
//    NSString *timestamp = [Utilities dateStringForTodayMidnight];
//    
//    NSString *q = [NSString stringWithFormat:@"{\"order_by\":[{\"field\": \"created_at\", \"direction\": \"desc\"}], \"filters\": [{\"name\":\"agency_id\",\"op\":\"==\",\"val\":\"%@\"},{\"name\":\"route_id\",\"op\":\"==\",\"val\":\"%@\"},{\"name\":\"created_at\",\"op\":\">\",\"val\":\"%@\"}]}", [Utilities agencyIDfromRouteUID:routeUID], [Utilities routeIDfromRouteUID:routeUID], timestamp];
//    
//    NSDictionary *params;
//    if (page>1)
//        params = @{@"page" : [NSNumber numberWithInteger:page], @"q": q};
//   else
//       params = @{@"q": q};
//    
//    [manager GET:URL_report parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSDictionary *reports = ((NSDictionary*)responseObject)[@"objects"];
//        NSMutableArray *sentiments = [NSMutableArray arrayWithCapacity:reports.count];
////        NSLog(@"Downloaded %lu reports", (unsigned long)reports.count);
//        if (reports.count>0)
//        {
//            for (NSDictionary *report in reports)
//            {
////                NSLog(@"Downloaded report: %@", report.description);
//                
////                NSLog(@"Downloading report with id %@ sentiment %i, latitude %f, longitude %f", report[@"id"], ((NSNumber*)report[@"sentiment"]).intValue, ((NSNumber*)report[@"latitude"]).floatValue, ((NSNumber*)report[@"longitude"]).floatValue);
////
//                if ([report[@"sentiment"] isKindOfClass:[NSNumber class]] &&
//                    [report[@"latitude"] isKindOfClass:[NSNumber class]] &&
//                    [report[@"longitude"] isKindOfClass:[NSNumber class]] &&
//                    [report[@"reason"] isKindOfClass:[NSNumber class]])
//                {
//                    NSNumber *sentiment = report[@"sentiment"];
//                    NSNumber *reason = report[@"reason"];
//                    NSNumber *latitude = report[@"latitude"];
//                    NSNumber *longitude = report[@"longitude"];
//                    
//                    // check for bad values
//                    if (sentiment.integerValue>4)
//                        sentiment = [NSNumber numberWithInt:EMPTY_EMOJI_i];
//                    if (reason.integerValue>11)
//                        reason = [NSNumber numberWithInt:EMPTY_CAUSE_i];
//                    
//                    [sentiments addObject:@[sentiment, reason, latitude, longitude, report[@"id"]]];
//                }
//             
//            }
//
//            success(sentiments);
//        }
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error: %@", error);
//        [CrashlyticsKit recordError:error];
//        failure(error);
//    }];
//    
//
//}

//- (void)postUDID
//{
//    AFHTTPSessionManager *manager = [self newSessionManager];
//    
////    NSLog(@"Posting UDID: %@", [Utilities UDID]);
//    
//    [manager POST:URL_rider parameters:@{@"id" : [Utilities UDID]} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"Successfully posted ID for rider");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Failed to post ID for rider, with error %@", error.description);
//    }];
//}

- (void)downloadOpportunitiesWithDataOnSuccess:(void (^)(NSDictionary* opportunitiesDictionary))success
{
    AFHTTPSessionManager *manager = [self newSessionManager];
    
    NSString *route = [NSString stringWithFormat:@"%@%@", URL_base, URL_opportunity];
    
    [manager GET: route parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to download opportunities from server with error %@", error.description);
    }];
}

- (void)downloadActionsWithDataOnSuccess:(void (^)(NSDictionary* actionsDictionary))success
{
    AFHTTPSessionManager *manager = [self newSessionManager];
    
    NSString *route = [NSString stringWithFormat:@"%@%@", URL_base, URL_action];
    
    [manager GET: route parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to download opportunities from server with error %@", error.description);
    }];
}


- (void)downloadPhoneActionsWithDataOnSuccess:(void (^)(NSDictionary* actionsDictionary))success
{
    AFHTTPSessionManager *manager = [self newSessionManager];
    
    NSString *route = [NSString stringWithFormat:@"%@%@", URL_base, URL_phone_action];
    
    [manager GET: route parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to download opportunities from server with error %@", error.description);
    }];
}

- (void)downloadEmailActionsWithDataOnSuccess:(void (^)(NSDictionary* actionsDictionary))success
{
    AFHTTPSessionManager *manager = [self newSessionManager];
    
    NSString *route = [NSString stringWithFormat:@"%@%@", URL_base, URL_email_action];
    
    [manager GET: route parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Failed to download opportunities from server with error %@", error.description);
    }];
}



//- (void)downloadAllAgenciesFromServerWithDataOnSuccess:(void (^)(NSDictionary* agenciesDictionary))success  onFailure:(void (^)(NSError *))failure
//{
//    AFHTTPSessionManager *manager = [self newSessionManager];
//    
//    [manager GET: URL_agencies parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        success(responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"Failed to update routes from server with error %@", error.description);
//        failure(error);
//    }];
//}





//- (void)syncMostRecentReport
//{
//    Report *report = [[TransitDataManager sharedInstance] mostRecentReport];
//    
//    [self syncReport:report];
//}
//
//- (void)addEmailToMailingList:(NSString *)email
//{
//    AFHTTPSessionManager *manager = [self newSessionManager];
//    
//    NSDictionary *params = @{@"id" : [Utilities UDID], @"email" : email };
//    
//    NSString *url = [NSString stringWithFormat:@"%@/%@", URL_rider,[Utilities UDID]];
//    
//    [manager PATCH:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"Successfully posted e-mail to mailing list");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//         NSLog(@"Failed to post e-mail to mailing list, with error %@", error.description);
//        [CrashlyticsKit recordError:error];
//    }];
//}

@end
