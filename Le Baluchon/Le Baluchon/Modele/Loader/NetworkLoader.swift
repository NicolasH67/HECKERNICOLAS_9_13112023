//
//  NetworkLoader.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 21/01/2024.
//

import Foundation

struct NetworkLoader {
    var session: URLSession
    var task: URLSessionTask?
    mutating func fetchData<T: Decodable>(url: URL, completion: @escaping (Result<T, NetworkingError>) -> Void) {
        task?.cancel()
        
        task = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.undecodableData))
            }
        }
        
        task?.resume()
    }
}
