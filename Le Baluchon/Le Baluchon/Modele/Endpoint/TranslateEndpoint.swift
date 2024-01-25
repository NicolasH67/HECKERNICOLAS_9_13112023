//
//  TranslateEndpoint.swift
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
enum TranslateEndpoint {
    /// Case for translating text to a specified target language.
    case translate(String, String)
    
    /// Builds and returns a URL for the specified weather endpoint.
    ///
    /// - Returns: A URL object for the specified weather API endpoint.
    func build() -> URL {
        var components = URLComponents()
        
        components.scheme = "https"
        components.host = "translation.googleapis.com"
        components.path = "/language/translate/v2"
        switch self {
        case let .translate(target, text):
            components.queryItems = [
                URLQueryItem(name: "key", value: "AIzaSyBxP_uQJ3Kz34MPNo2LiDr2AEmk6PkS4PA"),
                URLQueryItem(name: "target", value: target),
                URLQueryItem(name: "q", value: text),
                URLQueryItem(name: "format", value: "text")
            ]
        }
        return components.url!
    }
}
