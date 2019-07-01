//
//  LoginViewController.swift
//  Fin24
//
//  Created by Manenga Mungandi on 2019/06/30.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftyOnboard

class LoginViewController: UIViewController {

    private let primaryColor = UIColor(red:66/255, green:23/255, blue:32/255, alpha:1.0)
    private var shownWalkthrough = UserDefaults.standard.bool(forKey: "shownWalkthrough")
    private var isLoggedIn = false
    private var isShowingWalkthrough = false
    private var swiftyOnboard: SwiftyOnboard!
    
    private let key = "rosesR3dS0m3A3eBlu3Oth3S@R3N0Tee"
    private let iv  = "ThisIsATestAaKno"
    
    private var titleArray: [String] = ["Welcome to Fin24!", "It’s a handy finance news app!", "Be the first to know"]
    private var subTitleArray: [String] = ["Get the latest finance news without lifting a finger", "Curated by our awesome content team to your specifications", "Be nice to your friends.\n Share the news with them. \n It might make them smile :)"]
    private let colors:[UIColor] = [#colorLiteral(red: 0.9980840087, green: 0.3723873496, blue: 0.4952875376, alpha: 1),#colorLiteral(red: 0.2666860223, green: 0.5116362572, blue: 1, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)]
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cardView.layer.cornerRadius = 5
        loginBtn.layer.cornerRadius = 2
        loginBtn.layer.borderWidth = 1.5
        loginBtn.layer.borderColor = UIColor.white.cgColor
        
        if !self.shownWalkthrough {
            // show walkthrough
            isShowingWalkthrough = true
            swiftyOnboard = SwiftyOnboard(frame: self.view.frame)
            swiftyOnboard.backgroundColor = UIColor.white
            swiftyOnboard.fadePages = true
            swiftyOnboard.shouldSwipe = true
            
            swiftyOnboard.dataSource = self
            self.view.addSubview(swiftyOnboard)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // retrieve encrypted username and password, decrypt them
        
        let encryptedUsername = UserDefaults.standard.string(forKey: "encryptedUsername") ?? ""
        let encryptedPassword = UserDefaults.standard.string(forKey: "encryptedPassword") ?? ""
        
        do {
            let decryptedUsername = try encryptedUsername.decrypt(key: key, iv: iv)
            let decryptedPassword = try encryptedPassword.decrypt(key: key, iv: iv)
            isLoggedIn = (!decryptedUsername.isEmpty && !decryptedPassword.isEmpty)
            print("Successfully decrypted username and password.")
        } catch {
            print("Could not decrypt username and password.")
            self.loadingView.isHidden = true
            isLoggedIn = false
        }
        
        if !isShowingWalkthrough {
            attemptLogginIn()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func handleSkip() {
        isShowingWalkthrough = false
        swiftyOnboard.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "shownWalkthrough")
    }
    
    @IBAction func loginPress(_ sender: UIButton) {
        guard let user = userName.text, !user.isEmpty else {
            let message = "Username is empty"
            self.showSnack(message: message)
            print(message)
            return
        }
        
        guard let pass = password.text, !pass.isEmpty else {
            let message = "Password is empty"
            self.showSnack(message: message)
            print(message)
            return
        }
        
        // encrypt user name and password. store them
        
        do {
            let encryptedUsername = try user.encrypt(key: key, iv: iv)
            let encryptedPassword = try pass.encrypt(key: key, iv: iv)
            UserDefaults.standard.set(encryptedUsername, forKey: "encryptedUsername")
            UserDefaults.standard.set(encryptedPassword, forKey: "encryptedPassword")
            print("Successfully encrypted username and password.")
        } catch {
            print("Could not encrypt username and password.")
            print(error)
        }
        
        
        self.loadingView.isHidden = false
        self.isLoggedIn = true // proceed to news view controller
        attemptLogginIn()
    }
    
    private func attemptLogginIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            // check if user is logged in and proceed to news view controller or stay here
            
            if self.isLoggedIn {
                self.proceedToNews()
            } else {
                if !self.loadingView.isHidden {
                    UIView.animate(withDuration: 2, animations: {
                        self.loadingView.isHidden = true
                    })
                }
            }
        })
    }
    
    private func proceedToNews() {
        let vc = NewsViewController.create()
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
}

extension LoginViewController: SwiftyOnboardDataSource {
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 3
    }
    
    func swiftyOnboardBackgroundColorFor(_ swiftyOnboard: SwiftyOnboard, atIndex index: Int) -> UIColor? {
        return colors[index]
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let page = SwiftyOnboardPage()
        
        //Set the font and color for the labels:
        page.title.font = UIFont(name: "Lato-Heavy", size: 22)
        page.subTitle.font = UIFont(name: "Lato-Regular", size: 16)
        
        //Set the text in the page:
        page.title.text = titleArray[index]
        page.subTitle.text = subTitleArray[index]
        
        return page
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        let overlay = SwiftyOnboardOverlay()
        
        //Setup targets for the buttons on the overlay view:
        overlay.skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        
        //Setup for the overlay buttons:
        overlay.continueButton.isHidden = true
        overlay.skipButton.setTitleColor(UIColor.white, for: .normal)
        overlay.skipButton.titleLabel?.font = UIFont(name: "Lato-Heavy", size: 16)
        
        //Return the overlay view:
        return overlay
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        let currentPage = round(position)
        overlay.pageControl.currentPage = Int(currentPage)
        
        if currentPage == 2.0 {
            overlay.skipButton.setTitle("Done", for: .normal)
        }
    }
}
