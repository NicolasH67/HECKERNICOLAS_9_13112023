//
//  ExchangeResponse.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 17/01/2024.
//

import Foundation

struct ExchangeResponse: Decodable {
    let timestamp: Int
    let rates: [String: Double]
}
