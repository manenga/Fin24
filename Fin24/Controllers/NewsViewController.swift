//
//  NewsViewController.swift
//  Fin24
//
//  Created by Manenga Mungandi on 2019/06/30.
//  Copyright © 2019 Manenga Mungandi. All rights reserved.
//

import UIKit
import RealmSwift
import LPSnackbar

class NewsViewController: UIViewController {

    private var items: Results<NewsArticle>!
    private var refreshControl = UIRefreshControl.init()
    private let service = NewsService.init()
    
    static var identifier = "NewsViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    class func create() -> NewsViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: NewsViewController.identifier) as! NewsViewController
        controller.items = NewsService.init().getCachedNews()
        return controller
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if items.isEmpty {
            reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(reloadData), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        let color = UIColor(red:66/255, green:23/255, blue:32/255, alpha:1.0)
        let attributes: [NSAttributedString.Key: Any] = [ .foregroundColor : color ]
        
        refreshControl.tintColor = color
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Your Feed...", attributes: attributes)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: ArticleTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ArticleTableViewCell.identifier)
        
        navigationItem.title = "Fin24 Tech"
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor : UIColor.white ]
        navigationController?.navigationBar.barTintColor = color
        navigationController?.navigationBar.isTranslucent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSuccessful(notification:)), name: Notification.Name.getAllNewsRequestSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUnsuccessful(notification:)), name: Notification.Name.getAllNewsRequestFailure, object: nil)
    }
    
    deinit {
        // Release all resources
        // perform the deinitialization
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadData() {
        refreshControl.beginRefreshing()
        service.fetchNews()
    }
    
    @objc func reloadSuccessful(notification: Notification) {
        refreshControl.endRefreshing()
        // refresh items and reload table view
        items = service.getCachedNews()
        tableView.reloadData()
    }
    
    @objc func reloadUnsuccessful(notification: Notification) {
        refreshControl.endRefreshing()
        showRetrySnack()
    }
    
    public func showRetrySnack() {
        let snack = LPSnackbar(title: "Failed to load news articles...", buttonTitle: "Retry")
        snack.show(animated: true) { (redo) in
            if redo {
                self.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension NewsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier) as! ArticleTableViewCell
        let item = items[indexPath.row]
        cell.set(article: item)
        return cell
    }
}

extension NewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let vc = NewsDetailViewController.create(article: item)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

