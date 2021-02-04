//
//  ListArticleController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 20/01/21.
//

import UIKit
import JGProgressHUD

class ListArticleController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var key = ""
    var tag = ""
    var titleNav = ""
    var listArticle: [ListArticle]?
    var uiStyle: UIStyle = .light
    var hud = JGProgressHUD()
    var urlSession = URLSession.shared
    var chooseKey = ""
    var chooseTag = ""
    
    let estimateWidth = 160.0
    let cellMarginSize = 16.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        self.hud.textLabel.text = Const.loading[Int.random(in: 0...Const.loading.count-1)]
        self.navigationItem.title = titleNav
        
        onRetrieveArticle()
        onCheckInterfaceStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGridView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flow?.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow?.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func onRetrieveArticle(){
        hud.show(in: self.view)
        
        if let url = URL(string: "\(Url.baseUrl)\(Url.categoryArticle)/\(key)") {
            urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do{
                        let recipes = try JSONDecoder().decode(ResultListArticle.self, from: data)
                        self.listArticle = recipes.results
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.hud.dismiss()
                        }
                        
                    }catch let jsonErr {
                        print(jsonErr)
                        self.hud.dismiss()
                        self.errorAlert()
                    }
                }
            }.resume()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "willShowDetailArticle" {
            if let destination = segue.destination as? DetailArticleController {
                destination.tag = self.key
                destination.key = self.chooseKey
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
    
}

extension ListArticleController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listArticle?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "list_article_menu", for: indexPath) as? ListArticleCell{
            
            if uiStyle == .light {
                cell.coverView.backgroundColor = UIColor.white
                cell.coverView.layer.shadowColor = UIColor.black.cgColor
                cell.coverView.layer.shadowOffset = .zero
                cell.coverView.layer.shadowRadius = 3
                cell.coverView.layer.shadowOpacity = 0.3
            }
            else {
                cell.coverView.backgroundColor = UIColor.systemGray5
            }
            
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = false
            cell.imageArticle.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.imageArticle.layer.cornerRadius = 10
            cell.imageArticle.image = UIImage(named: "placeholder")
            cell.coverView.layer.cornerRadius = 10
            
            if let list = listArticle {
                let article = list[indexPath.row]
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
        if let list = listArticle {
            let article = list[indexPath.row]
            self.chooseKey = article.key
            self.chooseTag = article.tags
            self.performSegue(withIdentifier: "willShowDetailArticle", sender: self)
        }
        
    }
    
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
