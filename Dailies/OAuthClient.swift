//
//  OAuthClient.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/24.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

class OAuthClient: NSObject {
    
    static let dropbox = OAuthClient(
        authorizeURL: URL(string: "https://www.dropbox.com/oauth2/authorize")!
    )
    
    internal init(authorizeURL: URL) {
        self.authorizeURL = authorizeURL
    }
    
    let authorizeURL: URL
    
    private var publisher = PassthroughSubject<String, Never>()
    
    func retrieveAccessToken(withClientID clientID: String, redirectURI: String) -> AnyPublisher<String, Never> {
        guard var components = URLComponents(url: authorizeURL, resolvingAgainstBaseURL: true) else { fatalError() }
        components.queryItems = [
            .init(name: "client_id", value: clientID),
            .init(name: "response_type", value: "token"),
            .init(name: "redirect_uri", value: redirectURI)
        ]
        components.url
            .map { UIApplication.shared.open($0) }
        return publisher.eraseToAnyPublisher()
    }
    
    func canHandleURL(_ url: URL) -> Bool {
        URLComponents(url: url, resolvingAgainstBaseURL: true)?.host == "auth"
    }
    
    func handleURL(_ url: URL) {
        var components = URLComponents()
        components.query = url.fragment
        components.queryItems?
            .filter { $0.name == "access_token" }
            .compactMap { $0.value }
            .forEach { publisher.send($0); publisher.send(completion: .finished) } }
}
