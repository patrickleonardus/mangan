//
//  ViewPagerController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 18/01/21.
//

import UIKit
import CarbonKit

class ViewPagerController: UIViewController {
    
    
    var carbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    var pageName = ["Tentang Makanan", "Bahan Makanan", "Cara Memasak"]
    var uiStyle: UIStyle = .light
    
    var desc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    
    func initData(){
        
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: pageName, delegate: self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        carbonTabSwipeNavigation.toolbar.isTranslucent = false
        
        
    }
    
}

extension ViewPagerController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        
        if let storyboard = storyboard {
            if index == 0 {
                return storyboard.instantiateViewController(withIdentifier: "about_recipe")
            }
            else if index == 1 {
                return storyboard.instantiateViewController(withIdentifier: "ingridient")
            }
            else if index == 2 {
                return storyboard.instantiateViewController(withIdentifier: "step_cook")
            }
        }
        
        
        return UIViewController()
    }
    
}
