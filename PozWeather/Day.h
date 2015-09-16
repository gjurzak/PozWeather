//
//  Day.h
//  PozWeather
//
//  Created by Grzegorz Jurzak on 16/09/15.
//  Copyright (c) 2015 Grzegorz Jurzak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Weather;

@interface Day : NSManagedObject

@property (nonatomic, retain) NSDate * day_dt;
@property (nonatomic, retain) NSNumber * day_temp;
@property (nonatomic, retain) NSNumber * day_pressure;
@property (nonatomic, retain) NSSet *weather;
@end

@interface Day (CoreDataGeneratedAccessors)

- (void)addWeatherObject:(Weather *)value;
- (void)removeWeatherObject:(Weather *)value;
- (void)addWeather:(NSSet *)values;
- (void)removeWeather:(NSSet *)values;

@end
