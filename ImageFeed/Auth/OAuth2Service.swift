//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Taya on 02.12.2024.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            preconditionFailure("Invalid baseURL")
        }
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL) else {
            preconditionFailure("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken (code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else {
                preconditionFailure("fetchOAuthToken error: self is nil")
            }
            
            switch result {
                
            case .success(let data):
                do {
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print(response)
                    
                    completion(.success(response.accessToken))
                } catch {
                    print("Failed to parse data: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

