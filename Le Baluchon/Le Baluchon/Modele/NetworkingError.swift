//
//  NetworkingError.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 21/11/2023.
//

import Foundation

enum NetworkingError: Error {
    case noData
    case invalidResponse
    case undecodableData
}
