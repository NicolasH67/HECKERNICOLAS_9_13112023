//
//  ExchangeViewController.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 14/11/2023.
//

import UIKit

class ExchangeViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var secondSetting: UILabel!
    @IBOutlet weak var firstSetting: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    
    private let loader = Exchange()
    private var tauxExchange: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        backgroundView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        firstSetting.applyCornerRadius(30)
        secondSetting.applyCornerRadius(30)
        amountTextField.keyboardType = .numberPad
        loader.delegate = self
        amountTextField.delegate = self
        loader.getExchange { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(rate):
                    self.tauxExchange = rate
                case .failure:
                    break
                }
            }
        }

    }
    
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let range = Range(range, in: currentText),
              let updatedText = Optional(currentText.replacingCharacters(in: range, with: string)) else {
            return false
        }

        loader.updateExchangeValue(withText: updatedText, tauxExchange: tauxExchange, firstSetting: firstSetting.text!)
        return true
    }
    
    private func showAlert(statusCode: Int) {
        let alert = UIAlertController(title: "Oups une erreur", message: "Le Status du réseau est\(statusCode)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            self.refreshApplication()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func refreshApplication() {
        loader.getExchange { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(rate):
                    self.tauxExchange = rate
                case .failure:
                    break
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
