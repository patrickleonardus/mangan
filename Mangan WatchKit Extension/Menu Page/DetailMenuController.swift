//
//  DetailMenuController.swift
//  Mangan WatchKit Extension
//
//  Created by Patrick Leonardus on 26/01/21.
//

import UIKit
import WatchKit
import EMTLoadingIndicator

class DetailMenuController: WKInterfaceController {
    
    @IBOutlet weak var menuGroup: WKInterfaceGroup!
    @IBOutlet weak var menuImage: WKInterfaceImage!
    @IBOutlet weak var menuTitle: WKInterfaceLabel!
    @IBOutlet weak var difficultyLabel: WKInterfaceLabel!
    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    @IBOutlet weak var portionLabel: WKInterfaceLabel!
    @IBOutlet weak var imageLoading: WKInterfaceImage!
    
    var menuWatch: MenuWatch?
    var urlSession = URLSession.shared
    var ingridient: [String]?
    var step: [String]?
    var indicator: EMTLoadingIndicator?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        indicator = EMTLoadingIndicator(interfaceController: self, interfaceImage: imageLoading!, width: 40, height: 40, style: .line)
        self.showLoading()
        
        self.menuWatch = context as? MenuWatch
        if let menuUrl = self.menuWatch?.menuUrl {
            if let url = URL(string: menuUrl) {
                urlSession.dataTask(with: url) { (data, response, error) in
                    if error == nil {
                        if let data = data {
                            do{
                                let recipe = try JSONDecoder().decode(Recipe.self, from: data)
                                let imgUrl = self.menuWatch?.imageUrl ?? ""
                                self.ingridient = recipe.results.ingredient
                                self.step = recipe.results.step
                                
                                DispatchQueue.main.async {
                                    self.menuTitle.setText(recipe.results.title)
                                    self.difficultyLabel.setText(recipe.results.dificulty)
                                    self.timeLabel.setText(recipe.results.times)
                                    self.portionLabel.setText(recipe.results.servings)
                                    self.menuImage.setImageWithUrl(url: imgUrl)
                                    self.hideLoading()
                                    self.menuGroup.setHidden(false)
                                }
                                
                            } catch let error {
                                self.hideLoading()
                                print("Error while decode json: \(error.localizedDescription)")
                            }
                        }
                    }
                    else {
                        self.hideLoading()
                        print("Error while fetching data: \(String(describing: error?.localizedDescription))")
                    }
                }.resume()
            }
        }
    }
    
    func showLoading(){
        self.imageLoading.setHidden(false)
        self.indicator?.showWait()
    }

    func hideLoading(){
        self.imageLoading.setHidden(true)
        self.indicator?.hide()
    }
    
    @IBAction func ingridientBtn() {
        self.pushController(withName: "ingridient_page", context: self.ingridient)
    }
    
    @IBAction func stepBtn() {
        self.pushController(withName: "step_page", context: self.step)
    }
    
}
