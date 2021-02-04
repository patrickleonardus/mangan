//
//  ArticleFavoriteController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 22/01/21.
//

import UIKit
import CoreData

class ArticleFavoriteController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var articleFavoriteLists = [ArticleFavoriteList]()
    
    var tagChoose = ""
    var keyChoose = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Artikel Favorit"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        onFetchData()
        
    }
    
    func onFetchData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleFavorite")
        do {
            let favoriteLists = try managedContext.fetch(fetchRequest)
           
            favoriteLists.forEach { (favorite) in
                
                let imgUrl = favorite.value(forKey: "imageUrl") as? String ?? ""
                let key = favorite.value(forKey: "key") as? String ?? ""
                let title = favorite.value(forKey: "title") as? String ?? ""
                let tag = favorite.value(forKey: "tag") as? String ?? ""
                
                articleFavoriteLists.append(ArticleFavoriteList(imageUrl: imgUrl, key: key, title: title, tag: tag))
                articleFavoriteLists.reverse()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "willMoveToDetail" {
            if let dest = segue.destination as? DetailArticleController {
                dest.tag = self.tagChoose
                dest.key = self.keyChoose
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        num = articleFavoriteLists.count
        
        if num == 0 {
            self.tableView.setEmptyMessage("Belum ada daftar artikel favorite")
        }
        else {
            self.tableView.restore()
        }
        
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "article_favorite_cell") as? FavoriteCell {
            
            let article = articleFavoriteLists[indexPath.row]
            
            cell.favoriteImage.sd_setImage(with: URL(string: article.imageUrl), completed: nil)
            cell.favoriteTitle.text = article.title
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = articleFavoriteLists[indexPath.row]
        
        self.keyChoose = article.key
        self.tagChoose = article.tag
        
        self.performSegue(withIdentifier: "willMoveToDetail", sender: self)
        
    }
    
}
