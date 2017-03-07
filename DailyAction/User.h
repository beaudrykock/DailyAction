//
// User
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Action.h"

@interface User : RLMObject

@property NSString *firstName;
@property NSString *lastName;
@property NSInteger userID;
@property RLMArray<Action *><Action> *actionsTaken;

// Insert code here to declare functionality of your managed object subclass

@end
