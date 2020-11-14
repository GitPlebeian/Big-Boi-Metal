//
//  AppDelegate.swift
//  game
//
//  Created by Jackson Tubbs on 11/14/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        presentInitialViewController()
        return true
    }
    
    // Present Initial View Controller
    func presentInitialViewController() {
        let initialViewController = InitialViewController()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }
}

