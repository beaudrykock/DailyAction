//
// User
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Action.h"

@interface User : RLMObject

@property NSString *firstName;
@property NSString *lastName;
@property NSString *uuid;
@property NSString *zipcode;
@property NSString *city;
@property NSString *locationSource; // either AUTO or MANUAL
@property RLMArray<Action *><Action> *actionsTaken;

// Insert code here to declare functionality of your managed object subclass

@end
