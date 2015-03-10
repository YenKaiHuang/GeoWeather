//
//  ViewController.m
//  GeoGetWeather
//
//  Created by yenkai huang on 2014/9/25.
//  Copyright (c) 2014年 yenkai huang. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self startUpdataLocation];
}

- (void) startUpdataLocation{
    NSLog(@"startUpdataLocation");
    if (locationManager == nil){
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500; // meters
    
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSLog(@"latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
    
    GeoWeather* geoWeather = [[GeoWeather alloc] init];
    geoWeather.delegate = self;
    [geoWeather getAddrWithLat:location.coordinate.latitude lng:location.coordinate.longitude];
    
    [manager stopUpdatingLocation];
    
}

#pragma mark - GeoWeather Delegate

- (void)geoWeatherDidGetCity:(GeoWeather *)geoWeather city:(NSMutableDictionary *)city{
    NSLog(@"city = %@", city);
    [geoWeather getYahooWoeidWithCity:city];
}

- (void)geoWeatherDidGetWoeid:(GeoWeather *)geoWeather woeid:(NSString *)woeid{
    NSLog(@"woeid = %@", woeid);
    [geoWeather getYahooWeatherWithWoeid:woeid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
