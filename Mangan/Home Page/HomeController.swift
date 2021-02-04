//
//  ViewController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 14/01/21.
//

import UIKit
import SDWebImage
import JGProgressHUD
import CoreData
import WatchConnectivity

class HomeController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    let hud = JGProgressHUD()
    let urlSession = URLSession.shared
    
    let estimateWidth = 160.0
    let cellMarginSize = 16.0
    
    var wcSession = WCSession.default
    var recipes: Recipes?
    var searchRecipes: SearchRecipes?
    var chooseKey = ""
    var chooseImageUrl = ""
    var initial = ""
    var name = ""
    var uiStyle: UIStyle = .light
    var randomColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    var isLoadedFromWidget = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Cari Resep"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        hud.textLabel.text = Const.loading[Int.random(in: 0...Const.loading.count-1)]
        
        randomColor = onGenerateRandomPastelColor() ?? UIColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLaunchFromWidget), name: NSNotification.Name("widget"), object: nil)
        
        onCheckInterfaceStyle()
        onRetrieveData()
        setupGridView()
        
    }
    
    @objc func didLaunchFromWidget(notifiaction: NSNotification){
        if !isLoadedFromWidget{
            self.isLoadedFromWidget = true
            self.chooseKey = notifiaction.userInfo?["key"] as? String ?? ""
            self.chooseImageUrl = notifiaction.userInfo?["imageUrl"] as? String ?? ""
            self.performSegue(withIdentifier: "willMoveToDetailMenu", sender: self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.isLoadedFromWidget = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.largeTitleDisplayMode = .always
        
        onCheckLogin()
        onCreateNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        switch traitCollection.userInterfaceStyle {
        case .light:
            uiStyle = .light
            self.collectionView.reloadData()
        case .dark:
            uiStyle = .dark
            self.collectionView.reloadData()
        default:
            uiStyle = .light
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "willMoveToDetailMenu" {
            if let dest = segue.destination as? DetailMenuController {
                dest.key = self.chooseKey
                dest.imageUrl = self.chooseImageUrl
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
    
    func onCheckInterfaceStyle(){
        if self.traitCollection.userInterfaceStyle == .light {
            uiStyle = .light
        }
        else {
            uiStyle = .dark
        }
    }
    
    private func onRetrieveData(){
        
        hud.show(in: self.view)
        
        if let url = URL(string: "\(Url.baseUrl)\(Url.randomRecipes)") {
            urlSession.dataTask(with: url) { (data, response, error) in
                guard let data = data else {return}
                do{
                    self.recipes = try JSONDecoder().decode(Recipes.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.hud.dismiss()
                    }
                    
                }catch let jsonErr{
                    print(jsonErr)
                    self.hud.dismiss()
                    self.errorAlert()
                }
            }.resume()
        }
    }
    
    private func onSearchData(searchKey: String){
        
        hud.show(in: self.view)
        
        if let searchUrl = URL(string: "\(Url.baseUrl)\(Url.search)\(searchKey)") {
            urlSession.dataTask(with: searchUrl) { (data, response, error) in
                guard let data = data else  {return}
                do{
                    self.searchRecipes = try JSONDecoder().decode(SearchRecipes.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.hud.dismiss()
                    }
                    
                }catch let jsonErr {
                    print(jsonErr)
                    self.hud.dismiss()
                    self.errorAlert()
                }
            }.resume()
        }
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flow?.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow?.minimumLineSpacing = CGFloat(self.cellMarginSize)
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
    
    func onCheckLogin(){
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        
        if !isLogin {
            self.performSegue(withIdentifier: "willMoveToAuth", sender: self)
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
    
    @objc func willOpenProfile(){
        self.performSegue(withIdentifier: "willMoveToProfile", sender: self)
    }
    
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var num = 0
        
        if let numOfItem = recipes?.results?.count{
            num = numOfItem
        }
        
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "home_menu_cell", for: indexPath) as? RecipesMenuCell {
            
            if uiStyle == .light {
                cell.backgroundColor = UIColor.white
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = .zero
                cell.layer.shadowRadius = 3
                cell.layer.shadowOpacity = 0.3
                
            }
            else {
                cell.backgroundColor = UIColor.systemGray5
            }
            
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = false
            cell.recipeImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.recipeImage.layer.cornerRadius = 10
            cell.recipeImage.image = UIImage(named: "placeholder")
            
            if let recipe = recipes {
                if let result = recipe.results?[indexPath.row] {
                    if let imageUrl = result.thumb {
                        cell.recipeName.text = result.title
                        cell.recipeTime.text = result.times
                        cell.recipePortion.text = result.portion
                        cell.recipeImage.sd_setImage(with: URL(string: imageUrl), completed: nil)
                    }
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let recipe = self.recipes {
            if let result = recipe.results?[indexPath.row] {
                guard let key = result.key else {return}
                guard let url = result.thumb else {return}
                self.chooseKey = key
                self.chooseImageUrl = url
                self.performSegue(withIdentifier: "willMoveToDetailMenu", sender: self)
            }
        }
    }
    
}

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.calculateWidth()
        return CGSize(width: width, height: width + 80)
    }
    
    func calculateWidth() -> CGFloat{
        
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width) / estimatedWidth)
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
    
}

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var num = 0
        
        if let numOfRows = searchRecipes?.results?.count {
            num = numOfRows
        }
        
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "search_menu") as? SearchMenuCell {
            if let recipe = searchRecipes {
                if let result = recipe.results?[indexPath.row] {
                    if let imgUrl = result.thumb {
                        cell.imageRecipe.sd_setImage(with: URL(string: imgUrl), completed: nil)
                        cell.titleRecipe.text = result.title
                        cell.timeRecipe.text = result.times
                        cell.difficultyRecipe.text = result.difficulty
                    }
                }
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let recipe = self.searchRecipes {
            if let result = recipe.results?[indexPath.row] {
                guard let key = result.key else {return}
                guard let url = result.thumb else {return}
                self.chooseKey = key
                self.chooseImageUrl = url
                self.performSegue(withIdentifier: "willMoveToDetailMenu", sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}

extension HomeController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.setEmptyMessage("Silahkan cari resep yang anda butuhkan dan klik search")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.searchTextField.text {
            if !searchText.isEmpty {
                tableView.isHidden = false
            }
            else {
                tableView.isHidden = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        tableView.restore()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        tableView.restore()
        
        if let searchText = searchBar.text {
            onSearchData(searchKey: searchText)
        }
    }
}

enum UIStyle {
    case light
    case dark
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let messageLabel = UILabel(frame: CGRect(x: 0, y: height/4, width: width, height: height))
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.boldSystemFont(ofSize: 17)
        messageLabel.sizeToFit()
        messageLabel.center.x = wrapper.center.x
        
        wrapper.addSubview(messageLabel)
        self.backgroundView = wrapper
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

