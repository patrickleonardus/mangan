//
//  MenuFavoriteController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 22/01/21.
//

import UIKit
import CoreData

class MenuFavoriteController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuFavoriteLists = [MenuFavoriteList]()
    var chooseKey = ""
    var chooseImageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Menu Favorit"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        onFetchData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "willMoveToDetailMenu" {
            if let dest = segue.destination as? DetailMenuController {
                dest.key = self.chooseKey
                dest.imageUrl = self.chooseImageUrl
            }
        }
    }
    
    func onFetchData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MenuFavorite")
        do {
            let favoriteLists = try managedContext.fetch(fetchRequest)
           
            favoriteLists.forEach { (favorite) in
                
                let imgUrl = favorite.value(forKey: "imageUrl") as? String ?? ""
                let key = favorite.value(forKey: "key") as? String ?? ""
                let title = favorite.value(forKey: "title") as? String ?? ""
                
                menuFavoriteLists.append(MenuFavoriteList(imageUrl: imgUrl, key: key, title: title))
                menuFavoriteLists.reverse()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        num = menuFavoriteLists.count
        
        if num == 0 {
            self.tableView.setEmptyMessage("Belum ada daftar resep favorite")
        }
        else {
            self.tableView.restore()
        }
        
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "menu_favorite_cell") as? FavoriteCell {
            
            let favorite = menuFavoriteLists[indexPath.row]
            
            cell.favoriteTitle.text = favorite.title
            cell.favoriteImage.sd_setImage(with: URL(string: favorite.imageUrl), completed: nil)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let favorite = menuFavoriteLists[indexPath.row]
        self.chooseKey = favorite.key
        self.chooseImageUrl = favorite.imageUrl
        
        self.performSegue(withIdentifier: "willMoveToDetailMenu", sender: self)
        
    }
    
}
