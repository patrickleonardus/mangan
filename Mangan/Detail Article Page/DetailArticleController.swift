//
//  DetailArticleController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 20/01/21.
//

import UIKit
import JGProgressHUD
import CoreData

class DetailArticleController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tag = ""
    var key = ""
    var articleFavoriteLists = [ArticleFavoriteList]()
    
    var detailArticle: DetailArticle?
    var hud = JGProgressHUD()
    var loveBtn = UIBarButtonItem()
    var uiStyle: UIStyle = .light
    
    var urlSession = URLSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
      
        hud.textLabel.text =  Const.loading[Int.random(in: 0...Const.loading.count-1)]
        
        let loveImg = UIImage(systemName: "heart.fill")
        loveBtn = UIBarButtonItem(image: loveImg, style: .plain, target: self, action: #selector(didPressLoveMenu))
        didEnableRightBarBtn(isEnable: false)
        
        self.navigationItem.rightBarButtonItem = loveBtn
        self.navigationItem.title = "Detail Artikel"
        
        onCheckInterfaceStyle()
        onRetrieveData()
        onFetchFavoriteList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.largeTitleDisplayMode = .never
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
    
    func onRetrieveData(){
        
        hud.show(in: self.view)
        if let url = URL(string: "\(Url.baseUrl)\(Url.articleDetail)/\(tag)/\(key)") {
            urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do{
                        let result = try  JSONDecoder().decode(ResultDetailArticle.self, from: data)
                        self.detailArticle = result.results
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.hud.dismiss()
                        }
                        
                        self.didEnableRightBarBtn(isEnable: true)
                        
                    } catch let jsonErr {
                        print(jsonErr)
                        self.hud.dismiss()
                        self.errorAlert()
                    }
                }
            }.resume()
        }
    }
    
    func onFetchFavoriteList(){
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
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    func errorAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Artikel Tidak Tersedia", message: "Maaf artikel yang anda pilih tidak tersedia untuk saat ini, silahkan coba kembali atau pilih artikel yang lain", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func didPressLoveMenu() {
        didEnableRightBarBtn(isEnable: false)
        if articleFavoriteLists.count != 0 {
            for index in 0...articleFavoriteLists.count-1{
                let menu = articleFavoriteLists[index]
                if let article = detailArticle {
                    if menu.title == article.title {
                        SnackBarCustom.make(in: self.view, message: "Artikel ini sudah ada pada Favorite List anda", duration: .lengthLong).show()
                        break
                    }
                    else {
                        if index == articleFavoriteLists.count-1 {
                            saveFavoriteMenu()
                            SnackBarCustom.make(in: self.view, message: "Artikel ini berhasil dimasukan kedalam Favorite List", duration: .lengthLong).show()
                        }
                    }
                }
            }
        }
        else {
            saveFavoriteMenu()
            SnackBarCustom.make(in: self.view, message: "Artikel ini berhasil dimasukan kedalam Favorite List", duration: .lengthLong).show()
        }
    }
    
    func saveFavoriteMenu(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let menuFavorite = NSEntityDescription.entity(forEntityName: "ArticleFavorite", in: managedContext) else {return}
        let insert = NSManagedObject(entity: menuFavorite, insertInto: managedContext)
        if let article = detailArticle {
            insert.setValue(article.thumb, forKey: "imageUrl")
            insert.setValue(article.title, forKey: "title")
            insert.setValue(self.key, forKey: "key")
            insert.setValue(self.tag, forKey: "tag")
        }
        do {
            try managedContext.save()
        } catch let error {
            fatalError("Error while saving to core data \n Detail: \n \(error)")
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

extension DetailArticleController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let article = detailArticle {
            if indexPath.section == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "detail_article_image") as? ImageDetailArticleCell{
                    cell.imageArticle?.sd_setImage(with: URL(string: article.thumb), completed: nil)
                    return cell
                }
            }
            else if indexPath.section == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "detail_article_title") as?  TitleDetailArticleCell{
                    cell.titleArticle.text = article.title
                    cell.authorArticle.text =  "Dibuat oleh: \(article.author)"
                    cell.dateArticle.text = "Diterbitkan: \(article.date_published)"
                    return cell
                }
            }
            else if indexPath.section == 2 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "detail_article_desc") as? DescDetailArticleCell{
                    let attributedString = NSMutableAttributedString(string: article.description)
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 8
                    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                    cell.descArticle.attributedText = attributedString
                    cell.descArticle.textAlignment = .justified
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
}
