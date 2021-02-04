//
//  TOCController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 27/01/21.
//

import UIKit

class TOCController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var toc = [TOC]()
    var tocState = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        initVar()
        
    }
    
    func initVar(){
        switch tocState {
        case 0:
            self.navigationItem.title = "Syarat & Ketentuan"
            
            DefineTOC().fetchTOC { (toc) in
                self.toc = toc
                self.tableView.reloadData()
            }
        case 1:
            self.navigationItem.title = "Kebijakan Privasi"
            
            DefineTOC().fetchPolicies { (toc) in
                self.toc = toc
                self.tableView.reloadData()
            }
        case 2:
            self.navigationItem.title = "Licenses"
            
            DefineTOC().fetchLicense { (toc) in
                self.toc = toc
                self.tableView.reloadData()
            }
        default:
            self.navigationItem.title = "Syarat & Ketentuan"
            
            DefineTOC().fetchTOC { (toc) in
                self.toc = toc
                self.tableView.reloadData()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "toc_cell") as? TOCCell {
            let term = self.toc[indexPath.row]
            
            let attributedString = NSMutableAttributedString(string: term.body)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            cell.desc.attributedText = attributedString
            cell.title.text = term.title
            
            return cell
        }
        return UITableViewCell()
    }
    
    
    
}
