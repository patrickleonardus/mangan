//
//  EditProfileController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 21/01/21.
//

import UIKit
import CoreData

class EditProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var saveBtn = UIBarButtonItem()
    
    var name = ""
    var newName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Edit Profile"
        let cancelBtn = UIBarButtonItem(title: "Batal", style: .plain, target: self, action: #selector(dismissVC))
        saveBtn = UIBarButtonItem(title: "Simpan", style: .done, target: self, action: #selector(save))
        saveBtn.isEnabled = false
        self.navigationItem.leftBarButtonItem = cancelBtn
        self.navigationItem.rightBarButtonItem = saveBtn
        
    }
    
    @objc func dismissVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        if newName != "" {
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "UserData", in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = entity
            let predicate = NSPredicate(format: "(name = %@)", self.name)
            request.predicate = predicate
            do {
                let results =
                    try managedContext.fetch(request)
                let objectUpdate = results[0] as! NSManagedObject
                objectUpdate.setValue(self.newName, forKey: "name")
                do {
                    try managedContext.save()
                    self.dismiss(animated: true, completion: nil)
                }catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        else {
            errorAlert()
        }
    }
    
    func errorAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Nama Kosong", message: "Pastikan nama terisi", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "edit_profile_cell") as? EditProfileCell {
            cell.profileNameTF.text = self.name
            cell.profileNameTF.becomeFirstResponder()
            cell.profileNameTF.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
}

extension EditProfileController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let empty = text?.isEmpty {
            if empty {
                self.saveBtn.isEnabled = false
            }
            else {
                self.newName = text ?? ""
                self.saveBtn.isEnabled = true
            }
        }
        
        return true
    }
    
}
