//
//  Forecast.m
//
//  Created by shdwprince on 9/8/15.
//
//

#import "Forecast.h"

#pragma mark - hourly forecast

@implementation HourlyForecast
@synthesize clouds, rain, temperature, pressure, humidity, wind_speed, rain_probability, hour, frost;

- (NSString *) description {
    return [NSString stringWithFormat:@"{%d, (rain: %d, clouds: %d), pressure %d, hum %d, wnd %@%f, prob. %d}",
            self.temperature,
            self.rain,
            self.clouds,
            self.pressure,
            self.humidity,
            self.wind_directions[self.wind_direction],
            self.wind_speed,
            self.rain_probability];
}

- (void) setWindDirection:(NSString *)wind_direction {
    self.wind_direction = [HourlyForecast.wind_directions indexOfObject:wind_direction];
}

+ (NSArray *) wind_directions {
    return @[@"N", @"NE", @"E", @"SE", @"S", @"SW", @"W", @"NW", @"Z"];
}

#pragma mark coding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.temperature = [aDecoder decodeIntForKey:@"temperature"];
    self.feelslikeTemperature = [aDecoder decodeIntForKey:@"feelslikeTemperature"];
    self.rain = [aDecoder decodeIntForKey:@"rain"];
    self.clouds = [aDecoder decodeIntForKey:@"clouds"];
    self.frost = [aDecoder decodeIntForKey:@"frost"];
    self.pressure = [aDecoder decodeIntForKey:@"pressure"];
    self.humidity = [aDecoder decodeIntForKey:@"humidity"];
    self.wind_speed = [aDecoder decodeFloatForKey:@"wind_speed"];
    self.wind_direction = [aDecoder decodeIntForKey:@"wind_direction"];
    self.rain_probability = [aDecoder decodeIntForKey:@"rain_probability"];
    self.hour = [aDecoder decodeIntForKey:@"hour"];

    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.temperature forKey:@"temperature"];
    [aCoder encodeInt:self.rain forKey:@"rain"];
    [aCoder encodeInt:self.clouds forKey:@"clouds"];
    [aCoder encodeInt:self.frost forKey:@"frost"];
    [aCoder encodeInt:self.pressure forKey:@"pressure"];
    [aCoder encodeInt:self.humidity forKey:@"humidity"];
    [aCoder encodeFloat:self.wind_speed forKey:@"wind_speed"];
    [aCoder encodeInt:self.wind_direction forKey:@"wind_direction"];
    [aCoder encodeInt:self.rain_probability forKey:@"rain_probability"];
    [aCoder encodeInt:self.hour forKey:@"hour"];
    [aCoder encodeInt:self.feelslikeTemperature forKey:@"feelslikeTemperature"];
}

@end

#pragma mark - daily forecast

@implementation DailyForecast
@synthesize hourlyForecast, daylight, summary, last_update;

- (NSString *) description {
    return [NSString stringWithFormat:@"%@\n    %@, (%@-%@), %d others",
            self.summary,
            [self.hourlyForecast.allValues.firstObject description],
            self.daylight.firstObject,
            self.daylight.lastObject,
            self.hourlyForecast.count];
}

- (NSArray *) hours {
    return [self.hourlyForecast.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

- (HourlyForecast *) middayForecast {
    NSArray *keys = self.hourlyForecast.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];

    NSObject *key = keys[(int) keys.count / 2];
    return self.hourlyForecast[key];
}

- (HourlyForecast *) morningForecast {
    return self.hourlyForecast[@8];
}

- (HourlyForecast *) dayForecast {
    return self.hourlyForecast[@14];
}

- (HourlyForecast *) nightForecast {
    return self.hourlyForecast[@2];
}

- (HourlyForecast *) forecastFor:(int)targetHour {
    NSNumber *minHour;
    int minDif = 24;
    for (NSNumber *hour in self.hours) {
        int dif;
        if ((dif = abs(hour.integerValue - targetHour)) < minDif) {
            minHour = hour;
            minDif = dif;
        }
    }

    return self.hourlyForecast[minHour];
}

- (NSNumber *) hourFor:(int) targetHour {
    NSNumber *minHour;
    int minDif = 24;
    for (NSNumber *hour in self.hours) {
        int dif;
        if ((dif = abs(targetHour - hour.integerValue)) < minDif) {
            minHour = hour;
            minDif = dif;
        }
    }

    return minHour;
}

- (instancetype) init {
    self = [super init];
    self.hourlyForecast = [NSMutableDictionary new];
    self.daylight = @[];
    self.minMax = @[];
    self.last_update = [NSDate date];
    return self;
}

#pragma mark coding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.hourlyForecast = [aDecoder decodeObject];
    self.daylight = [aDecoder decodeObject];
    self.summary = [aDecoder decodeObject];
    self.last_update = [aDecoder decodeObject];
    self.minMax = [aDecoder decodeObject];

    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.hourlyForecast];
    [aCoder encodeObject:self.daylight];
    [aCoder encodeObject:self.summary];
    [aCoder encodeObject:self.last_update];
    [aCoder encodeObject:self.minMax];
}
@end

#pragma mark - forecast

@interface Forecast ()
@property NSDateFormatter *formatter;
@end@implementation Forecast
@synthesize dailyForecasts;

- (instancetype) init {
    self = [super init];
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = @"yyyy-MM-dd";
    //self.formatter.timeZone = [NSTimeZone systemTimeZone];

    self.dailyForecasts = [NSMutableDictionary new];
    return self;
}

- (NSString *) description {
    NSArray *keys = [self.dailyForecasts.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];

    NSMutableString *buff = [NSMutableString stringWithFormat:@"%@: {\n", [super description]];
    for (NSDate *key in keys) {
        [buff appendFormat:@"  %@: %@\n", [self.formatter stringFromDate:key], self.dailyForecasts[key]];
    }

    return [buff stringByAppendingString:@"}"];
}

- (NSArray<NSDate *> *) dates {
    NSArray *keys = [self.dailyForecasts.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];

    return keys;
}

- (DailyForecast *) dailyForecastFor:(NSDate *)date {
    /*
    NSDate *normalizedDate = [self.formatter dateFromString:[self.formatter stringFromDate:date]];
    NSLog(@"got %@ turned %@", date, normalizedDate);
     */
    return self.dailyForecasts[date];
}

#pragma mark coding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.dailyForecasts = [aDecoder decodeObject];
    self.lastUpdate = [aDecoder decodeObject];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.dailyForecasts];
    [aCoder encodeObject:self.lastUpdate];
}

@end
