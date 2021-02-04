//
//  DetailMenuController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 15/01/21.
//

import UIKit
import CoreData
import SDWebImage
import JGProgressHUD
import SnackBar_swift
import WatchConnectivity

class DetailMenuController: UIViewController {
    
    @IBOutlet weak var imageRecipe: UIImageView!
    @IBOutlet weak var titleRecipe: UILabel!
    @IBOutlet weak var madeByRecipe: UILabel!
    @IBOutlet weak var publishedRecipe: UILabel!
    @IBOutlet weak var viewPager: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var portionLabel: UILabel!
    @IBOutlet weak var cover: UIView!
    
    var key = ""
    var imageUrl = ""
    var menuTitle = ""
    var menuUrl = ""
    var detailRecipe: DetailRecipe?
    var ingridients = [""]
    var step = [""]
    var uiStyle: UIStyle = .light
    var menuFavoriteLists = [MenuFavoriteList]()
    var watchMenu = [MenuWatch]()
    var isFavoritePressed = false
    var isMenuPressed = false
    var wcSession = WCSession.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onCheckInterfaceStyle()
        initData()
        onRetrieveData()
        onFetchFavoriteList()
        onFetchWatchMenu()
        
    }
    
    func initData(){
        
        cover.isHidden = false
        
        let moreImg = UIImage(systemName: "ellipsis")
        let moreBtn = UIBarButtonItem(image: moreImg, style: .plain, target: self, action: #selector(didPressMore(_:)))
        
        didEnableRightBarBtn(isEnable: false)
        
        self.navigationItem.rightBarButtonItem = moreBtn
        self.navigationItem.title = "Detail Resep"
        self.navigationItem.largeTitleDisplayMode = .never
        
        wcSession.delegate = self
        wcSession.activate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(observePreIngredient), name: NSNotification.Name("pre_ingridients"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(observePreStep), name: NSNotification.Name("pre_step"), object: nil)
        
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
    
    private func onRetrieveData(){
        
        let hud = JGProgressHUD()
        hud.textLabel.text = Const.loading[Int.random(in: 0...Const.loading.count-1)]
        hud.show(in: self.view)
        
        self.menuUrl = "\(Url.baseUrl)\(Url.recipesDetail)/\(key)"
        guard let url = URL(string: self.menuUrl) else {return}
        
        URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            guard let data = data else {return}
            do{
                self.detailRecipe = try JSONDecoder().decode(DetailRecipe.self, from: data)
                
                if let recipe = self.detailRecipe {
                    self.ingridients = recipe.results.ingredient
                    self.step = recipe.results.step
                    self.menuTitle = recipe.results.title
                    
                    DispatchQueue.main.async {
                        imageRecipe.sd_setImage(with: URL(string: imageUrl) , completed: nil)
                        titleRecipe.text = self.menuTitle
                        madeByRecipe.text = "Dibuat oleh : \(recipe.results.author.user)"
                        publishedRecipe.text = "Dimuat : \(recipe.results.author.datePublished)"
                        difficultyLabel.text = recipe.results.dificulty
                        timeLabel.text = recipe.results.times
                        portionLabel.text = recipe.results.servings
                    }
                    
                    didEnableRightBarBtn(isEnable: true)
                    
                    NotificationCenter.default.post(name: NSNotification.Name("desc"), object: nil, userInfo: ["desc":recipe.results.desc])
                    
                }
                
                hud.dismiss()
                
                hideCover(hide: true)
                
            } catch let jsonError {
                print(jsonError)
                
                hud.dismiss()
                self.errorAlert()
            }
        }.resume()
    }
    
    @objc func observePreIngredient(){
        NotificationCenter.default.post(name: NSNotification.Name("ingridients"), object: nil, userInfo: ["ingridients":self.ingridients])
    }
    
    @objc func observePreStep(){
        NotificationCenter.default.post(name: NSNotification.Name("step"), object: nil, userInfo: ["step":self.step])
    }
    
    func onFetchFavoriteList(){
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
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func onFetchWatchMenu(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchMenu")
        do {
            let favoriteLists = try managedContext.fetch(fetchRequest)
            
            favoriteLists.forEach { (favorite) in
                
                let imgUrl = favorite.value(forKey: "imageUrl") as? String ?? ""
                let menuUrl = favorite.value(forKey: "menuUrl") as? String ?? ""
                let title = favorite.value(forKey: "title") as? String ?? ""
                
                watchMenu.append(MenuWatch(imageUrl: imgUrl, menuUrl: menuUrl, title: title))
                watchMenu.reverse()
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func didPressLoveMenu() {
        self.isFavoritePressed = true
        if menuFavoriteLists.count != 0 {
            for index in 0...menuFavoriteLists.count-1{
                let menu = menuFavoriteLists[index]
                if menu.title == menuTitle {
                    SnackBarCustom.make(in: self.view, message: "Menu ini sudah ada pada Favorite List anda", duration: .lengthLong).show()
                    break
                }
                else {
                    if index == menuFavoriteLists.count-1 {
                        saveFavoriteMenu()
                        SnackBarCustom.make(in: self.view, message: "Menu ini berhasil dimasukan kedalam Favorite List", duration: .lengthLong).show()
                    }
                }
            }
        }
        else {
            saveFavoriteMenu()
            SnackBarCustom.make(in: self.view, message: "Menu ini berhasil dimasukan kedalam Favorite List", duration: .lengthLong).show()
        }
    }
    
    @objc func didPressMore(_ sender: UIBarButtonItem){
        let alert = UIAlertController()
        let openInWatchAction = UIAlertAction(title: "Buka menu di watch", style: .default) { (_) in
            self.isMenuPressed = true
            if self.watchMenu.count != 0 {
                for i in 0...self.watchMenu.count-1{
                    let menu = self.watchMenu[i]
                    if menu.title == self.menuTitle {
                        SnackBarCustom.make(in: self.view, message: "Menu ini sudah ada di apple watch", duration: .lengthShort).show()
                        break
                    }
                    else {
                        if i == self.watchMenu.count-1 {
                            self.saveWatchMenu()
                            SnackBarCustom.make(in: self.view, message: "Mengirimkan menu ke apple watch", duration: .lengthLong).show()
                        }
                    }
                }
            }
            else {
                self.saveWatchMenu()
                SnackBarCustom.make(in: self.view, message: "Mengirimkan menu ke apple watch", duration: .lengthLong).show()
            }
        }
        let addToFavorite = UIAlertAction(title: "Tambahkan menu ini ke daftar favorit", style: .default) { (_) in
            self.didPressLoveMenu()
        }
        alert.addAction(openInWatchAction)
        alert.addAction(addToFavorite)
        alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
        
        if isFavoritePressed {
            addToFavorite.isEnabled = false
        }
        else {
            addToFavorite.isEnabled = true
        }
        
        if isMenuPressed {
            openInWatchAction.isEnabled = false
        }
        else {
            openInWatchAction.isEnabled = true
        }
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveFavoriteMenu(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let menuFavorite = NSEntityDescription.entity(forEntityName: "MenuFavorite", in: managedContext) else {return}
        let insert = NSManagedObject(entity: menuFavorite, insertInto: managedContext)
        insert.setValue(self.imageUrl, forKey: "imageUrl")
        insert.setValue(self.key, forKey: "key")
        insert.setValue(self.menuTitle, forKey: "title")
        do {
            try managedContext.save()
        } catch let error {
            fatalError("Error while saving to core data \n Detail: \n \(error)")
        }
    }
    
    func saveWatchMenu(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let menuFavorite = NSEntityDescription.entity(forEntityName: "WatchMenu", in: managedContext) else {return}
        let insert = NSManagedObject(entity: menuFavorite, insertInto: managedContext)
        insert.setValue(self.imageUrl, forKey: "imageUrl")
        insert.setValue(self.menuUrl, forKey: "menuUrl")
        insert.setValue(self.menuTitle, forKey: "title")
        do {
            try managedContext.save()
            self.onRetrieveWatchMenu()
        } catch let error {
            fatalError("Error while saving to core data \n Detail: \n \(error)")
        }
    }
    
    @objc func onRetrieveWatchMenu(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WatchMenu")
        do {
            let favoriteLists = try managedContext.fetch(fetchRequest)
            
            favoriteLists.forEach { (favorite) in
                
                let imgUrl = favorite.value(forKey: "imageUrl") as? String ?? ""
                let menuUrl = favorite.value(forKey: "menuUrl") as? String ?? ""
                let title = favorite.value(forKey: "title") as? String ?? ""
                
                do{
                    try wcSession.updateApplicationContext(["imageUrl":imgUrl, "menuUrl":menuUrl, "title":title])
                } catch let err {
                    print("\n\n\nError update application context: \n\(err.localizedDescription)")
                }
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    func hideCover(hide: Bool){
        DispatchQueue.main.async {
            if hide {
                self.cover.isHidden = true
            }else {
                self.cover.isHidden = false
            }
        }
    }
    
    func errorAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Menu Tidak Tersedia", message: "Maaf menu yang anda pilih tidak tersedia sekarang, silahkan coba kembali atau pilih menu yang lain", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didEnableRightBarBtn(isEnable: Bool){
        if isEnable {
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
        else {
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
}

extension DetailMenuController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
