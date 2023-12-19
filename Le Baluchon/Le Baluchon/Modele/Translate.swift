//
//  Translate.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 28/11/2023.
//

import Foundation

// MARK: - TranslationResponse
struct TranslationResponse: Decodable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Decodable {
    let translations: [Translation]
}

// MARK: - Translation
struct Translation: Decodable {
    let translatedText : String
    let detectedSourceLanguage: String
    
    private enum CodingKeys: String, CodingKey {
        case translatedText
        case detectedSourceLanguage = "detectedSourceLanguage"
    }
}

final class Translate {
    private let session: URLSession
    private var task: URLSessionTask?
    let baseUrl = URL(string: "https://translation.googleapis.com/language/translate/v2")
    let appId = "AIzaSyBxP_uQJ3Kz34MPNo2LiDr2AEmk6PkS4PA"
    let format = "text"
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.session = session
    }
    
    func getTranslate(firstLanguage: String, secondLanguage: String, text: String, completion: @escaping (Result<TranslationResponse, NetworkingError>) -> Void) {
        guard var urlComponents = URLComponents(url: baseUrl!, resolvingAgainstBaseURL: false) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: appId),
            URLQueryItem(name: "target", value: secondLanguage),
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "format", value: format)
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
