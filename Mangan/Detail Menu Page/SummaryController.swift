//
//  SummaryController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 18/01/21.
//

import UIKit

class SummaryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var desc = ""
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadDesc(_:)), name: NSNotification.Name("desc"), object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    
    @objc func loadDesc(_ notification: Notification){
        
        desc = notification.userInfo?["desc"] as? String ?? "Tidak ada deskripsi"
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "about_recipe") as? AboutCell {
            
            let attributedString = NSMutableAttributedString(string: self.desc)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            cell.aboutLbl.attributedText = attributedString
            cell.aboutLbl.textAlignment = .justified
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}
