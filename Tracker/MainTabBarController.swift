//
//  ViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 15/01/2024.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTabBar()
        setupTabBarAppearance()
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

    private func setupTabBarAppearance() {
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        tabBar.layer.borderWidth = 1.0
        tabBar.clipsToBounds = true
    }
}

