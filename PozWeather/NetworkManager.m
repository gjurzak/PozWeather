//
//  NetworkManager.m
//  PozWeather
//
//  Created by Grzegorz Jurzak on 16/09/15.
//  Copyright (c) 2015 Grzegorz Jurzak. All rights reserved.
//

#import "NetworkManager.h"

static NSString * const baseURL = @"http://api.openweathermap.org";
static NSString * const cityURL = @"/data/2.5/forecast/daily";
static NSString * const apiKey = @"xxxxxxx-APIKEY-xxxxxxxxxx";

@implementation NetworkManager

+ (NetworkManager *)sharedInstance {
    static NetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)configureObjectManager:(RKManagedObjectStore *)managedObjectStore {
    
    if (!self.objectManager) {
        self.objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:baseURL]];
        self.objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
        self.objectManager.managedObjectStore = managedObjectStore;
        self.managedObjectStore = managedObjectStore;
        self.objectManager.HTTPClient.parameterEncoding = AFJSONParameterEncoding;
        
        [RKObjectManager setSharedManager: self.objectManager];
        
        [self configureMappingManager];
    }
    
}

- (void)configureMappingManager {
    RKEntityMapping *weatherMapping = [self weatherMapping];
    RKEntityMapping *dayMapping = [self dayMappingWithWeatherMapping:weatherMapping];
    [self cityMappingWithDayMapping:dayMapping];
}


- (RKEntityMapping *)weatherMapping {
    NSLog(@"weatherMapping");
    
    RKEntityMapping *weatherMapping = [RKEntityMapping mappingForEntityForName:@"Weather" inManagedObjectStore:self.managedObjectStore];
    [weatherMapping  addAttributeMappingsFromDictionary:@{
                                                      @"id":@"weather_id",
                                                      @"main":@"weather_main",
                                                      @"description":@"weather_description",
                                                      @"icon":@"weather_icon",
                                                      }];
    weatherMapping.identificationAttributes = @[ @"weather_id" ];
    
    [self.objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:cityURL];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Weather"];
            return fetchRequest;
        }
        return nil;
    }];

    
    return weatherMapping;
}

- (RKEntityMapping *)dayMappingWithWeatherMapping:(RKEntityMapping *)weatherMapping {
    NSLog(@"dayMapping");
    
    RKEntityMapping *dayMapping = [RKEntityMapping mappingForEntityForName:@"Day" inManagedObjectStore:self.managedObjectStore];
    [dayMapping  addAttributeMappingsFromDictionary:@{
                                                       @"dt":@"day_dt",
                                                       @"pressure":@"day_pressure",
                                                       @"temp.day":@"day_temp",
                                                       }];
    dayMapping.identificationAttributes = @[ @"day_dt" ];
    
    [dayMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"weather" toKeyPath:@"weather" withMapping:weatherMapping]];
    
    [self.objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:cityURL];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Day"];
            return fetchRequest;
        }
        return nil;
    }];

    
    return dayMapping;
}

- (void)cityMappingWithDayMapping:(RKEntityMapping *)dayMapping {
    NSLog(@"cityMapping");
    
    RKEntityMapping *cityMapping = [RKEntityMapping mappingForEntityForName:@"City" inManagedObjectStore:self.managedObjectStore];
    [cityMapping  addAttributeMappingsFromDictionary:@{
                                                    @"city.id":@"city_id",
                                                    @"city.name":@"city_name",
                                                    @"city.country":@"city_country",
                                                    }];
    cityMapping.identificationAttributes = @[ @"city_id" ];
    
    [cityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"days" withMapping:dayMapping]];
    
    RKResponseDescriptor *cityMappingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:cityMapping method:RKRequestMethodGET pathPattern:cityURL keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:cityMappingDescriptor];
    
    [self.objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:cityURL];
        NSDictionary *argsDict = nil;
        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"City"];
            return fetchRequest;
        }
        return nil;
    }];
}

-(void)getWeater:(void(^)(City *city))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@"Poznań,pl" forKey:@"q"];
    [params setObject:@"metric" forKey:@"units"];
    [params setObject:[NSNumber numberWithInteger:7] forKey:@"cnt"];
    [params setObject:apiKey forKey:@"APPID"];
    
    [[RKObjectManager sharedManager] getObject:nil path:cityURL parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:kNilOptions error:nil];
        NSLog(@"responseDictionary : %@",responseDictionary);
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        success([mappingResult firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error while getting respond: %@",operation.HTTPRequestOperation.responseString);
        failure(nil);
    }];
}



@end