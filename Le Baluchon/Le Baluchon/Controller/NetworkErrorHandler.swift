//
//  NetworkErrorHandler.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 22/01/2024.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlertAndRefresh(statusCode: Int, refreshAction: @escaping () -> Void) {
        let alert = UIAlertController(title: "Oups une erreur", message: "Le Status du réseau est \(statusCode)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Rafraichir", style: .default) { (_) in
            refreshAction()
        }
        
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(secondAction)
        
        present(alert, animated: true)
    }
}
