//
//  WeatherResponse.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 17/01/2024.
//

import Foundation

// MARK: - WeatherResponse
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
