//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Taya on 02.12.2024.
//

import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    
    private let splashScreenLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SplashViewController: viewDidAppear")
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
            print("SplashViewController: switchToTabBarController")
            
        } else {
            //открывает экран аутентификации
            //performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            
            showAuthViewController()
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
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("AuthViewController: Error instantiating AuthViewController")
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("SwitchToTabBarController: Invalid window configuration")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    // переход к галерее
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWith code: String) {
        DispatchQueue.main.async {
            self.dismiss(animated: false) { [weak self] in
                guard let self else { return }
                
                self.fetchOAuthToken(code)
            }
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async { UIBlockingProgressHUD.dismiss()
                
                guard let self else { return }
                
                switch result {
                case .success(let token):
                    self.oauth2TokenStorage.token = token
                    self.fetchProfile(token)
                    
                case .failure:
                    print("SplashViewController: Error fetching token")
                    self.showErrorAlert(
                        title: "Что-то пошло не так(",
                        message: "Не удалось войти в систему"
                    )
                    
                }
            }
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                
                guard let self else { return }
                
                switch result {
                case .success(let profile):
                    ProfileImageService.shared.fetchProfileImageURL(token: token, username: profile.username) { _ in UIBlockingProgressHUD.dismiss()
                    }
                    self.switchToTabBarController()
                    
                case .failure(let error):
                    print("SplashViewController: Error fetching profile: \(error)")
                }
            }
        }
    }
    
    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .default
            )
        )
        present(alert, animated: true)
    }
}

    /*
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
     */

