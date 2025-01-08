//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Taya on 15.12.2024.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() {}
    
    enum ServiceError: Error {
        case invalidData
        case urlRequestError
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
        request.httpMethod = "GET"
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
                let profile = profileResult.fetchedProfile()
                self?.profile = profile
                completion(.success(profileResult))
                
            case .failure(let error):
                print("Profileservice: Failed to fetch profile with error: \(error)")
                completion(.failure(ServiceError.invalidData))
            }
        }
        task.resume()
    }
}
