//
//  User
//

#import "User.h"

@implementation User

+ (NSString *)primaryKey
{
    return @"uuid";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"uuid": [[NSUUID UUID] UUIDString]};
}

@end
