//
// User
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Action.h"

@interface User : RLMObject

@property NSString *firstName;
@property NSString *lastName;
@property NSString *userID;
@property NSString *zipcode;
@property RLMArray<Action *><Action> *actionsTaken;

// Insert code here to declare functionality of your managed object subclass

@end
