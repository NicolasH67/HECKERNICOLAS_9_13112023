//
//  Translate.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 28/11/2023.
//

import Foundation

final class TranslateLoader {
    
    //MARK: - Properties
    
    private let session: URLSession
    private var task: URLSessionTask?
    
    //MARK: - Initializer
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
    /// Initiates a translation request to the server for the provided text and language parameters.
    ///
    /// - Parameters:
    ///   - firstLanguage: The language code of the original text.
    ///   - secondLanguage: The language code to which the text should be translated.
    ///   - text: The text to be translated.
    ///   - completion: A closure to be executed once the translation request is complete.
    ///                 The closure takes a `Result` enum with a `TranslationResponse` value on success or a `NetworkingError` on failure.
    ///
    /// - Note: This method uses the `TranslateEndpoint` to build the URL for the translation API.
    ///         It performs a data task to send the translation request, handles various scenarios,
    ///         and calls the completion handler with the result containing the translated text.
    ///
    /// - Important: The completion handler is always called on the main thread.
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
