//
//  NewsService.swift
//  Fin24
//
//  Created by Manenga Mungandi on 2019/06/30.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import SwiftyXML

public class NewsService {
    
    private let debug = false // extra logs in debug
    
    // Get the default Realm
    private let realm = try! Realm()
    
    // Mark: Local db lookups
    
    public func getCachedNews() -> Results<NewsArticle> {
        return realm.objects(NewsArticle.self)
    }
    
    public func getCachedNewsAbout(_ query: String) -> Results<NewsArticle> {
        return realm.objects(NewsArticle.self).filter("title CONTAINS '\(query)' OR detail CONTAINS '\(query)'")
    }
    
    // Mark: Network Calls
    
    public func fetchNews() {
        Alamofire.request("http://feeds.news24.com/articles/Fin24/Tech/rss").responseJSON { response in
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), !data.isEmpty {
                if self.debug {
                    print("Data: \(utf8Text)") // original server data as UTF8 string
                    print()
                }
                
                // convert to JSON
                if let xml = XML(data: data) {
                    for item in xml.channel.item {
                        self.saveToDatabase(item: item)
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name.getAllNewsRequestSuccess, object: nil, userInfo: nil)
                }
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.getAllNewsRequestFailure, object: nil, userInfo: nil)
            }
        }
    }
    
    // save to Realm database
    private func saveToDatabase(item: XML) {
        let title = item.title.stringValue
        let description = item[.key("description")].stringValue
        let link = item.link.stringValue
        let pubDate = item[.key("pubDate")].stringValue
        var imageUrl = ""
        
        if let enclosure = item[.key("enclosure")].xml {
            imageUrl = enclosure[.attribute("url")].stringValue
        }
        
        if debug {
            print("Item title: \(title)")
            print("Item description: \(description)")
            print("Item link: \(link)")
            print("Item image url: \(imageUrl)")
            print()
        }
        
        let article = NewsArticle()
        article.title = title
        article.detail = description
        article.linkURL = link
        article.imageURL = imageUrl
        
        let suffixIndex = pubDate.index(pubDate.startIndex, offsetBy: 16)
        article.pubDate = String(pubDate.prefix(upTo: suffixIndex))
        
        try! realm.write {
            realm.add(article)
        }
    }
}

public class NewsArticle: Object {
    @objc dynamic var title = ""
    @objc dynamic var detail = ""
    @objc dynamic var linkURL = ""
    @objc dynamic var pubDate = ""
    @objc dynamic var imageURL = ""
}
