//
//  MainCollectionViewCell.h
//  PozWeather
//
//  Created by Grzegorz Jurzak on 16/09/15.
//  Copyright (c) 2015 Grzegorz Jurzak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"

@interface MainCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet RemoteImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
