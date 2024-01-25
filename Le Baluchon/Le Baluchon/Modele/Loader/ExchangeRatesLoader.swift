//
//  ExchangeRatesLoader.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 16/11/2023.
//

import Foundation
    
final class ExchangeRatesLoader {
    
    //MARK: - Properties
    
    var delegate: ExchangeModelDelegate?
    var session: URLSession
    var task: URLSessionTask?
    
    //MARK: - Initializer
        
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
    /// Fetches the exchange rate from the server and provides the result through a completion handler.
    ///
    /// - Parameters:
    ///   - completion: A closure to be executed once the exchange rate retrieval is complete.
    ///                 The closure takes a `Result` enum with a `Double` value on success or a `NetworkingError` on failure.
    ///
    /// - Note: This method uses the `ExchangeEndpoint` to build the URL for the exchange rate API.
    ///         It cancels any existing task, performs a data task to fetch the exchange rate, and handles various scenarios.
    ///         The completion handler is then called with the result of the operation.
    ///
    /// - Important: The completion handler is always called on the main thread.
    func getExchange(completion: @escaping (Result<Double, NetworkingError>) -> Void) {
        let url = ExchangeEndpoint.Exchange("nil").build()
        
        task?.cancel()
        task = session.dataTask(with: url) { data, response, error in
            guard let data, error == nil else {
                completion(.failure(.noData))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            guard let exchange = try? JSONDecoder().decode(ExchangeResponse.self, from: data) else {
                completion(.failure(.undecodableData))
                return
            }
            completion(.success(exchange.rates["USD"]!))
        }
        task?.resume()
    }
    
    /// Updates the exchange value based on user input and notifies the delegate of the result.
    ///
    /// - Parameters:
    ///   - text: The user-entered text representing the value to be converted.
    ///   - tauxExchange: The current exchange rate.
    ///   - firstSetting: The user's selected currency setting.
    ///
    /// - Note: This method performs the conversion based on the user's input and the current exchange rate.
    ///         It then formats the result and notifies the delegate with the updated exchange value.
    func updateExchangeValue(withText text: String, tauxExchange: Double, firstSetting: String) {
        guard let exchangeDouble = Double(text) else {
            delegate?.didFailConversion()
            return
        }
        switch firstSetting {
        case "Euro":
            let newValue = exchangeDouble * tauxExchange
            let formattedValue = String(format: "%.2f", newValue)
            delegate?.didUpdateExchangeValue("\(formattedValue) $")
        case "Dollar":
            let newValue = exchangeDouble / tauxExchange
            let formattedValue = String(format: "%.2f", newValue)
            delegate?.didUpdateExchangeValue("\(formattedValue) €")
        default:
            let text = "error with setting"
            delegate?.didUpdateExchangeValue("\(text)")
            break
        }
    }
}
