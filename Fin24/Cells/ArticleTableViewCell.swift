//
//  ArticleTableViewCell.swift
//  Fin24
//
//  Created by Manenga Mungandi on 2019/07/01.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    static var identifier = "ArticleTableViewCell"
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headlineLabel.text = ""
        dateLabel.text = ""
        articleDetail.text = ""
        articleImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func set(article: NewsArticle) {
        // (String.IndexDistance.init("Fin24.com | ") ?? nil)!
        let prefixIndex = article.title.index(article.title.startIndex, offsetBy: 12)
        headlineLabel.text = String(article.title.suffix(from: prefixIndex))
        dateLabel.text = article.pubDate
        articleDetail.text = article.detail
        
        if article.imageURL.isEmpty {
            articleImageView.isHidden = true
        } else {
            articleImageView.setImage(url: article.imageURL)
            articleImageView.isHidden = false
        }
    }
}
