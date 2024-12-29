//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Taya on 15.12.2024.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private var task: URLSessionTask?
    
    enum ServiceError: Error {
        case invalidData
        case urlRequestError
    }
    
    struct ProfileResult: Codable {
        let username: String
        let firstName: String?
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    
    //получаем данные пользователя
    func makeProfileRequest(_ token: String) -> URLRequest? {
        guard let url = URL(
            string: "/me"
            + "?client_id=\(Constants.accessKey)",
            relativeTo: Constants.defaultBaseURL
        )
        else {
            assertionFailure("ProfileService: Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeProfileRequest(token) else {
            print("Profileservice: Failed to create URLRequest")
            completion(.failure(ServiceError.urlRequestError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            self?.task = nil
            
            switch result {
            case .success(let profileResult):
                completion(.success(profileResult))
                
            case .failure(let error):
                print("Profileservice: Failed to fetch profile with error: \(error)")
                completion(.failure(ServiceError.invalidData))
            }
            
        }
    }
    
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        
        init(from profileResult: ProfileResult) {
            self.username = profileResult.username
            let fullName = [profileResult.firstName, profileResult.lastName].compactMap { $0 }.joined(separator: " ")
            self.name = fullName.isEmpty ? profileResult.username : fullName
            self.loginName = "@\(profileResult.username)"
            self.bio = profileResult.bio
        }
    }
}
