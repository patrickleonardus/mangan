//
//  AuthenticationController.swift
//  Mangan
//
//  Created by Patrick Leonardus on 21/01/21.
//

import UIKit
import AppleWelcomeScreen
import TweeTextField
import CoreData

class AuthenticationController: UIViewController {
    
    @IBOutlet weak var nameTF: TweeActiveTextField!
    @IBOutlet weak var validationLbl: UILabel!
    
    var person: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        guard let recipe = UIImage(systemName: "text.book.closed") else {return}
        guard let article = UIImage(systemName: "sun.max.fill") else {return}
        guard let watch = UIImage(systemName: "applewatch") else {return}
        
        let configuration = WelcomeScreenConfiguration(
            appName: Const.appName,
            appDescription: "Kreasi dan Ide masak dalam satu aplikasi",
            features: [
                WelcomeScreenFeature(
                    image: recipe,
                    title: "Cari Ide & Kreasi Resep",
                    description: "Temukan beragam macam ide dan kreasi resep masakan nusantara dengan lengkap dan mudah."
                ),
                WelcomeScreenFeature(
                    image: article,
                    title: "Artikel & Panduan Memasak",
                    description: "Perbanyak pengetahuan & pengalaman melalui artikel dan panduan yang tersedia."
                ),
                WelcomeScreenFeature(
                    image: watch,
                    title: "Koneksikan dengan Apple Watch",
                    description: "Melihat panduan resep jadi lebih mudah dengan bantuan Apple Watch."
                ),
            ]
        )
        self.present(WelcomeScreenViewController(configuration: configuration), animated: true)
    }
    
    func initView(){
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        nameTF.becomeFirstResponder()
    }
    
    func save(name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "UserData",in: managedContext)!
        let person = NSManagedObject(entity: entity,insertInto: managedContext)
        person.setValue(name, forKeyPath: "name")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func errorAlert(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Nama belum diisi", message: "Silahkan isi nama anda sebelum melanjutkan", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        if let text = nameTF.text{
            if !text.isEmpty {
                save(name: text)
                UserDefaults.standard.setValue(true, forKey: "isLogin")
                self.dismiss(animated: true, completion: nil)
            }
            else {
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
                DispatchQueue.main.async {
                    self.validationLbl.alpha = 1
                }
            }
        }
        else {
            errorAlert()
        }
    }
    
}
