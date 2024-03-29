//
//  ForecastManager.h
//  
//
//  Created by shdwprince on 9/8/15.
//
//

#import <Foundation/Foundation.h>
#import "SinoptikAPI.h"

@class ForecastManager;

@protocol ForecastManagerDelegate <NSObject>
- (void) forecastManager:(ForecastManager *) manager didReceivedForecast:(Forecast *) cast for:(NSArray *) place;
- (void) forecastManager:(ForecastManager *) manager didMadeProgress:(NSUInteger) from to:(NSUInteger) to for:(NSArray *) place;

@end

@interface ForecastManager : NSObject
@property NSUInteger behindDays, forwardDays;

- (instancetype) initWithDelegate:(id<ForecastManagerDelegate>) delegate;
- (void) requestForecastFor:(NSArray *) key;

@end
