//
//  ProfileModel.swift
//  ImageFeed
//
//  Created by Taya on 08.01.2025.
//

import Foundation

struct Profile: Decodable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?
    
    func name() -> String {
        return "\(firstName) \(lastName)"
    }
    
    func loginName() -> String {
        return "@\(username)"
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName
        case lastName
        case bio
    }
    
    func fetchedProfile() -> Profile {
        return Profile(username: username, firstName: firstName ?? "", lastName: lastName ?? "", bio: bio)
    }
}
