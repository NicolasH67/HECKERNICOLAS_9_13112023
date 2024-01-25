//
//  WeatherResponse.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 17/01/2024.
//

import Foundation

// MARK: - WeatherResponse

/// Represents the decoded response from the weather API, including details about the current weather conditions.
///
/// This structure conforms to the `Decodable` protocol and is used to model the data received
/// from the server when fetching weather information. It includes an array of `WeatherDetails` representing
/// various weather conditions, and a `Main` object providing key temperature and atmospheric details.
///
/// - Note: The structure assumes a specific JSON structure where weather details are represented by an array
///         (`weather`) and main temperature-related information is encapsulated in a `Main` object.
struct WeatherResponse: Decodable {
    let weather: [WeatherDetails]
    let main: Main
}

// MARK: - Main

struct Main: Decodable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Weather

struct WeatherDetails: Decodable {
    let id: Int
    let main, description, icon: String
}
