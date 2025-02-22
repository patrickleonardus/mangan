//
//  SceneDelegate.swift
//  Mangan
//
//  Created by Patrick Leonardus on 14/01/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        didOpenFromWidget(urlContexts: connectionOptions.urlContexts)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        didOpenFromWidget(urlContexts: URLContexts)
    }
    
    func didOpenFromWidget(urlContexts: Set<UIOpenURLContext>){
        if let url = urlContexts.first?.url {
            let urlString = url.absoluteString
            
            let recipeUrl = urlString.components(separatedBy: "(-)")[1]
            let imageUrl = urlString.components(separatedBy: "(-)")[2]
            
            let userInfo = ["key":recipeUrl, "imageUrl":imageUrl]
            
            NotificationCenter.default.post(name: NSNotification.Name("widget"), object: nil, userInfo: userInfo)
        }
    }
}

