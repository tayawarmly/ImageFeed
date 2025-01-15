//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Taya on 02.12.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    var authToken: String? {
        get { OAuth2TokenStorage().token }
        set { OAuth2TokenStorage().token = newValue }
    }
    
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private let tokenStorage = OAuth2TokenStorage()
    
    enum ServiceErrors: Error {
        case makeTokenRequestError
        case taskError
        case decodingError
        case fetchingError
        case invalidRequest
    }
    
    private init() {}
    
    func fetchOAuthToken (_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let fulfillCompletionOnMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard lastCode != code else {
            
            fulfillCompletionOnMainThread(.failure(ServiceErrors.invalidRequest))
            print("OAuth2Service: Invalid request")
            return
        }
        
        task?.cancel()
        lastCode = code //
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            fulfillCompletionOnMainThread(.failure(ServiceErrors.makeTokenRequestError))
            print("OAuth2Service: Error: Failed to create URLRequest")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
            }
            
            switch result {
            case .success(let response):
                self?.tokenStorage.token = response.accessToken
                fulfillCompletionOnMainThread(.success(response.accessToken))
                
            case .failure(let error):
                fulfillCompletionOnMainThread(.failure(ServiceErrors.decodingError))
                print("OAuth2Service: Failed to parse data: \(error.localizedDescription)")
            }
        }
        
        self.task = task
        task.resume()
    }
}

private func makeOAuthTokenRequest(code: String) -> URLRequest? {
    
    guard let url = URL(
        string: "https://unsplash.com/oauth/token"
        + "?client_id=\(Constants.accessKey)"
        + "&client_secret=\(Constants.secretKey)"
        + "&redirect_uri=\(Constants.redirectURI)"
        + "&code=\(code)"
        + "&grant_type=authorization_code") else {
        print("OAuth2Service: Error: invalid URL")
        return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    return request
}
