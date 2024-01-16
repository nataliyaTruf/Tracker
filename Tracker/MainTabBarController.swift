//
//  ViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 15/01/2024.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTabBar()
    }
    
    private func getTabBar() {
        let trackersVC = getVC(
            viewController: TrackersViewController(),
            title: "Трекеры",
            image: UIImage(named: "trackers")
        )
        let statsVC = getVC(
            viewController: StatisticsViewController(),
            title: "Статистика",
            image: UIImage(named: "stats")
        )
        let trackersNavController = UINavigationController(rootViewController: trackersVC)
        viewControllers = [trackersNavController, statsVC]
    }
    
    private func getVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = image
        return viewController
    }
}

