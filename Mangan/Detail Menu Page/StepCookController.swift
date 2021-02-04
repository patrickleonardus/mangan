//
//  StepCookController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 18/01/21.
//

import UIKit

class StepCookController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var step = [""]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadData(_:)), name: NSNotification.Name("step"), object: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name("pre_step"), object: nil)
        
    }
    
    @objc func loadData(_ notification: Notification){
        step = notification.userInfo?["step"] as? [String] ?? ["Tidak ada step"]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var num = 0
        
        num = step.count
        
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "step_cell") as? StepCell {
            
            let steps = step[indexPath.row]
            let cleanStep = String(steps.dropFirst(2))
            
            let attributedString = NSMutableAttributedString(string: cleanStep)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            
            cell.titleStep.attributedText = attributedString
            cell.stepLbl.text = "\(indexPath.row + 1)"
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}
