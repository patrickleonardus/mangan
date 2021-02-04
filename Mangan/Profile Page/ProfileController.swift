//
//  ProfileController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 21/01/21.
//

import UIKit
import CoreData

class ProfileController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityMenu = ["Edit Profile", "Menu Favorit", "Artikel Favorit"]
    let appleMenu = ["Apple Watch"]
    let tocMenu = ["Syarat dan Ketentuan", "Kebijakan Privasi", "Licenses"]
    let logOutMenu = ["Hapus Data & Keluar"]
    
    var initialColor: UIColor?
    var initialName = ""
    var name = ""
    var tocState = 0
    var uiStyle: UIStyle = .light
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        onCheckInterfaceStyle()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "willMoveToEdit" {
            if let dest = segue.destination as? UINavigationController {
                if let topController = dest.topViewController as? EditProfileController {
                    topController.name = self.name
                }
            }
        }
        else if segue.identifier == "willShowTOC" {
            if let dest = segue.destination as? TOCController {
                dest.tocState = self.tocState
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        switch traitCollection.userInterfaceStyle {
        case .light:
            uiStyle = .light
            self.navigationController?.view.backgroundColor  = UIColor.white
        case .dark:
            uiStyle = .dark
            self.navigationController?.view.backgroundColor  = UIColor.black
        default:
            uiStyle = .light
            self.navigationController?.view.backgroundColor  = UIColor.white
        }
    }
    
    func onCheckInterfaceStyle(){
        if self.traitCollection.userInterfaceStyle == .light {
            uiStyle = .light
            self.navigationController?.view.backgroundColor  = UIColor.white
        }
        else {
            uiStyle = .dark
            self.navigationController?.view.backgroundColor  = UIColor.black
        }
    }
    
    func deleteAllData(){
        ///delete core data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequestUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        let fetchRequestMenu = NSFetchRequest<NSFetchRequestResult>(entityName: "MenuFavorite")
        let fetchRequestArticle = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticleFavorite")
        let fetchRequestWatch = NSFetchRequest<NSFetchRequestResult>(entityName: "WatchMenu")
        let deleteRequestUser = NSBatchDeleteRequest(fetchRequest: fetchRequestUser)
        let deleteRequestMenu = NSBatchDeleteRequest(fetchRequest: fetchRequestMenu)
        let deleteRequestArticle = NSBatchDeleteRequest(fetchRequest: fetchRequestArticle)
        let deleteRequestWatch = NSBatchDeleteRequest(fetchRequest: fetchRequestWatch)
        do {
            try managedContext.execute(deleteRequestUser)
            try managedContext.execute(deleteRequestMenu)
            try managedContext.execute(deleteRequestArticle)
            try managedContext.execute(deleteRequestWatch)
            try managedContext.save()
        } catch let error {
            fatalError("Error occured while delete the data in core data \nDetail:\n \(error)")
        }
        
        ///delete user defaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
    }
    
}

extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        
        if section == 0 {
            num = 1
        }
        else if section == 1 {
            num = activityMenu.count
        }
        else if section == 2 {
            num = 1
        }
        else if section == 3 {
            num = tocMenu.count
        }
        else if section == 4 {
            num = logOutMenu.count
        }

        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profile_picture_cell") as? ProfilePictureCell {
                
                if let color = initialColor {
                    cell.profilePictureImage.backgroundColor = color
                    cell.profileInitial.text = initialName
                    cell.profileName.text = name
                }
                
                return cell
            }
        }
        else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profile_activity_cell") {
                cell.textLabel?.text = activityMenu[indexPath.row]
                return cell
            }
        }
        else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profile_apple_cell") {
                cell.textLabel?.text = appleMenu[0]
                return cell
            }
        }
        else if indexPath.section == 3 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profile_toc_cell") {
                cell.textLabel?.text = tocMenu[indexPath.row]
                return cell
            }
        }
        else if indexPath.section == 4 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profile_logout_cell") {
                cell.textLabel?.text = logOutMenu[indexPath.row]
                cell.textLabel?.textColor = UIColor.systemRed
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "willMoveToEdit", sender: self)
            }
            else if indexPath.row == 1 {
                self.performSegue(withIdentifier: "willShowMenuFavorite", sender: self)
            }
            else if indexPath.row == 2 {
                self.performSegue(withIdentifier: "willShowArticleFavorite", sender: self)
            }
        }
        else if indexPath.section == 2 {
            self.performSegue(withIdentifier: "willShowApple", sender: self)
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0 {
                self.tocState = 0
            }
            else if indexPath.row == 1 {
                self.tocState = 1
            }
            else if indexPath.row == 2 {
                self.tocState = 2
            }
            self.performSegue(withIdentifier: "willShowTOC", sender: self)
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "Hapus Data & Keluar", message: "Data anda tidak dapat dikembalikan setelah dihapus, apakah anda yakin?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Ya, Hapus Data", style: .destructive, handler: { (_) in
                    self.deleteAllData()
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
        }
        
    }
    
    
    
}
