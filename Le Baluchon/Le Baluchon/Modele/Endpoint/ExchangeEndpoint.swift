//
//  ExchangeEndpoint.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 21/01/2024.
//

import Foundation

enum ExchangeEndpoint {
    case Exchange(String)
    
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
