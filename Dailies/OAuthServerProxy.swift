//
//  OAuthClient.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/24.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class OAuthClient: NSObject {
    
    static let dropbox = OAuthClient(
        authorizeURL: URL(string: "https://www.dropbox.com/oauth2/authorize")!
    )
    
    internal init(authorizeURL: URL) {
        self.authorizeURL = authorizeURL
    }
    
    let authorizeURL: URL
    
    func retrieveAccessToken(withClientID clientID: String, redirectURI: String, completion: @escaping (String) -> Void) {
        guard var components = URLComponents(url: authorizeURL, resolvingAgainstBaseURL: true) else { return }
        components.queryItems = [
            .init(name: "client_id", value: clientID),
            .init(name: "response_type", value: "token"),
            .init(name: "redirect_uri", value: redirectURI)
        ]
        components.url
            .map { UIApplication.shared.open($0) }
    }
}
