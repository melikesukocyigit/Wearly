//
//  MainTabBarController.swift
//  OOtdays
//
//  Created by Melike Su KOÇYİĞİT on 6.08.2025.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar()
    {
        
        let wardrobeVC = UINavigationController(rootViewController: WardrobeViewController())
        wardrobeVC.tabBarItem = UITabBarItem(title: "Wardrobe", image: UIImage(systemName: "tshirt"), tag: 0)

        let combinationsVC = UINavigationController(rootViewController: CombinationsViewController())
        combinationsVC.tabBarItem = UITabBarItem(
            title: "Combinations",
            image: UIImage(systemName: "sparkles"),
            tag: 1
        )
 
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        
       
        viewControllers = [wardrobeVC, combinationsVC, profileVC]
    }
}


