//
//  WeatherEndpoint.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 21/01/2024.
//

import Foundation

enum WeatherEndpoint {
    case Weather(String, String)
    
    func build() -> URL {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        switch self {
        case let .Weather(lat, lon):
            components.queryItems = [
                URLQueryItem(name: "lat", value: lat),
                URLQueryItem(name: "lon", value: lon),
                URLQueryItem(name: "appid", value: "2711c007e62e5a93869bdb2a1f03155c"),
                URLQueryItem(name: "units", value: "metric")
            ]
        }
        
        return components.url!
    }
}
