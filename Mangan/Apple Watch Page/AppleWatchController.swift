//
//  AppleWatchController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 22/01/21.
//

import UIKit
import CoreData
import WatchConnectivity

class AppleWatchController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var menuWatch = [MenuWatch]()
    var wcSession = WCSession.default

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        wcSession.delegate = self
        wcSession.activate()

        self.navigationItem.title = "Apple Watch"
        
        onRetrieveWatchMenu()
        
    }
    
    func onRetrieveWatchMenu(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchMenu")
        do {
            let favoriteLists = try managedContext.fetch(fetchRequest)
            
            favoriteLists.forEach { (favorite) in
                
                let imgUrl = favorite.value(forKey: "imageUrl") as? String ?? ""
                let menuUrl = favorite.value(forKey: "menuUrl") as? String ?? ""
                let title = favorite.value(forKey: "title") as? String ?? ""
                
                self.willSendDataToWatch(imgUrl: imgUrl, menuUrl: menuUrl, title: title)
                
                menuWatch.append(MenuWatch(imageUrl: imgUrl, menuUrl: menuUrl, title: title))
                menuWatch.reverse()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func willSendDataToWatch(imgUrl: String, menuUrl: String, title: String){
        let data = ["imgUrl":imgUrl, "menuUrl":menuUrl, "title":title]
        wcSession.sendMessage(data, replyHandler: nil) { (error) in
            print("\n\nError Happened : \n\(error.localizedDescription)")
        }
    }

}

extension AppleWatchController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        num = menuWatch.count
        return num
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Menu ini digunakan di Apple Watch, anda dapat menambahkan menu baru untuk ditampilkan di Apple Watch pada halaman detail resep"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "watch_menu") as? FavoriteCell {
            let menu = menuWatch[indexPath.row]
            cell.favoriteTitle.text = menu.title
            cell.favoriteImage.sd_setImage(with: URL(string: menu.imageUrl), completed: nil)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AppleWatchController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
}
