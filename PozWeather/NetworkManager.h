//
//  NetworkManager.h
//  PozWeather
//
//  Created by Grzegorz Jurzak on 16/09/15.
//  Copyright (c) 2015 Grzegorz Jurzak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import "City.h"

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedInstance;

@property (strong, nonatomic) RKManagedObjectStore *managedObjectStore;
@property (strong, nonatomic) RKObjectManager *objectManager;

- (void)configureObjectManager:(RKManagedObjectStore *)managedObjectStore;
-(void)getWeater:(void(^)(City *city))success failure:(void (^)(NSError *error))failure;

@end
