//
//  DirectionsViewController.h
//  CoffeeFinder
//
//  Created by Caleb Talbot on 5/18/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoffeeShop.h"


@interface DirectionsViewController : UIViewController
@property CoffeeShop *coffeeShop;
@property CLLocation *userLocation;
@end
