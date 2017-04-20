//
//  Utilities.m


#import "Utilities.h"

#define ud_dataDownloadDate @"dataDownloadDate"
#define ud_uuid @"uuid"
#define ud_udid @"udid"
#define ud_latitude @"latitude"
#define ud_longitude @"longitude"
#define ud_launchCount @"launchCount"
#define ud_sharePromptShown @"sharePromptShown"
#define c_secondsInOneDay 86400

@implementation Utilities

+(NSString*)routeIDfromRouteUID:(NSString *)routeUID
{
    NSArray *substrings = [routeUID componentsSeparatedByString:@"_"];
    return substrings[1];
}

+(NSString*)agencyIDfromRouteUID:(NSString *)routeUID
{
    NSArray *substrings = [routeUID componentsSeparatedByString:@"_"];
    return substrings[0];
}

+(float) randFloatBetween:(float)low and:(float)high
{
    float diff = high - low;
    return (((float) rand() / RAND_MAX) * diff) + low;
}

+(NSDate*)dateForTodayMidnight
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *allComponents =
    [gregorian components:(NSCalendarUnitDay |
                           NSCalendarUnitHour |
                           NSCalendarUnitMinute |
                           NSCalendarUnitYear |
                           NSCalendarUnitMonth |
                           NSCalendarUnitSecond ) fromDate:today];
    NSInteger year = [allComponents year];
    NSInteger month = [allComponents month];
    NSInteger day = [allComponents day];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    [comps setHour:0];
    [comps setMinute:1];
    [comps setSecond:0];
    
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

+(NSDate*)dateFromUTCString:(NSString*)utcString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'+'HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate *date = [dateFormatter dateFromString:utcString];
    
    return date;
}

+ (NSString*)criticalityFromIndex:(NSInteger)index
{
    switch (index) {
        case 1:
            return @"Important issue";
            break;
        case 2:
            return @"Critical issue";
            break;
        case 3:
            return @"Burning issue";
            
        default:
            return @"Important issue";
            break;
    }
}

+ (NSString*)easeFromIndex:(NSInteger)index
{
    switch (index) {
        case 1:
            return @"Easy action";
            break;
        case 2:
            return @"More effort";
            break;
        case 3:
            return @"Serious activism";
            
        default:
            return @"Easy action";
            break;
    }
}

+(NSString*)dateStringForTodayMidnight
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *allComponents =
    [gregorian components:(NSCalendarUnitDay |
                           NSCalendarUnitHour |
                           NSCalendarUnitMinute |
                           NSCalendarUnitYear |
                           NSCalendarUnitMonth |
                           NSCalendarUnitSecond ) fromDate:today];
    NSInteger year = [allComponents year];
    NSInteger month = [allComponents month];
    NSInteger day = [allComponents day];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    [comps setHour:0];
    [comps setMinute:1];
    [comps setSecond:0];
    
    return [dateFormatter stringFromDate: [[NSCalendar currentCalendar] dateFromComponents:comps]];
}

+ (NSString*)UDID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ud_udid];
}

+ (void)createNewUDID
{
    [[NSUserDefaults standardUserDefaults] setObject:[[UIDevice currentDevice] identifierForVendor].UUIDString forKey:ud_udid];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)sharePromptShown
{
    BOOL shown = [[NSUserDefaults standardUserDefaults] boolForKey:ud_sharePromptShown];
    if (!shown)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ud_sharePromptShown];
        return NO;
    }
    return YES;
}

+(NSInteger)launchCount
{
    NSInteger launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:ud_launchCount];
    return launchCount;
}

+ (void)incrementLaunchCount
{
    NSInteger launchCount = [Utilities launchCount];
    launchCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:ud_launchCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setUserLocation:(CLLocation*)location
{
    [[NSUserDefaults standardUserDefaults] setFloat:location.coordinate.latitude forKey:ud_latitude];
    [[NSUserDefaults standardUserDefaults] setFloat:location.coordinate.longitude forKey:ud_longitude];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(CLLocation*)lastUserLocation
{
    float latitude = [[NSUserDefaults standardUserDefaults] floatForKey:ud_latitude];
    float longitude = [[NSUserDefaults standardUserDefaults] floatForKey:ud_longitude];
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

+ (NSNumber*)randomNumberWithMin:(NSInteger)min max:(NSInteger)max
{
    if (min>max) {
        NSInteger tempMax=max;
        max=min;
        min=tempMax;
    }
    NSInteger randomy=arc4random() % (max-min+1);
    randomy=randomy+min;
    return @(randomy);
}

+ (NSInteger)randomIntegerWithMin:(NSInteger)min max:(NSInteger)max
{
    return [[self randomNumberWithMin:min max:max] integerValue];
}

+ (BOOL)randomBoolean
{
    return [self randomIntegerWithMin:0 max:1] == 0;
}
+(CGSize)sizeAspectFitForRatio:(CGSize)aspectRatio toBoundingSize:(CGSize)boundingSize
{
    float mW = boundingSize.width / aspectRatio.width;
    float mH = boundingSize.height / aspectRatio.height;
    if( mH < mW )
        boundingSize.width = mH * aspectRatio.width;
    else if( mW < mH )
        boundingSize.height = mW * aspectRatio.height;
    return boundingSize;
}

+(NSString*)getUUID
{
    NSString *currentUUID = [[NSUserDefaults standardUserDefaults] stringForKey:ud_uuid];
    if (!currentUUID)
    {
        currentUUID = [[NSUUID UUID] UUIDString];
    }
    return currentUUID;
}

+(void)recordDataDownload
{
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:ud_dataDownloadDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)shouldRefreshData
{
    NSDate *lastRefreshed = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:ud_dataDownloadDate];
    
    if (lastRefreshed)
    {
        NSDate *today = [NSDate date];
        
        return ([today timeIntervalSinceDate:lastRefreshed] > c_secondsInOneDay);
        
    }
    return YES;
}

+ (UIImage*)imageWithAlpha:(float)alpha fromImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)placeImageOne:(UIImage*)imageOne sideBySideWithImageTwo:(UIImage*)imageTwo
{
    UIImage *newImage;
    
    CGRect rect = CGRectMake(0, 0, (imageOne.size.width*2)+10.0, imageOne.size.height);
    
    // Begin context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    // draw images
    [imageOne drawInRect:rect];
    [imageTwo drawInRect:rect];
    
    // grab context
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end context
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)convertImageToGrayScale:(UIImage *)image {
    
    
    float scaleFactor = [[UIScreen mainScreen] scale];
    
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width*scaleFactor, image.size.height*scaleFactor);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width*scaleFactor, image.size.height*scaleFactor, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    // make a new alpha-only graphics context
    context = CGBitmapContextCreate(nil, image.size.width*scaleFactor, image.size.height*scaleFactor, 8, 0, nil, kCGImageAlphaOnly);
    
    // draw image into context with no colorspace
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // create alpha bitmap mask from current context
    CGImageRef mask = CGBitmapContextCreateImage(context);
    
    // release graphics context
    CGContextRelease(context);
    
    // make UIImage from grayscale image with alpha mask
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale*scaleFactor orientation:image.imageOrientation];
    
    // release the CG images
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    // return the new grayscale image
    return grayScaleImage;
}

@end
