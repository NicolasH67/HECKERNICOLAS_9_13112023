//
//  ExchangeViewController.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 14/11/2023.
//

import UIKit

final class ExchangeViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var secondSetting: UILabel!
    @IBOutlet weak var firstSetting: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    
    //MARK: - Object Initialization
    
    private let loader = ExchangeRatesLoader()
    
    // MARK: - Exchange Rate Declaration
    
    private var tauxExchange: Double = 0.0
    
    /// View Controller Lifecycle method called after the view has been loaded into memory.
    ///
    /// This method configures the initial appearance and settings of the view elements.
    override func viewDidLoad() {
        super.viewDidLoad()
            
        backgroundView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        firstSetting.applyCornerRadius(30)
        secondSetting.applyCornerRadius(30)
        amountTextField.keyboardType = .numberPad
        loader.delegate = self
        amountTextField.delegate = self
        callEndpoint()
    }
    
    //MARK: - IBAction
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        amountTextField.resignFirstResponder()
    }
    
    @IBAction func invers(_ sender: Any) {
        let leftSymbol = firstSetting.text!
        let rightSymbol = secondSetting.text!
        
        firstSetting.text = rightSymbol
        secondSetting.text = leftSymbol
        
        if let text = amountTextField.text {
            loader.updateExchangeValue(withText: text, tauxExchange: tauxExchange, firstSetting: firstSetting.text!)
        }
    }
}


extension ExchangeViewController {
    
    // MARK: - Methode
    
    /// Validates and updates the text field content during user input.
    ///
    /// This delegate method is called when the text in the text field is about to change. It performs the following tasks:
    /// - Validates the current text, range, and replacement string.
    /// - Updates the text field's content with the modified text.
    /// - Calls the `loader.updateExchangeValue` method to handle the exchange value update based on the entered text.
    ///
    /// - Parameters:
    ///   - textField: The text field for which the changes are being made.
    ///   - range: The range of characters to be replaced in the text field.
    ///   - string: The string that will replace the characters in the specified range.
    ///
    /// - Returns: A Boolean value indicating whether the replacement should occur.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let range = Range(range, in: currentText),
              let updatedText = Optional(currentText.replacingCharacters(in: range, with: string)) else {
            return false
        }

        loader.updateExchangeValue(withText: updatedText, tauxExchange: tauxExchange, firstSetting: firstSetting.text!)
        return true
    }
    
    /// Initiates an API call to retrieve the exchange rate.
    ///
    /// This method uses the `loader` to make an API call to obtain the exchange rate. If the call is successful,
    /// it updates the `tauxExchange` property with the retrieved rate. In case of a failure, it shows an alert
    /// with a 500 status code and provides a refresh action to retry the endpoint call (`callEndpoint()`).
    private func callEndpoint() {
        loader.getExchange { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success(rate):
                    self.tauxExchange = rate
                case .failure:
                    self.showAlertAndRefresh(statusCode: 500, refreshAction: self.callEndpoint)
                }
            }
        }
    }
}

extension ExchangeViewController: ExchangeModelDelegate, UITextFieldDelegate {
    // MARK: - Delegate
    func didUpdateExchangeValue(_ formattedValue: String) {
        exchangeLabel.text = formattedValue
    }
    
    func didFailConversion() {
        exchangeLabel.text = "Conversion to Double failed"
    }
}

protocol ExchangeModelDelegate: AnyObject {
    // MARK: - Protocol
    func didUpdateExchangeValue(_ formattedValue: String)
    func didFailConversion()
}
