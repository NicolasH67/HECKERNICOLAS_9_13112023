//
//  TranslateEndpoint.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 21/01/2024.
//

import Foundation

enum TranslateEndpoint {
    case translate(String, String)
    
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
        print(components.url!)
        return components.url!
    }
}
