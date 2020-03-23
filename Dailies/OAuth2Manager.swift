//
//  OAuth2Manager.swift
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

extension Optional {
    func filter(_ isIncluded: (Wrapped) throws -> Bool) rethrows -> Wrapped? {
        if let self = self, try isIncluded(self) {
            return self
        } else {
            return nil
        }
    }
}

class OAuth2Manager: NSObject {
    static let shared = OAuth2Manager()
    var accessToken: String?
    var subscriptions = Set<AnyCancellable>()
    func startAuthorizationFlow() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.dropbox.com"
        components.path = "/oauth2/authorize"
        components.queryItems = [
            .init(name: "client_id", value: "pjwsk8p4dk374mp"),
            .init(name: "response_type", value: "code"),
            .init(name: "redirect_uri", value: "https://www.narrativesaw.com/auth")
        ]
        components.url.map { UIApplication.shared.open($0, options: [:], completionHandler: nil) }
        
    }
    func handleURL(_ url: URL) {
        URLComponents(url: url, resolvingAgainstBaseURL: true)
            .filter { $0.host == "receiveAuthorizationCode" }
            .flatMap { $0.queryItems }?
            .compactMap { $0 }
            .filter { $0.name == "code" }
            .compactMap { $0.value }
            .forEach { OAuth2Manager.shared.askForToken(authorizationCode: $0) }
    }
    func askForToken(authorizationCode: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.dropbox.com"
        components.path = "/oauth2/token"
        components.url
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
            .assign(to: \.accessToken, on: self)
            .store(in: &subscriptions)
    }
}
