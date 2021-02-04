//
//  ExploreController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 19/01/21.
//

import UIKit
import CoreData
import SDWebImage
import JGProgressHUD

class ExploreController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cover: UIView!
    
    
    let urlSession = URLSession.shared
    var hud = JGProgressHUD()
    var generalArticle: [GeneralArticle]?
    var listArticle: [ListArticle]?
    var listMenu: [Menu]?
    var isArticleLoad = false
    var isMenuLoad = false
    var currRow = 0
    var tagChoose = ""
    var keyChoose = ""
    var titleChoose = ""
    var initial = ""
    var name = ""
    var randomColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.tableFooterView = UIView()
        
        hud.textLabel.text = Const.loading[Int.random(in: 0...Const.loading.count-1)]
        hud.show(in: self.view)
        
        randomColor = onGenerateRandomPastelColor() ?? UIColor()
        
        onRetrieveGeneralArticle()
        onRetrieveCategoryRecipe()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.largeTitleDisplayMode = .always
        
        onCreateNavigationBar()
    }
    
    func onRetrieveGeneralArticle(){
        
        if let url = URL(string: "\(Url.baseUrl)\(Url.categoryArticle)") {
            urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do{
                        let resultArticle = try JSONDecoder().decode(ResultGeneralArticle.self, from: data)
                        self.generalArticle = resultArticle.results
                        
                        if let genArt = self.generalArticle {
                            self.onPickArticleCategory(generalArticle: genArt)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }catch let jsonErr {
                        print(jsonErr)
                        self.errorAlert()
                    }
                }
            }.resume()
        }
    }
    
    func onPickArticleCategory(generalArticle: [GeneralArticle]){
        
        var key = ""
        var title = ""
        var category = GeneralArticle(title: title, key: key)
        
        let random = Int.random(in: 0...generalArticle.count-1)
        
        key = generalArticle[random].key
        title = generalArticle[random].title
        
        self.tagChoose = key
        
        category = GeneralArticle(title: title, key: key)
        
        repeat{
            onRetrieveListArticle(category: category)
        } while category.key == ""
        
    }
    
    func onRetrieveListArticle(category: GeneralArticle){
        if let url = URL(string: "\(Url.baseUrl)\(Url.categoryArticle)/\(category.key)") {
            urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do{
                        let result = try JSONDecoder().decode(ResultListArticle.self, from: data)
                        self.listArticle = result.results
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        
                        self.isArticleLoad = true
                        self.onCheckData()
                        
                    } catch let jsonErr {
                        print(jsonErr)
                        self.errorAlert()
                    }
                }
            }.resume()
        }
    }
    
    func onRetrieveCategoryRecipe(){
        if let url = URL(string: "\(Url.baseUrl)\(Url.categoryRecipe)") {
            urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do{
                        let menus = try JSONDecoder().decode(MenuResult.self, from: data)
                        self.listMenu = menus.results
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                        self.isMenuLoad = true
                        self.onCheckData()
                        
                    }catch let jsonErr {
                        print(jsonErr)
                        self.errorAlert()
                    }
                }
            }.resume()
        }
    }
    
    func onCheckData(){
        if isMenuLoad && isArticleLoad {
            DispatchQueue.main.async {
                self.hud.dismiss()
                self.cover.isHidden = true
                
                _ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.isScrollToNext), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func isScrollToNext(){
        
        if let data = listArticle?.count {
            
            if currRow<data{
                let indexPath = IndexPath(row: currRow, section: 0)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                currRow+=1
            }
            else if currRow == data{
                currRow = 0
                collectionView.scrollToItem(at: IndexPath(row: currRow, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "willMoveToDetailArticle" {
            if let dest = segue.destination as? DetailArticleController {
                dest.tag = self.tagChoose
                dest.key = self.keyChoose
            }
        }
        else if segue.identifier == "willShowListMenu" {
            if let dest = segue.destination as? ListMenuController {
                dest.key = self.keyChoose
                dest.tag = self.tagChoose
            }
        }
        else if segue.identifier == "willMoveToListArticle" {
            if let dest = segue.destination as? ListArticleController {
                dest.key = self.keyChoose
                dest.tag = self.tagChoose
                dest.titleNav = self.titleChoose
            }
        }
        else if segue.identifier == "willMoveToProfile" {
            if let dest = segue.destination as? ProfileController {
                dest.initialColor = randomColor
                dest.initialName = self.initial
                dest.name = self.name
            }
        }
    }
    
    func errorAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Terjadi Kesalahan", message: "Tidak dapat memuat konten, mohon periksa jaringan dan koneksi internet anda", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onCreateNavigationBar(){
        
        /// setup initial char
        name = fetchName()
        
        if name != "" {
            let whitespace = NSCharacterSet.whitespaces
            let range = name.rangeOfCharacter(from: whitespace)
            
            if range != nil {
                let firstChar = name.components(separatedBy: " ")[0].first
                let secondChar = name.components(separatedBy: " ")[1].first
                initial = "\(firstChar?.uppercased() ?? "")\(secondChar?.uppercased() ?? "")"
            }
            else {
                let firstChar = name.components(separatedBy: " ")[0].first
                initial = "\(firstChar?.uppercased() ?? "")"
            }
            
            /// profile picture embedded in navigation bar
            let profileView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 28, height: 28))
            profileView.layer.cornerRadius = profileView.frame.height/2
            profileView.backgroundColor = randomColor
            
            let labelInitial = UILabel()
            labelInitial.text = initial
            labelInitial.textColor = .black
            labelInitial.textAlignment = .center
            labelInitial.font = UIFont.boldSystemFont(ofSize: 13)
            labelInitial.sizeToFit()
            labelInitial.center.x = profileView.center.x
            labelInitial.center.y = profileView.center.y
            
            profileView.addSubview(labelInitial)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(willOpenProfile))
            profileView.addGestureRecognizer(tap)
            
            let menuBarItem = UIBarButtonItem(customView: profileView)
            menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 28).isActive = true
            menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 28).isActive = true
            self.navigationItem.rightBarButtonItem = menuBarItem
            
        }
    }
    
    func fetchName() -> String{
        var persons = ""
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserData")
        do{
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            results.forEach { (result) in
                persons = "\(result.value(forKey: "name") ?? "")"
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return persons
    }
    
    func onGenerateRandomPastelColor() -> UIColor? {
        
        var red = (CGFloat(arc4random() % 256)) / 256
        var green = (CGFloat(arc4random() % 256)) / 256
        var blue = (CGFloat(arc4random() % 256)) / 256
        
        let mixRed: CGFloat = 1 + 0xad / 256
        let mixGreen: CGFloat = 1 + 0xd8 / 256
        let mixBlue: CGFloat = 1 + 0xe6 / 256
        red = (red + mixRed) / 3
        green = (green + mixGreen) / 3
        blue = (blue + mixBlue) / 3
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    @objc func willOpenProfile(){
        self.performSegue(withIdentifier: "willMoveToProfile", sender: self)
    }
    
}


extension ExploreController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width - 40
        let height = collectionView.frame.height - 30
        
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var num = 0
        
        if let articles = listArticle {
            num = articles.count
        }
        
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "explore_article", for: indexPath) as? ExploreArticleCell {
            
            cell.layer.cornerRadius = 10
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = .zero
            cell.layer.shadowOpacity = 0.5
            cell.layer.shadowRadius = 3.5
            cell.layer.masksToBounds = false
            cell.imageArticle.layer.cornerRadius = 10
            
            if let articles = listArticle {
                let article = articles[indexPath.row]
                if let url = URL(string: article.thumb) {
                    cell.imageArticle.sd_setImage(with: url, completed: nil)
                    cell.titleArticle.text = article.title
                }
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let articles = listArticle {
            let article = articles[indexPath.row]
            self.keyChoose = article.key
            self.performSegue(withIdentifier: "willMoveToDetailArticle", sender: self)
        }
    }
    
}

extension ExploreController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var num = 0
        
        if section == 0 {
            if let count = listMenu?.count {
                num = count
            }
        }
        else if section == 1 {
            if let count = generalArticle?.count {
                num = count
            }
        }
        
        return num
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title = ""
        
        if section == 0 {
            title = "Kumpulan Resep"
        }
        else if section == 1 {
            title = "Artikel Seru"
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "explore_menu_cell") {
                
                if let menus = listMenu {
                    let menu = menus[indexPath.row]
                    cell.textLabel?.text = menu.category
                }
                return cell
            }
        }
        else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "explore_article_cell") {
                
                if let genArt = self.generalArticle {
                    let article = genArt[indexPath.row]
                    cell.textLabel?.text = article.title
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if indexPath.section == 0 {
            if let menus = listMenu {
                let menu = menus[indexPath.row]
                self.keyChoose = menu.key
                self.tagChoose = menu.category
                self.performSegue(withIdentifier: "willShowListMenu", sender: self)
            }
        }
        else if indexPath.section == 1 {
            if let genArt = self.generalArticle {
                let article = genArt[indexPath.row]
                self.keyChoose = article.key
                self.titleChoose = article.title
                self.performSegue(withIdentifier: "willMoveToListArticle", sender: self)
            }
        }
        
    }
}
