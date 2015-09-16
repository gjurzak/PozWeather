//
//  MainViewController.m
//  PozWeather
//
//  Created by Grzegorz Jurzak on 16/09/15.
//  Copyright (c) 2015 Grzegorz Jurzak. All rights reserved.
//

#import "MainViewController.h"
#import "MainCollectionViewCell.h"
#import "NetworkManager.h"
#import "Day.h"
#import "Weather.h"

static NSString * const iconURL = @"http://openweathermap.org/img/w/";

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fetchedResultsControllerMain.delegate = nil;
    self.fetchedResultsControllerMain = nil;
    [self.fetchedResultsControllerMain performFetch:nil];
    [self refreshButtonTap:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsControllerMain sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsControllerMain sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    Day *day  = [self.fetchedResultsControllerMain objectAtIndexPath:indexPath];
    
    [cell.temperatureLabel setText:[NSString stringWithFormat:@"%lu C", [day.day_temp integerValue]]];
    [cell.pressureLabel setText:[NSString stringWithFormat:@"%lu hPa", [day.day_pressure integerValue]]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [cell.dateLabel setText:[formatter stringFromDate:day.day_dt]];
    
    Weather *weather = [[day.weather allObjects] firstObject];
    cell.iconImage.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", iconURL, weather.weather_icon]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Adjust cell size for orientation
    return CGSizeMake(self.view.frame.size.width / 2, self.view.frame.size.width / 2);
}

#pragma mark - collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - buttons
- (IBAction)refreshButtonTap:(id)sender {
    [self.refreshButton setHidden:YES];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    [[NetworkManager sharedInstance] getWeater:^(City *city) {
        [self.cityLabel setText:[NSString stringWithFormat:@"%@, %@ - WEATHER", city.city_name, city.city_country]];
        [self.refreshButton setHidden:NO];
        [self.activityIndicator setHidden:YES];
        [self.activityIndicator stopAnimating];
    } failure:^(NSError *error) {
        [self.refreshButton setHidden:NO];
        [self.activityIndicator setHidden:YES];
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - fetch result controller
- (NSFetchedResultsController *)fetchedResultsControllerMain {
    if (_fetchedResultsControllerMain != nil) {
        return _fetchedResultsControllerMain;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Day" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"day_dt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    
    self.fetchedResultsControllerMain = theFetchedResultsController;
    self.fetchedResultsControllerMain.delegate = self;
    return _fetchedResultsControllerMain;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

#pragma mark - dealloc
-(void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView = nil;
    self.fetchedResultsControllerMain.delegate = nil;
    self.fetchedResultsControllerMain = nil;
}
@end
