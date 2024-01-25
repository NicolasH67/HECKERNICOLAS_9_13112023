//
//  WeatherTests.swift
//  Le BaluchonTests
//
//  Created by Nicolas Hecker on 02/01/2024.
//

import XCTest
@testable import Le_Baluchon

class MockWeatherURLProtocol: URLProtocol {
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
        if let data = MockWeatherURLProtocol.mockResponseData {
            client?.urlProtocol(self, didLoad: data)
        }
        if let error = MockWeatherURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
        }
        if let response = MockWeatherURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        // Ne rien faire
    }
    
    static func resetMock() {
        MockWeatherURLProtocol.mockError = nil
        MockWeatherURLProtocol.mockResponse = nil
        MockWeatherURLProtocol.mockResponseData = nil
    }
}

class WeatherTests: XCTestCase {
    
    private func makeSUT() -> (Weatherloader) {
        MockWeatherURLProtocol.resetMock()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockWeatherURLProtocol.self]
        let sut = Weatherloader(session: URLSession(configuration: config))
        return sut
    }
    
    func testGetWeatherSuccess() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Appel API Weather")
        let mockResponseData = """
            {
                "weather": [
                    {
                        "id": 800,
                        "main": "Clear",
                        "description": "clear sky",
                        "icon": "01d"
                    }
                ],
                "main": {
                    "temp": 25.5,
                    "feels_like": 24.8,
                    "temp_min": 24.0,
                    "temp_max": 26.5,
                    "pressure": 1015,
                    "humidity": 50
                }
            }
            """.data(using: .utf8)!

        MockWeatherURLProtocol.mockResponseData = mockResponseData
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockWeatherURLProtocol.mockResponse = mockResponse

        sut.getWeather(lat: "37.7749", lon: "-122.4194") { result in
            switch result {
            case .success(let weatherResponse):
                XCTAssertEqual(weatherResponse.weather.first?.main, "Clear")
                XCTAssertEqual(weatherResponse.main.temp, 25.5, accuracy: 0.1)
            case .failure(let error):
                print("Error: \(error)")
                XCTFail("Succès attendu, échec obtenu. Error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetWeatherUndecodableData() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Appel API Weather")

        let mockResponseData = "invalidData".data(using: .utf8)!

        MockWeatherURLProtocol.mockResponseData = mockResponseData
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        MockWeatherURLProtocol.mockResponse = mockResponse

        sut.getWeather(lat: "37.7749", lon: "-122.4194") { result in
            switch result {
            case .success:
                XCTFail("Erreur attendue, succès obtenu.")
            case .failure(let error):
                XCTAssertEqual(error as NetworkingError, NetworkingError.undecodableData)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testGetWeatherNetworkFail() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Appel API Exchange")
        let mockResponseData = "Data".data(using: .utf8)!
        MockWeatherURLProtocol.mockResponseData = mockResponseData
        let mockResponseStatusCode = 500
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: mockResponseStatusCode,
            httpVersion: nil,
            headerFields: nil
        )
        MockWeatherURLProtocol.mockResponse = mockResponse

        sut.getWeather(lat: "37.7749", lon: "-122.4194") { result in
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

    func testGetWeatherNoData() {
        let sut = makeSUT()
        let expectation = XCTestExpectation(description: "Appel API Exchange")

        MockWeatherURLProtocol.mockError = NSError(domain: "Test", code: 123, userInfo: nil)

        sut.getWeather(lat: "37.7749", lon: "-122.4194") { result in
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
}
