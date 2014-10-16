//
//  ViewController.h
//  GeoGetWeather
//
//  Created by yenkai huang on 2014/9/25.
//  Copyright (c) 2014年 yenkai huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "GeoWeather.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate, GeoWeatherDelegate>{
    CLLocationManager *locationManager;
}


@end

