//
//  ExchangeTests.swift
//  Le BaluchonTests
//
//  Created by Nicolas Hecker on 19/12/2023.
//

import XCTest
@testable import Le_Baluchon


class MockURLProtocol: URLProtocol {
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
        if let data = MockURLProtocol.mockResponseData {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        }
        if let response = MockURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        //This function is mandatory, but I do not use it in these tests.
    }
    
    static func resetMock() {
        MockURLProtocol.mockError = nil
        MockURLProtocol.mockResponse = nil
        MockURLProtocol.mockResponseData = nil
    }
}

class ExchangeTests: XCTestCase {
    
    private func makeSUT() -> (sut: ExchangeRatesLoader, spy: exchangeTestDelegateSpy) {
        MockURLProtocol.resetMock()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let sut = ExchangeRatesLoader(session: URLSession(configuration: config))
        let spy = exchangeTestDelegateSpy()
        sut.delegate = spy
        return (sut, spy)
    }

    func testGetExchangeSuccess() {
        let sut = makeSUT().sut
        let expectation = XCTestExpectation(description: "Appel API Exchange")
        let mockResponseData = """
        {
            "success": true,
            "timestamp": 1703520004,
            "base": "EUR",
            "date": "2023-12-25",
            "rates": {
                "USD": 1.2
            }
        }
        """.data(using: .utf8)!

        MockURLProtocol.mockResponseData = mockResponseData
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockResponse = mockResponse

        sut.getExchange { result in
            switch result {
            case .success(let rate):
                XCTAssertEqual(rate, 1.2)
            case .failure(let error):
                print("Error: \(error)")
                XCTFail("Succès attendu, échec obtenu. Error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetExchangeUndecodableData() {
        let sut = makeSUT().sut
        let expectation = XCTestExpectation(description: "Appel API Exchange")

        let mockResponseData = "invalideData".data(using: .utf8)!

        MockURLProtocol.mockResponseData = mockResponseData
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockResponse = mockResponse

        sut.getExchange { result in
            switch result {
            case .success(let error):
                print("Error: \(error)")
                XCTFail("Erreur attendu, succès obtenu. Error: \(error)")
            case .failure(let error):
                XCTAssertEqual(error as NetworkingError, NetworkingError.undecodableData)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetExchangeReseauFail() {
        let sut = makeSUT().sut
        let expectation = XCTestExpectation(description: "Appel API Exchange")
        let mockResponseData = "Data".data(using: .utf8)!
        MockURLProtocol.mockResponseData = mockResponseData
        let mockResponseStatusCode = 500
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: mockResponseStatusCode,
            httpVersion: nil,
            headerFields: nil
        )
        MockURLProtocol.mockResponse = mockResponse

        sut.getExchange { result in
            switch result {
            case .success:
                XCTFail("Succès inattendu, échec attendu")
            case .failure(let error):
                XCTAssertEqual(500, mockResponse?.statusCode)
                XCTAssertEqual(error as NetworkingError, NetworkingError.invalidResponse)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetExchangeNoData() {
        let sut = makeSUT().sut
        let expectation = XCTestExpectation(description: "Appel API Exchange")

        MockURLProtocol.mockError = NSError(domain: "Test", code: 123, userInfo: nil)

        sut.getExchange { result in
            switch result {
            case .success:
                XCTFail("Échec attendu, succès obtenu")
            case .failure(let error):
                XCTAssertEqual(error as NetworkingError, NetworkingError.noData)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }
    
    func testExchange1Euro() {
        let (sut, delegate) = makeSUT()
        
        let rates = 1.2
        
        sut.updateExchangeValue(withText: "1", tauxExchange: rates, firstSetting: "Euro")
        XCTAssertEqual(delegate.text, "1.20 $")
    }
    
    func testExchange1Dollar() {
        let (sut, delegate) = makeSUT()
        
        let rates = 0.5
        
        sut.updateExchangeValue(withText: "1", tauxExchange: rates, firstSetting: "Dollar")
        XCTAssertEqual(delegate.text, "2.00 €")
    }
    
    func testExchangeError() {
        let (sut, delegate) = makeSUT()
        
        let rates = 0.5
        let text = "Conversion to Double failed"
        
        sut.updateExchangeValue(withText: "Error", tauxExchange: rates, firstSetting: "Dollar")
        XCTAssertEqual(delegate.text, text)
    }
    
    func testExchangeErrorSetting() {
        let (sut, delegate) = makeSUT()
        
        let rates = 0.5
        let text = "error with setting"
        
        sut.updateExchangeValue(withText: "1", tauxExchange: rates, firstSetting: "Pounds")
        XCTAssertEqual(delegate.text, text)
    }
}

class exchangeTestDelegateSpy: ExchangeModelDelegate {
    
    private(set) var text = ""
    
    func didUpdateExchangeValue(_ formattedValue: String) {
        self.text = formattedValue
    }
    
    func didFailConversion() {
        self.text = "Conversion to Double failed"
    }
}
