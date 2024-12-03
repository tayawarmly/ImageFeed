//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Taya on 02.12.2024.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
