//
//  TemperatureGraphController.m
//  sinoptik.ua
//
//  Created by shdwprince on 2/22/16.
//  Copyright © 2016 shdwprince. All rights reserved.
//

#import "GraphController.h"

@interface GraphController ()
@property NSDateFormatter *formatter;
@property NSDateFormatter *captionFormatter;
@end @implementation GraphController

- (instancetype) init {
    self = [super init];
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"dd-MM-y";
    self.captionFormatter = [NSDateFormatter new];
    self.captionFormatter.dateFormat = @"E";
    return self;
}

- (NSArray *) temperatureGraphDataFor:(Forecast *) cast {
    int currentDayIdx = 0;
    float minTemp = MAXFLOAT, maxTemp = MAXFLOAT;
    NSMutableArray *tempValues = [NSMutableArray new];
    NSMutableArray *plottingXTitles = [NSMutableArray new];
    for (int i = 0; i < cast.dates.count; i++) {
        NSDate *d = cast.dates[i];
        
        DailyForecast *day = [cast dailyForecastFor:d];
        HourlyForecast *hour = day.middayForecast;

        NSString *dayTitle = [self.captionFormatter stringFromDate:d];
        NSNumber *key = [NSNumber numberWithInt:i];

        [plottingXTitles addObject:@{key: dayTitle}];
        [tempValues addObject:@(hour.temperature)];
        
        if (minTemp == MAXFLOAT || minTemp > hour.temperature) {
            minTemp = hour.temperature;
        }
        
        if (maxTemp == MAXFLOAT || maxTemp < hour.temperature) {
            maxTemp = hour.temperature;
        }
        
        if ([[self.formatter stringFromDate:[NSDate new]] isEqualToString:[self.formatter stringFromDate:d]]) {
            currentDayIdx = i;
        }
    }
    
    float range;
    int zeroPresent;
    
    if (minTemp > 0) {
        zeroPresent = 1;
        range = maxTemp;
    } else if (maxTemp < 0) {
        zeroPresent = -1;
        range = (float) abs((int) minTemp);
    } else {
        zeroPresent = 0;
        range = (float) MAX(maxTemp, abs((int) minTemp)) * 2;
    }
    range -= 2;

    NSMutableArray *plottingValues = [NSMutableArray new];
    for (int i = 0; i < tempValues.count; i++) {
        NSNumber *value = tempValues[i];
        NSNumber *key = [NSNumber numberWithInt:i];
        float range_add = 0;
        switch (zeroPresent) {
            case -1:
                range_add = range;
                break;
            case 0:
                range_add = range/2;
                break;
            case 1:
                range_add = 0;
                break;
        }
        
        float floatValue = value.floatValue + range_add;
        [plottingValues addObject:@{key: [NSNumber numberWithFloat:floatValue]}];
    }
    
    return @[@(range), @"℃", plottingXTitles, plottingValues, @(currentDayIdx), @(zeroPresent), ];
}

- (NSArray *) windGraphDataFor:(Forecast *) cast {
    int currentDayIdx = 0;

    float range = 0;
    NSMutableArray *plottingValues = [NSMutableArray new];
    NSMutableArray *plottingXTitles = [NSMutableArray new];
    for (int i = 0; i < cast.dates.count; i++) {
        NSDate *d = cast.dates[i];
        
        DailyForecast *day = [cast dailyForecastFor:d];
        HourlyForecast *hour = day.middayForecast;

        NSString *dayTitle = [self.captionFormatter stringFromDate:d];
        NSNumber *key = [NSNumber numberWithInt:i];

        [plottingXTitles addObject:@{key: dayTitle}];
        [plottingValues addObject:@{key: @(hour.wind_speed)}];

        if (range < hour.wind_speed) {
            range = hour.wind_speed;
        }

        if ([[self.formatter stringFromDate:[NSDate new]] isEqualToString:[self.formatter stringFromDate:d]]) {
            currentDayIdx = i;
        }
    }

    return @[@(range), @"ms", plottingXTitles, plottingValues, @(currentDayIdx), @(1), ];
}

@end