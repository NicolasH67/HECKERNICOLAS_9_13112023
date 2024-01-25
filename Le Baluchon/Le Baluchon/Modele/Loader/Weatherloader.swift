//
//  Weather.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 22/11/2023.
//

import Foundation

final class Weatherloader {
    
    //MARK: - Properties
    
    private let session: URLSession
    private var task: URLSessionTask?
    
    //MARK: - Initializer
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
    /// Fetches weather data from the server based on the provided latitude and longitude coordinates.
    ///
    /// - Parameters:
    ///   - lat: The latitude coordinate for the location.
    ///   - lon: The longitude coordinate for the location.
    ///   - completion: A closure to be executed once the weather data retrieval is complete.
    ///                 The closure takes a `Result` enum with a `WeatherResponse` value on success or a `NetworkingError` on failure.
    ///
    /// - Note: This method uses the `WeatherEndpoint` to build the URL for the weather API.
    ///         It performs a data task to fetch weather data, handles various scenarios, and calls the completion handler with the result.
    ///
    /// - Important: The completion handler is always called on the main thread.
    func getWeather(lat: String, lon: String, completion: @escaping (Result<WeatherResponse, NetworkingError>) -> Void) {
        let url = WeatherEndpoint.Weather(lat, lon).build()

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
