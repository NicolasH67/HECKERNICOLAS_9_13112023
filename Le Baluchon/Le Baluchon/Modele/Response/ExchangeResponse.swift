//
//  ExchangeResponse.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 17/01/2024.
//

import Foundation

/// Represents the decoded response from the exchange rate API.
///
/// This structure conforms to the `Decodable` protocol and is used to model the data received
/// from the server when fetching the exchange rate. It includes the timestamp of the exchange rates
/// and a dictionary (`rates`) mapping currency codes to their corresponding exchange rates.
///
/// - Note: The structure assumes that the response includes a timestamp and a dictionary of currency rates.
struct ExchangeResponse: Decodable {
    let timestamp: Int
    let rates: [String: Double]
}
