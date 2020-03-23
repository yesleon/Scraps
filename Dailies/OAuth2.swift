//
//  OAuth2.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

struct TokenResponse: Codable {
    var access_token: String
    var token_type: String
    var account_id: String
    var uid: String
}

enum OAuth2 {
    
    static func openAuthorizationPage(host: String, path: String, clientID: String, redirectURI: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = [
            .init(name: "client_id", value: clientID),
            .init(name: "response_type", value: "code"),
            .init(name: "redirect_uri", value: redirectURI)
        ]
        components.url.map { UIApplication.shared.open($0, options: [:], completionHandler: nil) }
    }
    
    static func retrieveToken(host: String, path: String, clientID: String, clientSecret: String, redirectURI: String, authorizationCode: String, handler: @escaping (String) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.dropbox.com"
        components.path = "/oauth2/token"
        var subscription: AnyCancellable?
        subscription = components.url
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                var components = URLComponents()
                components.queryItems = [
                    .init(name: "code", value: authorizationCode),
                    .init(name: "grant_type", value: "authorization_code"),
                    .init(name: "client_id", value: "pjwsk8p4dk374mp"),
                    .init(name: "client_secret", value: "mh92gshwdn9p6z7"),
                    .init(name: "redirect_uri", value: "https://www.narrativesaw.com/auth")
                ]
                request.httpBody = components.percentEncodedQuery
                    .flatMap { $0.data(using: .utf8) }
                return request }
            .map(URLSession.shared.dataTaskPublisher(for:))?
            .map(\.data)
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .map(\.access_token)
            .map(Optional.init)
            .catch { error -> Just<String?> in print(error); return Just(nil) }
            .compactMap { $0 }
            .sink { code in
                handler(code)
                subscription?.cancel()
        }
        
    }
    
}
