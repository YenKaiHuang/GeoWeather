//
//  GeoWeather.m
//  GeoGetWeather
//
//  Created by yenkai huang on 2014/9/26.
//  Copyright (c) 2014年 yenkai huang. All rights reserved.
//

#import "GeoWeather.h"


@implementation GeoWeather{
    GDataXMLDocument *doc;
    GDataXMLElement *root;

    AFHTTPRequestOperationManager *manager;
    
    float currentLat;
    float currentLng;
    
    int cityIndex;
}

- (id) init{
    self = [super init];
    if (self) {
        manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [[AFXMLParserResponseSerializer alloc] init];
        self.city = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) getAddrWithLat:(float)lat lng:(float)lng{
    currentLat = lat;
    currentLng = lng;
    NSString *addrUrl = [NSString stringWithFormat:GoogleGeoToCityURL, lat, lng];
    addrUrl = [addrUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = @{};
    
    [manager POST:addrUrl
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSString *xmlString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
              NSArray *addressArray = [self getArrayFromXML:xmlString namespace:nil path:@"//GeocodeResponse/result/address_component"];
              NSArray *types;
              for (GDataXMLElement *addr in addressArray) {
                  types = [addr elementsForName:@"type"];
                  GDataXMLElement *type = (GDataXMLElement *) [types objectAtIndex:0];
                  if ([type.stringValue isEqualToString:@"administrative_area_level_4"]) {
                      GDataXMLElement *cityElement = [[addr elementsForName:@"long_name"] objectAtIndex:0];
                      [self.city setValue:cityElement.stringValue forKey:@"city4"];
                  } else if ([type.stringValue isEqualToString:@"administrative_area_level_3"]) {
                      GDataXMLElement *cityElement = [[addr elementsForName:@"long_name"] objectAtIndex:0];
                      [self.city setValue:cityElement.stringValue forKey:@"city3"];
                  }else if ([type.stringValue isEqualToString:@"administrative_area_level_2"]) {
                      GDataXMLElement *cityElement = [[addr elementsForName:@"long_name"] objectAtIndex:0];
                      [self.city setValue:cityElement.stringValue forKey:@"city2"];
                  }else if ([type.stringValue isEqualToString:@"administrative_area_level_1"]) {
                      GDataXMLElement *cityElement = [[addr elementsForName:@"long_name"] objectAtIndex:0];
                      [self.city setValue:cityElement.stringValue forKey:@"city1"];
                      cityIndex = 1;
                      [self.delegate geoWeatherDidGetCity:self city:self.city];
                      
                      break;
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
          }];
    
}

- (void) getYahooWoeidWithCity:(NSDictionary *)city{
    
    NSString *cityString = [city valueForKey:[NSString stringWithFormat:@"city%d", cityIndex]];
//    NSLog(@"cityString = %@", cityString);
    
    NSString *cityUrl = [NSString stringWithFormat:YahooGeoPlaceURL, cityString];
    cityUrl = [cityUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *parameters = @{};
    
    [manager POST:cityUrl
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSString *xmlString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
              NSArray *resultsArray = [self getArrayFromXML:xmlString namespace:nil path:@"//query/results"];
              for (GDataXMLElement *result in resultsArray) {
                  GDataXMLElement *placeElement = [[result elementsForName:@"place"] objectAtIndex:0];
                  GDataXMLElement *woeidElement = [[placeElement elementsForName:@"woeid"] objectAtIndex:0];
                  GDataXMLElement *centroidElement = [[placeElement elementsForName:@"centroid"] objectAtIndex:0];
                  GDataXMLElement *latElement = [[centroidElement elementsForName:@"latitude"] objectAtIndex:0];
                  GDataXMLElement *lngElement = [[centroidElement elementsForName:@"longitude"] objectAtIndex:0];
//                  NSLog(@"woeidElement = %@", woeidElement.stringValue);
//                  NSLog(@"latElement = %@", latElement.stringValue);
//                  NSLog(@"lngElement = %@", lngElement.stringValue);
                  if ((int)([latElement.stringValue doubleValue] - currentLat) == 0 && (int)([lngElement.stringValue doubleValue] - currentLng) == 0) {
                      self.woeid = woeidElement.stringValue;
                  }
                  break;
              }
              cityIndex ++;
              if (cityIndex < 5) {
                  [self getYahooWoeidWithCity:self.city];
              }else{
                  [self.delegate geoWeatherDidGetWoeid:self woeid:self.woeid];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
          }];
}

- (void) getYahooWeatherWithWoeid:(NSString *)woeid{
    NSString *weatherUrl = [NSString stringWithFormat:YahooWetherURL, woeid];
    weatherUrl = [weatherUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *connection = [[NSURL alloc] initWithString:[weatherUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [request setURL:connection];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *xmlString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"xmlString = %@", xmlString);
    
    
    NSArray *resultsArray = [self getArrayFromXML:xmlString namespace:nil path:@"//rss/channel"];
    NSLog(@"resultsArray = %@", resultsArray);
    for (GDataXMLElement *result in resultsArray) {
        GDataXMLElement *windElement = [[result elementsForName:@"yweather:wind"] objectAtIndex:0];
        NSLog(@"windElement = %@", windElement.attributes);
        GDataXMLElement *humidityElement = [[result elementsForName:@"yweather:atmosphere"] objectAtIndex:0];
        NSLog(@"humidityElement = %@", humidityElement.attributes);
        GDataXMLElement *itemElement = [[result elementsForName:@"item"] objectAtIndex:0];
        GDataXMLElement *conditionElement = [[itemElement elementsForName:@"yweather:condition"] objectAtIndex:0];
        NSLog(@"conditionElement = %@", conditionElement.attributes);
        break;
    }
    
    // todo: fixed error on AFHTTPRequestOperation
    
//    NSDictionary *parameters = @{};
//    
//    [manager POST:weatherUrl
//       parameters:parameters
//          success:^(AFHTTPRequestOperation *operation, id responseObject) {
//              NSString *xmlString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//              NSLog(@"xmlString = %@", xmlString);
//              NSArray *resultsArray = [self getArrayFromXML:xmlString namespace:nil path:@"//query/results"];
//              for (GDataXMLElement *result in resultsArray) {
//                  GDataXMLElement *placeElement = [[result elementsForName:@"place"] objectAtIndex:0];
//                  GDataXMLElement *woeidElement = [[placeElement elementsForName:@"woeid"] objectAtIndex:0];
//                  self.woeid = woeidElement.stringValue;
//                  [self.delegate geoWeatherDidGetWoeid:self woeid:self.woeid];
//                  break;
//              }
//          }
//          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              NSLog(@"error = %@", error);
//          }];
}

- (NSArray *) getArrayFromXML:(NSString *)xml namespace:(NSString *)namespace path:(NSString *)path
{
    doc = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
    NSArray *elementArray = [doc nodesForXPath:path error:nil];
    return elementArray;
}



@end
