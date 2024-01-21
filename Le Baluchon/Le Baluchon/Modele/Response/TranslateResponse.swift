//
//  TranslateResponse.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 17/01/2024.
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
