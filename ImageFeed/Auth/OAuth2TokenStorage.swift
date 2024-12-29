//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Taya on 02.12.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    var token: String? {
        get { return KeychainWrapper.standard.string(forKey: "AuthToken") }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: "AuthToken")
            } else {
                KeychainWrapper.standard.remove(forKey: "AuthToken")
            }
        }
    }
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case token
    }
}
