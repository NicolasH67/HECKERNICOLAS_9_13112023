//
//  Translate.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 28/11/2023.
//

import Foundation

final class TranslateLoader {
    private let session: URLSession
    private var task: URLSessionTask?
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
    func getTranslate(firstLanguage: String, secondLanguage: String, text: String, completion: @escaping (Result<TranslationResponse, NetworkingError>) -> Void) {
        let url = TranslateEndpoint.translate(secondLanguage, text).build()
        
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
                let translationResponse = try JSONDecoder().decode(TranslationResponse.self, from: data)
                completion(.success(translationResponse))
            } catch {
                print("Error decoding JSON: \(error)")
                completion(.failure(.undecodableData))
            }
        }
        task?.resume()
    }
}
