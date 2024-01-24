//
//  Weather.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 22/11/2023.
//

import Foundation

final class Weatherloader {
    private let session: URLSession
    private var task: URLSessionTask?
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
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
