//
//  DBManager.h
//  PozWeather
//
//  Created by Grzegorz Jurzak on 16/09/15.
//  Copyright (c) 2015 Grzegorz Jurzak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <CoreData/CoreData.h>

@interface DBManager : NSObject

+ (DBManager *)sharedInstance;
- (void)dataBaseConfiguration;

@end
