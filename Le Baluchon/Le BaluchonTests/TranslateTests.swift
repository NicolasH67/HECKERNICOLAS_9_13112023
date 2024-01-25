//
//  TranslateTests.swift
//  Le BaluchonTests
//
//  Created by Nicolas Hecker on 06/01/2024.
//

import XCTest
@testable import Le_Baluchon


class MockTranslateURLProtocol: URLProtocol {
    static var mockResponseData: Data?
    static var mockError: Error?
    static var mockResponse: HTTPURLResponse?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let data = MockTranslateURLProtocol.mockResponseData {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = MockTranslateURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        }
        if let response = MockTranslateURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // Ne rien faire
    }
    
    static func resetMock() {
        MockTranslateURLProtocol.mockError = nil
        MockTranslateURLProtocol.mockResponse = nil
        MockTranslateURLProtocol.mockResponseData = nil
    }
}

final class TranslateTests: XCTestCase {
    private func makeSUT() -> (TranslateLoader) {
        MockTranslateURLProtocol.resetMock()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockTranslateURLProtocol.self]
        let sut = TranslateLoader(session: URLSession(configuration: config))
        return sut
    }
    
    func testGetTranslateSuccess() {
        let sut = makeSUT()
        
        let expectation = XCTestExpectation(description: "Appel API Translate")
        let mockResponseData = makeValideJSON()
        
        MockTranslateURLProtocol.mockResponseData = mockResponseData
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockTranslateURLProtocol.mockResponse = mockResponse
        
        sut.getTranslate(firstLanguage: "Test", secondLanguage: "Test", text: "Test") { result in
            switch result {
            case .success(let translationResponse):
                XCTAssertEqual(translationResponse.data.translations.first?.translatedText, "Test")
                XCTAssertEqual(translationResponse.data.translations.first?.detectedSourceLanguage, "fr")
            case .failure(let error):
                print("Error: \(error)")
                XCTFail("Succès attendu, échec obtenu. Error: \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGetExchangeUndecodableData() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "API Call - Exchange")
        
        let mockResponseData = "invalidData".data(using: .utf8)!
        MockTranslateURLProtocol.mockResponseData = mockResponseData
        
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockTranslateURLProtocol.mockResponse = mockResponse
        
        sut.getTranslate(firstLanguage: "en", secondLanguage: "fr", text: "Hello") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success.")
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.undecodableData)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testGetTranslateReseauFail() {
        let sut = makeSUT()
        
        let expectation = XCTestExpectation(description: "Appel API Translate")
        
        MockTranslateURLProtocol.mockResponseData = "Data".data(using: .utf8)!
        let mockResponseStatusCode = 500
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: mockResponseStatusCode,
            httpVersion: nil,
            headerFields: nil
        )
        MockTranslateURLProtocol.mockResponse = mockResponse
        
        sut.getTranslate(firstLanguage: "fr", secondLanguage: "en", text: "Bonjour") { result in
            switch result {
            case .success:
                XCTFail("Succès inattendu, échec attendu")
            case .failure(let error):
                XCTAssertEqual(500, mockResponse?.statusCode)
                XCTAssertEqual(error, NetworkingError.invalidResponse)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetTranslateNoData() {
        let sut = makeSUT()
        
        let expectation = XCTestExpectation(description: "Appel API Translate")
        MockTranslateURLProtocol.mockError = NSError(domain: "error", code: 0)
        let mockResponseStatusCode = 200
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: mockResponseStatusCode,
            httpVersion: nil,
            headerFields: nil
        )
        MockTranslateURLProtocol.mockResponse = mockResponse
        
        sut.getTranslate(firstLanguage: "fr", secondLanguage: "en", text: "Bonjour") { result in
            switch result {
            case .success:
                XCTFail("Succès inattendu, échec attendu")
            case .failure(let error):
                XCTAssertEqual(error, NetworkingError.noData)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    private func makeValideJSON() -> Data {
                """
                {
                    "data": {
                        "translations": [
                            {
                                "translatedText": "Test",
                                "detectedSourceLanguage": "fr"
                            }
                        ]
                    }
                }
                """.data(using: .utf8)!
    }
}
