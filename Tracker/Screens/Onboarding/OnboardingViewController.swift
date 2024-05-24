//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 23/04/2024.
//

import UIKit

// MARK: - Enum

enum OnboardingPage: Int, CaseIterable {
    case pageOne = 0
    case pageTwo
    
    var title: String {
        switch self {
        case .pageOne:
            return "Отслеживайте только то, что хотите"
        case .pageTwo:
            return "Даже если это не литры воды и йога"
        }
    }
    
    var imageName: String {
        switch self {
        case .pageOne:
            return "onboarding1"
        case .pageTwo:
            return "onboarding2"
        }
    }
}

final class OnboardingViewController: UIPageViewController {
    // MARK: - UI Components
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .ypGray
        pc.currentPageIndicatorTintColor = .ypBlackDay
        pc.numberOfPages = OnboardingPage.allCases.count
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    lazy var skipButton: CustomButton = {
        let button = CustomButton(title: "Вот это технологии!")
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        
        setupPageControl()
        setupSkipButton()
        
        if let firstPage = viewController(for: .pageOne) {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
  
    // MARK: - Setup Methods
    
    private func setupPageControl() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupSkipButton() {
        NSLayoutConstraint.activate([
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }
    
    // MARK: - Navigation
    
    private func switchToMainInterface() {
        if let window = view?.window {
            let mainTabBarController = MainTabBarController()
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func viewController(for page: OnboardingPage) -> UIViewController? {
        return OnboardingPageViewController(page: page)
    }
    
    // MARK: - Actions
    
    @objc private func skipButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        switchToMainInterface()
    }
    
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingPageViewController,
              let currentPage = OnboardingPage(rawValue: onboardingVC.page.rawValue - 1) else {
            return nil
        }
        return self.viewController(for: currentPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let onboardingVC = viewController as? OnboardingPageViewController,
              let currentPage = OnboardingPage(rawValue: onboardingVC.page.rawValue + 1) else {
            return nil
        }
        return self.viewController(for: currentPage)
    }
    
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleController = pageViewController.viewControllers?.first as? OnboardingPageViewController {
            pageControl.currentPage = visibleController.page.rawValue
        }
    }
}
