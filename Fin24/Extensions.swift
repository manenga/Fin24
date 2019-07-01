//
//  Extensions.swift
//  Fin24
//
//  Created by Manenga Mungandi on 2019/06/30.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//

import Foundation
import UIKit
import LPSnackbar
import CryptoSwift

extension String {
    
    public func encrypt(key: String, iv: String) throws -> String {
        let encrypted = try AES(key: key, iv: iv, padding: .pkcs7).encrypt([UInt8](self.data(using: .utf8)!))
        return Data(encrypted).base64EncodedString()
    }
    
    public func decrypt(key: String, iv: String) throws -> String {
        guard let data = Data(base64Encoded: self) else { return "" }
        let decrypted = try AES(key: key, iv: iv, padding: .pkcs7).decrypt([UInt8](data))
        return String(bytes: decrypted, encoding: .utf8) ?? self
    }
}

extension Notification.Name {
    public static let getAllNewsRequestSuccess = Notification.Name("getAllNewsRequestSuccess")
    public static let getAllNewsRequestFailure = Notification.Name("getAllNewsRequestFailure")
    public static let CachedNewsRefreshed = Notification.Name("CachedNewsRefreshed")
}

extension UIImageView {
    
    func setImage(url: String) {
        let imgUrl = NSURL(string: url)!
        
        let task = URLSession.shared.dataTask(with: imgUrl as URL) { (responseData, responseUrl, error) -> Void in
            if let data = responseData{
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.image = UIImage(data: data)
                })
            }
        }
        
        task.resume()
    }
}
extension UIViewController {
    
    public func showSnack(message: String) {
        LPSnackbar.showSnack(title: message)
    }
    
    public func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Oh, okay.", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
