//
//  ProfileImageModel.swift
//  ImageFeed
//
//  Created by Taya on 10.01.2025.
//

import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Decodable {
        let small: String
    }
}
