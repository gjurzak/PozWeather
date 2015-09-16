//
//  Weather.h
//  PozWeather
//
//  Created by Grzegorz Jurzak on 16/09/15.
//  Copyright (c) 2015 Grzegorz Jurzak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Weather : NSManagedObject

@property (nonatomic, retain) NSNumber * weather_id;
@property (nonatomic, retain) NSString * weather_main;
@property (nonatomic, retain) NSString * weather_description;
@property (nonatomic, retain) NSString * weather_icon;

@end
