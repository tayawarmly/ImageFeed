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
    
    enum ServiceErrors: Error {
        case makeTokenRequestError
        case selfError
        case decodingError
        case fetchingError
    }
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else { return nil }
        
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL)
        
        guard let url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken (_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(ServiceErrors.makeTokenRequestError))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else {
                completion(.failure(ServiceErrors.selfError))
                return
            }
            
            switch result {
                
            case .success(let data):
                do {
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print(response.accessToken)
                    
                    self.authToken = response.accessToken
                    completion(.success(response.accessToken))
                    
                } catch {
                    
                    completion(.failure(ServiceErrors.decodingError))
                    print("Failed to parse data: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                completion(.failure(ServiceErrors.fetchingError))
                print("Failed to fetch data: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
