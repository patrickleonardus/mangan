//
//  ListMenuController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 20/01/21.
//

import UIKit
import JGProgressHUD

class ListMenuController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cover: UIView!
    
    var key = ""
    var tag = "Daftar Menu"
    var choosenKey = ""
    var choosenUrl = ""
    var urlSession = URLSession.shared
    var recipesList: [Results]?
    var uiStyle: UIStyle = .light
    var hud = JGProgressHUD()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = tag
        self.hud.textLabel.text = Const.loading[Int.random(in: 0...Const.loading.count-1)]
        
        onRetrieveList()
        onCheckInterfaceStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    
    func onRetrieveList(){
        
        hud.show(in: self.view)
        
        if let url = URL(string: "\(Url.baseUrl)\(Url.categoryRecipe)/\(key)") {
            urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do{
                        let recipes = try JSONDecoder().decode(Recipes.self, from: data)
                        self.recipesList = recipes.results
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.hud.dismiss()
                            self.cover.isHidden = true
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
        if segue.identifier == "willMoveToDetailMenu" {
            if let destination = segue.destination as? DetailMenuController {
                destination.key = self.choosenKey
                destination.imageUrl = self.choosenUrl
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

extension ListMenuController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipesList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "list_menu_category") as? SearchMenuCell{
            
            if let list = recipesList {
                let recipe = list[indexPath.row]
                if let url = recipe.thumb{
                    cell.titleRecipe.text = recipe.title
                    cell.timeRecipe.text = "Waktu masak: \(recipe.times ?? "")"
                    cell.difficultyRecipe.text = "Kesulitan: \(recipe.dificulty ?? "")"
                    cell.imageRecipe.sd_setImage(with: URL(string: url), completed: nil)
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let list = recipesList {
            let recipe = list[indexPath.row]
            guard let url = recipe.thumb else {return}
            guard let keyRecipe = recipe.key else {return}
            
            self.choosenKey = keyRecipe
            self.choosenUrl = url
            
            self.performSegue(withIdentifier: "willMoveToDetailMenu", sender: self)
        }
        
    }
    
}
