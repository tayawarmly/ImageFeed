//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Taya on 02.12.2024.
//

import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
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
        
        if let token = oauth2TokenStorage.token  {
            fetchProfile(token) // + переход в таб бар
            print("SplashViewController: switchToTabBarController")
            
        } else {
            //открывает экран аутентификации
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
            assertionFailure("SplashVC: AuthViewController: Error instantiating AuthViewController")
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("SplashVC: SwitchToTabBarController: Invalid window configuration")
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
        print ("SplashVC: SwitchToTabBarController: TabBarViewController opened")
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
            DispatchQueue.main.async {
                
                guard let self else { return }
                
                // получение токена, профиля. переход в таб
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
                UIBlockingProgressHUD.dismiss()
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
                    
                    self.profileImageService.fetchProfileImageURL(token: token, username: profile.username) { _ in }
                    
                    self.switchToTabBarController()
                    
                case .failure(let error):
                    print("SplashViewController: Error fetching profile: \(error)")
                    self.showErrorAlert(
                        title: "Что-то пошло не так(",
                        message: "Не удалось войти в систему"
                    )
                }
                
                UIBlockingProgressHUD.dismiss()
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
