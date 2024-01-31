//
//  WeatherViewController.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 21/11/2023.
//

import UIKit

class WeatherViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topCityLabel: UILabel!
    @IBOutlet weak var topTempLabel: UILabel!
    @IBOutlet weak var topDescriptionLabel: UILabel!
    @IBOutlet weak var bottomCityLabel: UILabel!
    @IBOutlet weak var bottomTempLabel: UILabel!
    @IBOutlet weak var bottomDescriptionLabel: UILabel!
    
    //MARK: - Weather Data
    
    var tempNewYork = "0.00"
    var descriptionNewYork = "Error"
    var tempParis = "0.00"
    var descriptionParis = "Error"
    
    //MARK: - Geographic Coordinates
    
    private let latNewYork = "40.71"
    private let lonNewYork = "-74.00"
    private let latParis = "48.85"
    private let lonParis = "2.35"
    
    //MARK: - Object Initialization
    
    let loader = Weatherloader()
    
    //MARK: - Override
    
    /// View Controller Lifecycle method called after the view has been loaded into memory.
    ///
    /// This method configures the initial appearance and settings of the view elements.
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.roundCorners(corners: .allCorners, radius: 30)
        bottomView.roundCorners(corners: .allCorners, radius: 30)
        callAllEndpoint()
    }
}

extension WeatherViewController {
    
    //MARK: - Method
    
    /// Initiates translation endpoint calls for both New York and Paris coordinates.
    ///
    /// This method calls the specific endpoint functions (`callEndpointNewYork()` and `callEndpointParis()`)
    /// to perform translation logic for the geographic coordinates of New York and Paris.
    private func callAllEndpoint() {
        callEndpointNewYork()
        callEndpointParis()
    }
    
    /// Initiates a weather API call for the geographic coordinates of New York.
    ///
    /// This method uses the `loader` to make a weather API call with the coordinates of New York.
    /// If the call is successful, it updates UI elements (`topTempLabel` and `topDescriptionLabel`)
    /// with the temperature and weather description. In case of a failure, it shows an alert with
    /// a 500 status code and provides a refresh action to retry all endpoints (`callAllEndpoint()`).
    private func callEndpointNewYork() {
        loader.getWeather(lat: latNewYork, lon: lonNewYork) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(weather):
                    let temp = weather.main.temp
                    let tempInt = Int(temp)
                    self.topTempLabel.text = "\(tempInt)°C"
                    if let firstWeatherDetail = weather.weather.first {
                        let description = firstWeatherDetail.description
                        self.topDescriptionLabel.text = description
                    }
                case .failure:
                    self.showAlertAndRefresh(statusCode: 500, refreshAction: self.callAllEndpoint)
                }
            }
        }
    }
    
    /// Initiates a weather API call for the geographic coordinates of Paris.
    ///
    /// This method uses the `loader` to make a weather API call with the coordinates of Paris.
    /// If the call is successful, it updates UI elements (`bottomTempLabel` and `bottomDescriptionLabel`)
    /// with the temperature and weather description. In case of a failure, it shows an alert with
    /// a 500 status code and provides a refresh action to retry all endpoints (`callAllEndpoint()`).
    private func callEndpointParis() {
        loader.getWeather(lat: latParis, lon: lonParis) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(weather):
                    let temp = weather.main.temp
                    let tempInt = Int(temp)
                    self.bottomTempLabel.text = "\(tempInt)°C"
                    if let firstWeatherDetail = weather.weather.first {
                        let description = firstWeatherDetail.description
                        self.bottomDescriptionLabel.text = description
                    }
                case .failure:
                    self.showAlertAndRefresh(statusCode: 500, refreshAction: self.callAllEndpoint)
                }
            }
        }
    }
}

