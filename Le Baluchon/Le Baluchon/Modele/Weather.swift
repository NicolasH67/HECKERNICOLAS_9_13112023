//
//  Weather.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 22/11/2023.
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

final class Weather {
    private let session: URLSession
    private var task: URLSessionTask?
    
    let baseUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather")
    let appid = "2711c007e62e5a93869bdb2a1f03155c"
    let units = "metric"
    
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
    func getWeather(lat: String, lon: String, completion: @escaping (Result<WeatherResponse, NetworkingError>) -> Void) {
        guard var urlComponents = URLComponents(url: baseUrl!, resolvingAgainstBaseURL: false) else {
                completion(.failure(.invalidResponse))
                return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: lat),
            URLQueryItem(name: "lon", value: lon),
            URLQueryItem(name: "appid", value: appid),
            URLQueryItem(name: "units", value: units)
        ]

        guard let url = urlComponents.url else {
            completion(.failure(.invalidResponse))
            return
        }

        task = session.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(.failure(.noData))
            return
        }

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            completion(.failure(.invalidResponse))
            return
        }

        do {
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            completion(.success(weatherResponse))
        } catch {
            completion(.failure(.undecodableData))
        }
    }

    task?.resume()
    }
}
