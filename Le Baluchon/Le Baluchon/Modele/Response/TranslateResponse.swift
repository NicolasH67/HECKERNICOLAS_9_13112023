//
//  TranslateResponse.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 17/01/2024.
//

import Foundation

// MARK: - TranslationResponse

/// Represents the decoded response from the translation API, including translated text and language detection information.
///
/// This structure conforms to the `Decodable` protocol and models the data received from the server
/// when fetching translation information. It includes a `DataClass` object containing an array of `Translation` objects.
///
/// - Note: The structure assumes a specific JSON structure where translation details are encapsulated in a `DataClass` object.
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
