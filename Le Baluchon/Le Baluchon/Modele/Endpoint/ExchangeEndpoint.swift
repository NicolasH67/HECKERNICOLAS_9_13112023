//
//  ExchangeEndpoint.swift
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
enum ExchangeEndpoint {
    
    /// Case for fetching the latest exchange rates. Is dont use for the moment
    case Exchange(String)
    
    /// Builds and returns a URL for the specified weather endpoint.
    ///
    /// - Returns: A URL object for the specified weather API endpoint.
    func build() -> URL {
        var components = URLComponents()
        
        components.scheme = "http"
        components.host = "data.fixer.io"
        components.path = "/api/latest"
        components.queryItems = [
            URLQueryItem(name: "access_key", value: "5f1d6629fff55e08eb516d98945c39ed"),
        ]
        return components.url!
    }
}
