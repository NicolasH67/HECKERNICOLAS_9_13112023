//
//  NetworkErrorHandler.swift
//  Le Baluchon
//
//  Created by Nicolas Hecker on 22/01/2024.
//

import Foundation
import UIKit

/// Extension providing a utility method to display an alert and trigger a refresh action.
extension UIViewController {
    
    /// Displays an alert with an error message and options for user interaction.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code associated with the error.
    ///   - refreshAction: A closure representing the action to be taken when the user chooses to refresh.
    ///
    /// - Note: This method is designed to be used within a UIViewController subclass.
    ///
    /// - Important: Ensure that the UIViewController instance has been presented before calling this method.
    func showAlertAndRefresh(statusCode: Int, refreshAction: @escaping () -> Void) {
        let alert = UIAlertController(title: "Oops, an error", message: "Network Status is \(statusCode)", preferredStyle: .alert)

        let action = UIAlertAction(title: "Refresh", style: .default) { (_) in
            refreshAction()
        }

        let secondAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(action)
        alert.addAction(secondAction)

        present(alert, animated: true)
    }
}
