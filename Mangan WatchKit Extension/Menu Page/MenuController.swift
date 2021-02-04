//
//  InterfaceController.swift
//  Mangan WatchKit Extension
//
//  Created by Patrick Leonardus on 14/01/21.
//

import WatchKit
import WatchConnectivity
import EMTLoadingIndicator


class MenuController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var loadingImage: WKInterfaceImage!
    @IBOutlet weak var tableView: WKInterfaceTable!
    @IBOutlet weak var validLabel: WKInterfaceLabel!
    var indicator: EMTLoadingIndicator?
    
    var menuWatchLists = [MenuWatch]()
    var menuChoosen: MenuWatch?
    
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session.delegate = self
        session.activate()
        
        tableView.setHidden(true)
        validLabel.setHidden(true)
        
        indicator = EMTLoadingIndicator(interfaceController: self, interfaceImage: loadingImage!, width: 40, height: 40, style: .line)
        indicator?.showWait()
        
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        let menuTitle = applicationContext["title"] as? String ?? "N/A"
        let menuImgUrl = applicationContext["imageUrl"] as? String ?? "N/A"
        let menuWatchUrl = applicationContext["menuUrl"] as? String ?? "N/A"
        
        if menuWatchLists.count != 0 {
            for index in 0...menuWatchLists.count-1 {
                if menuTitle == menuWatchLists[index].title {
                    break
                }
                else {
                    if index == menuWatchLists.count-1 {
                        menuWatchLists.append(MenuWatch(imageUrl: menuImgUrl, menuUrl: menuWatchUrl, title: menuTitle))
                        setTableView()
                    }
                }
            }
        }
        else {
            menuWatchLists.append(MenuWatch(imageUrl: menuImgUrl, menuUrl: menuWatchUrl, title: menuTitle))
            setTableView()
        }
        
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if !session.isReachable {
            self.indicator?.hide()
            self.validLabel.setHidden(false)
        }
        else {
            session.sendMessage(["ask_data":"ask_data"], replyHandler: nil) { (error) in
                print("\n\n\nError Request Data:\n\(error)")
                self.indicator?.hide()
                self.validLabel.setHidden(false)
            }
        }
    }
    
    func setTableView(){
        
        indicator?.hide()
        tableView.setHidden(false)
        validLabel.setHidden(true)
        
        menuWatchLists.reverse()
        tableView.setNumberOfRows(menuWatchLists.count, withRowType: "home_menu_cell")
        for index in 0...menuWatchLists.count-1 {
            if let cell = tableView.rowController(at: index) as? MenuCell {
                let menu = menuWatchLists[index]
                cell.menuLabel.setText(menu.title)
                cell.menuImage.setImageWithUrl(url: menu.imageUrl)
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        menuChoosen = menuWatchLists[rowIndex]
        self.pushController(withName: "detail_menu_page", context: menuChoosen)
    }
    
}


extension WKInterfaceImage {
    @discardableResult
    func setImageWithUrl(url:String, scale: CGFloat = 1.0) -> WKInterfaceImage? {
        if let urlData = URL(string: url) {
            URLSession.shared.dataTask(with: urlData) { (data, response, error) in
                if (data != nil && error == nil) {
                    let image = UIImage(data: data!, scale: scale)
                    DispatchQueue.main.async {
                        self.setImage(image)
                    }
                }
            }.resume()
        }
        return self
    }
}
