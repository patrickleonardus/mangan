//
//  IngridientsController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 18/01/21.
//

import UIKit

class IngridientsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var tableView: UITableView!
    
    var data = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        NotificationCenter.default.addObserver(self, selector: #selector(loadData(_:)), name: NSNotification.Name("ingridients"), object: nil) 
        
        NotificationCenter.default.post(name: NSNotification.Name("pre_ingridients"), object: nil)
       
    }
    
    @objc func loadData(_ notification: Notification){
        data = notification.userInfo?["ingridients"] as? [String] ?? ["Tidak ada bahan baku"]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        
        num = data.count
        
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ingridient") as? IngridientsCell {
            
            let ingridient = data[indexPath.row]
            
            let attributedString = NSMutableAttributedString(string: ingridient)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            cell.titleLbl.attributedText = attributedString
            cell.noLbl.text = "\(indexPath.row + 1)."
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}
