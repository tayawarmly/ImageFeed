//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Taya on 20.12.2024.
//

import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange") //нотификация
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        struct ProfileImage: Codable {
            let small: String
        }
    }
    
    enum ServiceErrors: Error {
        case urlError
        case urlSessionError
        case dataError
        case notificationError
    }
    
    private init() {}
    
    // Формируем url и создаем запрос
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            assertionFailure("ProfileImageService: makeProfileImageRequest: cannot create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    // Получениe url аватара пользователя
    func fetchProfileImageURL(token: String, username: String,  _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makeProfileImageRequest(token: token, username: username) else {
            completion(.failure(ServiceErrors.urlError))
            print("ProfileImageService: fetchProfileImageURL: cannot create URL")
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            
            guard self != nil else {
                completion(.failure(ServiceErrors.urlSessionError))
                print("ProfileImageService: Error: urlSession is nil")
                return
            }
            
            switch result {
                
            case .success(let objectTask):
                let profileImageURL = objectTask.profileImage.small
                self?.avatarURL = profileImageURL
                
                //публикация нотификации
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL])
                
                completion(.success(profileImageURL))
                
            case.failure(let error):
                completion(.failure(ServiceErrors.notificationError))
                print("ProfileImageService: Error: \(error.localizedDescription)")
            }
        }
        task?.resume()
    }
}
