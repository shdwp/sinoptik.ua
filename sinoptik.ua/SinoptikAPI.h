//
//  SinoptikAPI.h
//  
//
//  Created by shdwprince on 9/7/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SinoptikResponseParser.h"

typedef NSString *SinoptikImageSize;

#define SinoptikImageSizeBig @"b"
#define SinoptikImageSizeMedium @"m"
#define SinoptikImageSizeSmall @"s"

typedef NSString *SinoptikTime;

#define SinoptikTimeDay @"d"
#define SinoptikTimeNight @"n"

typedef void (^SinoptikAPIProgressCallback)(NSUInteger, NSUInteger);

@interface SinoptikAPI : NSObject

+ (instancetype) api;

- (NSArray *) searchPlaces:(NSString *) query;
- (Forecast *) forecastFor:(NSString *) key progressCallback:(SinoptikAPIProgressCallback) cb;
- (NSData *) imageForForecast:(HourlyForecast *) cast ofSize:(SinoptikImageSize) size time:(SinoptikTime) time;
- (NSString *) imageNameFor:(HourlyForecast *) cast ofSize:(SinoptikImageSize) size time:(SinoptikTime) time;

@end
