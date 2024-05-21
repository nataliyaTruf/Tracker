//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 23/04/2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    // MARK: - Properties
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = .ypGray
        pc.currentPageIndicatorTintColor = .ypBlackDay
        pc.numberOfPages = pages.count
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    lazy var pages: [UIViewController] = {
        var pages = [UIViewController]()
        pages.append(createOnboardingViewController(forPage: 1))
        pages.append(createOnboardingViewController(forPage: 2))
        return pages
    }()
    
    lazy var skipButton: CustomButton = {
        let button = CustomButton(title: "Вот это технологии")
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
        setupNextButton()
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @objc private func skipButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
     switchToMainInterface()
    }
   
    // MARK: - Navigation
    
    private func switchToMainInterface() {
        if let window = view?.window {
            let mainTabBarController = MainTabBarController()
            window.rootViewController = mainTabBarController
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    // MARK: - Setup Methods
    
    private func createOnboardingViewController(forPage page: Int) -> UIViewController {
        let pageContentViewController = UIViewController()
        
        let backgroundImageView = UIImageView(image: (UIImage(named: "onboarding\(page)")))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        pageContentViewController.view.insertSubview(backgroundImageView, at: 0)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: pageContentViewController.view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: pageContentViewController.view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: pageContentViewController.view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: pageContentViewController.view.trailingAnchor)
        ])
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.font = Fonts.bold(size: 32)
        textLabel.textAlignment = .center
        textLabel.textColor = .ypBlackDay
        textLabel.backgroundColor = .clear
        textLabel.text = page == 1 ? "Отслеживайте только то, что хотите" : "Даже если это не литры воды и йога"
        pageContentViewController.view.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.bottomAnchor.constraint(equalTo: pageContentViewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            textLabel.leadingAnchor.constraint(equalTo: pageContentViewController.view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: pageContentViewController.view.trailingAnchor, constant: -16),
            textLabel.heightAnchor.constraint(equalToConstant: 76)
        ])
        
        return pageContentViewController
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupNextButton() {
        NSLayoutConstraint.activate([
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
        ])
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController),
              viewControllerIndex > 0 else {
            return nil
        }
        return pages[viewControllerIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController),
              viewControllerIndex < pages.count - 1 else {
            return nil
        }
        return pages[viewControllerIndex + 1]
    }
    
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleController = pageViewController.viewControllers?.first,
           let index = pages.firstIndex(of: visibleController) {
            pageControl.currentPage = index
        }
    }
}
