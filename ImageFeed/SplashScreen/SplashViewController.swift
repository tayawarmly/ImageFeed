//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Taya on 02.12.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SplashViewController: viewDidAppear")
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
            print("SplashViewController: switchToTabBarController")

        } else {
            
            //открывает экран аутентификации
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            print("SplashViewController: Authentication screen opened")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window configuration")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    
    // проверка перехода на авторизацию
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }

            viewController.delegate = self
            
        } else {
            
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    // переход к галерее
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWith code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
         
            case .failure:
                // TODO: [Sprint 11]
                break
            }
        }
    }
}
