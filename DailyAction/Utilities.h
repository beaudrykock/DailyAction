//
//  Utilities.h
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import <UIKit/UIKit.h>

@interface Utilities : NSObject

+ (UIImage*)imageWithAlpha: (float)alpha fromImage:(UIImage*)image;
+ (NSDate*)dateForTodayMidnight;
+ (NSString*)dateStringForTodayMidnight;
+ (NSDate*)dateFromUTCString:(NSString*)utcString;
+ (void)incrementLaunchCount;
+ (NSInteger)launchCount;
+ (void)recordDataDownload;
+ (BOOL)shouldRefreshData;
+ (NSString*)getUUID;
+ (CLLocation*)lastUserLocation;
+ (void)setUserLocation:(CLLocation*)location;
+ (BOOL)randomBoolean;
+ (NSNumber*)randomNumberWithMin:(NSInteger)min max:(NSInteger)max;
+ (BOOL)sharePromptShown;
+ (void)createNewUDID;
+ (NSString*)UDID;
+ (float) randFloatBetween:(float)low and:(float)high;
+ (CGSize) sizeAspectFitForRatio:(CGSize)aspectRatio toBoundingSize:(CGSize)boundingSize;
+ (UIImage *)convertImageToGrayScale:(UIImage *)image;
+ (UIImage *)placeImageOne:(UIImage*)imageOne sideBySideWithImageTwo:(UIImage*)imageTwo;
+ (NSString*)criticalityFromIndex:(NSInteger)index;
+ (NSString*)easeFromIndex:(NSInteger)index;

@end
