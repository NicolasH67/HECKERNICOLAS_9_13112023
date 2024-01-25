//
//  TranslateViewController.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 24/11/2023.
//

import UIKit

class TranslateViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var translatetextView: UITextView!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var secondSetting: UILabel!
    @IBOutlet weak var firstSetting: UILabel!
    
    //MARK: - Object Initialization
    
    let loader = TranslateLoader()
    
    //MARK: - Override
    
    /// View Controller Lifecycle method called after the view has been loaded into memory.
    ///
    /// This method configures the initial appearance and settings of the view elements.
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        firstSetting.applyCornerRadius(30)
        secondSetting.applyCornerRadius(30)
        translateLabel.text = ""
        
    }
    
    //MARK: - IBAction

    @IBAction func translate(_ sender: Any) {
        callEndpoint()
        self.translateLabel.isHidden = false
    }
    
    @IBAction func invers(_ sender: Any) {
        guard let leftSymbol = firstSetting.text else { return }
        guard let rightSymbol = secondSetting.text else { return }
        
        firstSetting.text = rightSymbol
        secondSetting.text = leftSymbol
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        translatetextView.resignFirstResponder()
    }
}

extension TranslateViewController {
    //MARK: - Extension
    
    //MARK: - Methode
    
    /// Initiates a translation endpoint call based on the selected language setting.
    ///
    /// This method checks the value of the `firstSetting` text field. If it is set to "Français",
    /// it calls the `callEndpointTargetEn()` function for English translation; otherwise, it calls
    /// the `callEndpointTargetFr()` function for French translation.
    ///
    /// - Note: This function assumes the existence of the `callEndpointTargetEn()` and `callEndpointTargetFr()`
    ///   functions for handling the translation logic.
    private func callEndpoint() {
        if firstSetting.text == "Français" {
            callEndpointTargetEn()
        } else {
            callEndpointTargetFr()
        }
    }
    
    /// Initiates a translation endpoint call for translating text from French to English.
    ///
    /// This method uses the `loader` to make a translation API call with the specified parameters.
    /// If the call is successful, it updates the `translateLabel` with the translated text.
    /// In case of a failure, it shows an alert with a 500 status code and provides a refresh action
    /// to retry the translation by calling itself (`callEndpointTargetEn()`).
    private func callEndpointTargetEn() {
        loader.getTranslate(firstLanguage: "fr", secondLanguage: "en", text: translatetextView.text) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(translate):
                    guard let translatedText = translate.data.translations.first?.translatedText else {
                        return
                    }
                    self.translateLabel.text = translatedText
                case .failure:
                    self.showAlertAndRefresh(statusCode: 500, refreshAction: self.callEndpointTargetEn)
                }
            }
        }
    }
    
    /// Initiates a translation endpoint call for translating text from English to French.
    ///
    /// This method uses the `loader` to make a translation API call with the specified parameters.
    /// If the call is successful, it updates the `translateLabel` with the translated text.
    /// In case of a failure, it shows an alert with a 500 status code and provides a refresh action
    /// to retry the translation by calling itself (`callEndpointTargetFr()`).
    private func callEndpointTargetFr() {
        loader.getTranslate(firstLanguage: "en", secondLanguage: "fr", text: translatetextView.text) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(translate):
                    guard let translatedText = translate.data.translations.first?.translatedText else {
                        return
                    }
                    self.translateLabel.text = translatedText
                case .failure:
                    self.showAlertAndRefresh(statusCode: 500, refreshAction: self.callEndpointTargetFr)
                }
            }
        }
    }
}
