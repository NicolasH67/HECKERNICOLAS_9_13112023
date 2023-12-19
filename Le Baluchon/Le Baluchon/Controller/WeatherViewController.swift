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
    var tempNewYork = "0.00"
    var descriptionNewYork = "Error"
    var tempParis = "0.00"
    var descriptionParis = "Error"
    let latNewYork = "40.71"
    let lonNewYork = "-74.00"
    let latParis = "48.85"
    let lonParis = "2.35"
    let loader = Weather()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topView.roundCorners(corners: .allCorners, radius: 30)
        bottomView.roundCorners(corners: .allCorners, radius: 30)
        loader.getWeather(lat: latNewYork, lon: lonNewYork) { result in
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
                    print(result)
                    break
                }
            }
        }
        loader.getWeather(lat: latParis, lon: lonParis) { result in
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
                    print(result)
                    break
                }
            }
        }
    }
}

extension WeatherViewController {
    
}
