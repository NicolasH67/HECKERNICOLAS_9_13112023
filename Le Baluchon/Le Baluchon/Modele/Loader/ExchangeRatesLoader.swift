//
//  ExchangeRatesLoader.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 16/11/2023.
//

import Foundation
    
final class ExchangeRatesLoader {
    var delegate: ExchangeModelDelegate?
    var session: URLSession
    var task: URLSessionTask?
        
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
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
