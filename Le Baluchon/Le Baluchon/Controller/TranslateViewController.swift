//
//  TranslateViewController.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 24/11/2023.
//

import UIKit

class TranslateViewController: UIViewController {
    @IBOutlet weak var translatetextView: UITextView!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var secondSetting: UILabel!
    @IBOutlet weak var firstSetting: UILabel!
    
    var loader = Translate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 30)
        firstSetting.applyCornerRadius(30)
        secondSetting.applyCornerRadius(30)
        translateLabel.text = ""
        
    }
    
    
    @IBAction func translate(_ sender: Any) {
        if firstSetting.text == "Français" {
            loader.getTranslate(firstLanguage: "fr", secondLanguage: "en", text: translatetextView.text) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(translate):
                        guard let translatedText = translate.data.translations.first?.translatedText else {
                            return
                        }
                        print(translatedText)
                        self.translateLabel.text = translatedText
                    case .failure:
                        break
                    }
                }
            }
        } else {
            loader.getTranslate(firstLanguage: "en", secondLanguage: "fr", text: translatetextView.text) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(translate):
                        guard let translatedText = translate.data.translations.first?.translatedText else {
                            return
                        }
                        print(translatedText)
                        self.translateLabel.text = translatedText
                    case .failure:
                        break
                    }
                }
            }
        }
        self.translateLabel.isHidden = false
    }
    
    @IBAction func invers(_ sender: Any) {
        let leftSymbol = firstSetting.text!
        let rightSymbol = secondSetting.text!
        
        firstSetting.text = rightSymbol
        secondSetting.text = leftSymbol
        if translatetextView.isHidden {
            translateButton.setTitle("Traduire", for: .normal)
            translatetextView.text = ""
        }
    }
}
