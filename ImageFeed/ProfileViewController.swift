//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Taya on 11.11.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPicture = UIImage(named: "userPicture")
        let avatarImage = UIImageView(image: userPicture)
        self.view.backgroundColor = .ypBlack
        
        self.view.addSubview(avatarImage)
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            avatarImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 76),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let userName = UILabel()
        userName.text = "Екатерина Новикова"
        userName.textColor = .ypWhite
        userName.font = .boldSystemFont(ofSize: 23)
        
        view.addSubview(userName)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userName.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userName.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
        ])
        
        let userNickname = UILabel()
        userNickname.text = "@ekaterina_nov"
        userNickname.textColor = .ypGray
        userNickname.font = .systemFont(ofSize: 13)
        
        view.addSubview(userNickname)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userNickname.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userNickname.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
        ])
        
        let userText = UILabel()
        userText.text = "Hello, World!"
        userText.textColor = .ypWhite
        userText.font = .systemFont(ofSize: 13)
        userText.numberOfLines = 0
        
        view.addSubview(userText)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userText.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            userText.topAnchor.constraint(equalTo: userNickname.bottomAnchor, constant: 8),
        ])
        
        
        let exitButton = UIButton()
        exitButton.setImage(UIImage(named: "ExitSymbol"), for: .normal)
        
        view.addSubview(exitButton)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: 99),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        
    }
}

