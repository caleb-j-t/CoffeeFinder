//
//  ViewController.m
//  CoffeeFinder
//
//  Created by Caleb Talbot on 5/18/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

#import "ViewController.h"
#import "CoffeeShop.h"
#import "DirectionsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@interface ViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property  CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property NSArray *coffeeShops;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    set the property locationManager to be a new CLLocationManager instance
    self.locationManager = [CLLocationManager new];
    
//    set the delegate of the locationManager to be the ViewController (which is self)
    self.locationManager.delegate = self;
    
//    request authorization to use the location. can do requestAlwaysAuthorization or can request authorization when in use
//    also, in the plist, set Privacy - Location Usage Description and set the string to what I want the location request window to display when it pops up asking the use if they want to be able to use the location
    [self.locationManager requestAlwaysAuthorization];
    
//    this starts the location manager updating the location
    [self.locationManager startUpdatingLocation];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.coffeeShops.count;
};
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    /* -create an instance of a coffee shop that is the coffeeShop from the sorted array called coffeeShops and then pass in the objectAtIndex:indexPath.row so that it calls the item in the coffeeShops array for the given row in the tableView
     -then set the textLabel of the cell to the name of the coffeeShop (do this by using mapItem.name)
     -set the detailTextLabel (which is a secondary textLabel) to the distance... have to set it to an NSString that contains a stringWithFormat because the distance property is a float in miles
     -return a cell*/
    CoffeeShop *coffeeShop = [self.coffeeShops objectAtIndex:indexPath.row];
    cell.textLabel.text = coffeeShop.mapItem.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f miles away", coffeeShop.distance];
    return cell;
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    /* -set the userLocation property to the first location that is called when the app starts updating locations... the locations variable is an array that is created by the didUpdateLocations method
     -stopUpdatingLocation becasue we only one it to find the location the one time when we open the app
        - then, run the findCoffeePlaces custom method on the view controller and set the argument as self.userLocation to find places near the userLocation
     */
    self.userLocation = locations.lastObject;
    [self.locationManager stopUpdatingLocation];
    [self findCoffeePlaces:self.userLocation];

    
}

//the below custom method finds the 5 closest coffee places and returns the locations as an array of CLLocation objects named location

-(void) findCoffeePlaces:(CLLocation *) location {
/*   -create a new search
 -MKLocalSearchRequest is created an initialized with a natuarlLanguageQuery of "coffee" and a region to tell it where to search
 -the request.region needs to be set to narrow down the search location
 -MKCoordinateRequionMake creates a new MKCoordinateRegion from the specified coordinate and span values. */
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"coffee";
    request.region  = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.5, 0.5));
    
/*    -after we created the request, we'll create the actual search below and initWithRequest set to the request we created above 
 -we run the method startWithCompletionHandler on the search that we created ... You use this method to initiate a map-based search operation. The search runs until the results are delivered, at which point the specified completion handler is called
 -the array of mapItems we create is set to response.mapItems, which is an array of mapItems that is returned as an array called response by the startWithCompletionHandler method
 -then we iterate through the array with a for loop and return just the first 5 responses*/
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *mapItems = response.mapItems;
        NSMutableArray *tempArray = [NSMutableArray new];
        
            /* -the below for loop iterates through the mapItems array (which contains the mapItems in the response for the search -we create a new object called map item and use [mapItems objectAtIndex: i] to iterate through each item in the array until the for loop stops (at 5 items because it only runs while i is less than 5)
             - then we set a variable of type CLLocationDistance called distance that is equal to the distance that the user is from the location of the mapItem... mapItem.placemark references The placemark object containing the location information of the mapItem and .location gets the location object of that containing the latitude and longitude of the mapItem... we then run the distanceFromLocation message on that and pass it the userLocation,  which we set earlier as the first location pulled from the locationManager
             -then we convert the distance into miles with the division operand
             -create a class called CoffeeShop (file->new file->cocoa touch class->set type to NSObject->declare the properties of the class (here mapItem and distance)
             -create a new object of the custom CoffeeShop class called coffeeShop
             -set the properties of the coffeeShop object and add that object to the array we created called tempArray*/
        for (int i = 0; i < 5; i++){
            MKMapItem *mapItem = [mapItems objectAtIndex: i];
            CLLocationDistance distance =[mapItem.placemark.location distanceFromLocation:self.userLocation];
            float milesDistance = distance / 1609.34;
            CoffeeShop *coffeeShop = [CoffeeShop new];
            coffeeShop.mapItem = mapItem;
            coffeeShop.distance = milesDistance;
            [tempArray addObject:coffeeShop];
        };
        
        /* below we will sort the CoffeeShop objects in the array by distance from the user
         -creating an NSSortDescriptor object and initializing it with sortDescriptorWithKey creates and returns an NSSortDescriptor with the specified key and ordering
         -we create a new array called sortedArray that is the tempArray contain the coffee shops with the message sortedArrayUsingDescriptors, which returns a copy of the receiving array (here tempArray) sorted as specified by a given array of sort descriptors (which here we create an array with one object and add the sortDescriptor we created as the one item in the array)
         -we then create a new array called coffeeShopes and add a property to the interface so it's globally accessible and initialize that array by using arrayWithArray and pass in the sortedArray */
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:true];
        NSArray *sortedArray = [tempArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        self.coffeeShops = [NSArray arrayWithArray:sortedArray];
        for (CoffeeShop *coffeeShop in self.coffeeShops) {
            NSLog(@"%f", coffeeShop.distance);
        }
        [self.tableView reloadData];
    }];

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DirectionsViewController *dvc = segue.destinationViewController;
    dvc.coffeeShop = [self.coffeeShops objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    dvc.userLocation = self.userLocation;
}
@end
