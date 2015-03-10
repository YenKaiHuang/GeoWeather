//
//  GeoWeather.h
//  GeoGetWeather
//
//  Created by yenkai huang on 2014/9/26.
//  Copyright (c) 2014年 yenkai huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "GData.h"

#define GoogleGeoToCityURL @"http://maps.googleapis.com/maps/api/geocode/xml?language=EN&latlng=%f,%f"
#define YahooGeoPlaceURL @"http://query.yahooapis.com/v1/public/yql?q=select+*+from+geo.places+where+text+=\'%@\'"
#define YahooWetherURL @"http://weather.yahooapis.com/forecastrss?u=c&w=%@"

@protocol GeoWeatherDelegate;

@interface GeoWeather : NSObject


@property (nonatomic, strong) id<GeoWeatherDelegate>delegate;
@property (nonatomic, strong) NSMutableDictionary *city;
@property (nonatomic, strong) NSString *woeid;


/**
 * @brief get Address With Latitude and longitude
 * @param lat (float)Latitude of location
 * @param lng (float)longitude of location
 */
- (void) getAddrWithLat:(float)lat lng:(float)lng;

/**
 * @brief get YahooWoeid With City
 * @param city (NSString *)city
 */
- (void) getYahooWoeidWithCity:(NSMutableDictionary *)city;

/**
 * @brief get Yahoo Weather With Woeid
 * @param woeid (NSString *)YahooWoeid
 */
- (void) getYahooWeatherWithWoeid:(NSString *)woeid;

@end



@protocol GeoWeatherDelegate

@optional

/**
 * @brief geoWeather get city finished delegate
 * @param geoWeather (GeoWeather *)geoWeather object
 * @param city (NSString *)city
 */
- (void) geoWeatherDidGetCity:(GeoWeather *)geoWeather city:(NSMutableDictionary *)city;

/**
 * @brief geoWeather get Woeid finished delegate
 * @param geoWeather (GeoWeather *)geoWeather object
 * @param woeid (NSString *)woeid
 */
- (void) geoWeatherDidGetWoeid:(GeoWeather *)geoWeather woeid:(NSString *)woeid;

/**
 * @brief geoWeather get Weather finished delegate
 * @param geoWeather (GeoWeather *)geoWeather object
 * @param weatherDictionary (NSDictionary *)weatherDictionary
 */
- (void) geoWeatherDidGetWeather:(GeoWeather *)geoWeather weatherDictionary:(NSDictionary *)weatherDictionary;

@end

