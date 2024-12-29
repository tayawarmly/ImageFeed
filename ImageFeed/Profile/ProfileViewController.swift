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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPicture = UIImage(named: "UserPicture")
        let avatarImage = UIImageView(image: userPicture)
        view.backgroundColor = .ypBlack
        
        view.addSubview(avatarImage)
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let userName = UILabel()
        userName.text = "Екатерина Новикова"
        userName.textColor = .ypWhite
        userName.font = .boldSystemFont(ofSize: 23)
        
        view.addSubview(userName)
        userName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userName.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userName.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            userName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        let userNickname = UILabel()
        userNickname.text = "@ekaterina_nov"
        userNickname.textColor = .ypGray
        userNickname.font = .systemFont(ofSize: 13)
        
        view.addSubview(userNickname)
        userNickname.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userNickname.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userNickname.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            userNickname.trailingAnchor.constraint(equalTo: userName.trailingAnchor)
            
        ])
        
        let userText = UILabel()
        userText.text = "Hello, World!"
        userText.textColor = .ypWhite
        userText.font = .systemFont(ofSize: 13)
        userText.numberOfLines = 0
        
        view.addSubview(userText)
        userText.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userText.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userText.topAnchor.constraint(equalTo: userNickname.bottomAnchor, constant: 8),
            userText.trailingAnchor.constraint(equalTo: userName.trailingAnchor)
            
        ])
        
        let exitButton = UIButton()
        exitButton.setImage(UIImage(named: "ExitSymbol"), for: .normal)
        
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 99),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        // Обновляем аватар, используя Kingfisher
        if let imageView = view.subviews.compactMap( {$0 as? UIImageView}).first {
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "avatar"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}
