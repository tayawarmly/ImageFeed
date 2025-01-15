//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Taya on 11.11.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // Хранение обсервера, возвращаемого API
    private var profileImageServiceObserver: NSObjectProtocol?
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    
    private lazy var exitButton: UIButton = {
        let exitButton = UIButton()
        
        exitButton.setImage(UIImage(named: "ExitSymbol"), for: .normal)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }()
    
    private lazy var avatarImage: UIImageView = {
        let mockAvatar = UIImage(named: "stub_profile_img")
        let avatarImage = UIImageView(image: mockAvatar)
        
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        return avatarImage
    }()
    
    private lazy var userText: UILabel = {
        let userText = UILabel()
        userText.text = "Hello, World!"
        userText.textColor = .ypWhite
        userText.font = .systemFont(ofSize: 13)
        userText.numberOfLines = 0
        
        userText.translatesAutoresizingMaskIntoConstraints = false
        return userText
    }()
    
    private lazy var userNickname: UILabel = {
        let userNickname = UILabel()
        userNickname.text = "@ekaterina_nov"
        userNickname.textColor = .ypGray
        userNickname.font = .systemFont(ofSize: 13)
        
        userNickname.translatesAutoresizingMaskIntoConstraints = false
        return userNickname
    }()
    
    private lazy var userName: UILabel = {
        let userName = UILabel()
        userName.text = "Екатерина Новикова"
        userName.textColor = .ypWhite
        userName.font = .boldSystemFont(ofSize: 23)
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        return userName
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        avatarImage.layer.cornerRadius = 35
        avatarImage.clipsToBounds = true
        
        addSubviews()
        setupConstraints()
        
        updateUserInfo()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func addSubviews() {
        view.addSubview(exitButton)
        view.addSubview(avatarImage)
        view.addSubview(userText)
        view.addSubview(userNickname)
        view.addSubview(userName)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            userText.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userText.topAnchor.constraint(equalTo: userNickname.bottomAnchor, constant: 8),
            userText.trailingAnchor.constraint(equalTo: userName.trailingAnchor),
            
            userName.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userName.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            userName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            
            userNickname.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userNickname.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userNickname.trailingAnchor.constraint(equalTo: userName.trailingAnchor),
            
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 99),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func updateUserInfo() {
        if let profile = profileService.profile {
            userName.text = profile.name()
            userNickname.text = profile.loginName()
            userText.text = profile.bio ?? "No BIO"
        } else {
            print("ProfileViewController: No profile found")
        }
    }
    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL
        else {
            print("ProfileViewController: Unable to get avatar")
            return
        }
        
        let imageURL = URL(string: profileImageURL)
        
        // Обновляем аватар, используя Kingfisher
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: "stub_profile_img"),
            options: [
                  .transition(.fade(0.2)),
                  .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success:
                print ("ProfileViewController: Image loaded successfully")
                
            case .failure(let error):
                print("ProfileViewController: Image loading failed", error)
            }
        }
    }
}
