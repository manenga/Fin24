//
//  NewsDetailViewController.swift
//  Fin24
//
//  Created by Manenga Mungandi on 2019/06/30.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {

    private var article: NewsArticle!
    static var identifier = "NewsDetailViewController"
    
    @IBOutlet weak var articleHeadline: UILabel!
    @IBOutlet weak var articleImg: UIImageView!
    @IBOutlet weak var articleDetail: UITextView!
    
    class func create(article: NewsArticle) -> NewsDetailViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: NewsDetailViewController.identifier) as! NewsDetailViewController
        controller.article = article
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let color = UIColor(red:66/255, green:23/255, blue:32/255, alpha:1.0)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor : UIColor.white ]
        navigationController?.navigationBar.barTintColor = color
        
        let prefixIndex = article.title.index(article.title.startIndex, offsetBy: 12)
        articleHeadline.text = String(article.title.suffix(from: prefixIndex))
        articleDetail.text = article.detail
        
        if article.imageURL.isEmpty {
            articleImg.isHidden = true
        } else {
            articleImg.setImage(url: article.imageURL)
            articleImg.isHidden = false
        }
    }
    
    @IBAction func shareToFacebook(_ sender: UIButton) {
        showPromotionalAlert()
    }
    
    @IBAction func shareToTwitter(_ sender: UIButton) {
        showPromotionalAlert()
    }
    
    @IBAction func shareToLinkedIn(_ sender: UIButton) {
        showPromotionalAlert()
    }
    
    private func showPromotionalAlert() {
        showAlert(title: "Sorry", message: "This is purely for UI purposes.")
    }
    
    @IBAction func openInBrowserPress(_ sender: UIButton) {
        guard let url = URL(string: article.linkURL) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
