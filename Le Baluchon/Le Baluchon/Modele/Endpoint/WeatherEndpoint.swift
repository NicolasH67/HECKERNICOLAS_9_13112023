//
//  WeatherEndpoint.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 21/01/2024.
//

import Foundation

/// Enum representing various endpoints for weather-related API requests.
///
/// This enum includes a case for fetching current weather based on latitude and longitude coordinates.
///
/// - Note: Ensure to call the `build()` method to obtain a valid URL for the specified endpoint.
enum WeatherEndpoint {
    
    /// Case for fetching current weather based on latitude and longitude coordinates.
    case Weather(String, String)
    
    /// Builds and returns a URL for the specified weather endpoint.
    ///
    /// - Returns: A URL object for the specified weather API endpoint.
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
                URLQueryItem(name: "appid", value: "YourPass"),
                URLQueryItem(name: "units", value: "metric")
            ]
        }
        
        return components.url!
    }
}
