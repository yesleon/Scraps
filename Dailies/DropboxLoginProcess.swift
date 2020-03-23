//
//  DropboxLoginProcess.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/24.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class DropboxLoginProcess: NSObject {
    private(set) static var current: DropboxLoginProcess?
    private let completion: (DropboxProxy) -> Void
    private init(completion: @escaping (DropboxProxy) -> Void) {
        self.completion = completion
    }
    
    static func initiate(completion: @escaping (DropboxProxy) -> Void) {
        current = .init(completion: completion)
        OAuthServerProxy.dropbox.authorize(withClientID: "pjwsk8p4dk374mp", redirectURI: "https://www.narrativesaw.com/auth")
    }
    
    func handleURL(_ url: URL) {
        URLComponents(url: url, resolvingAgainstBaseURL: true)
            .flatMap { $0.host == "auth" ? $0 : nil }
            .flatMap { $0.fragment }
            .flatMap { fragment -> [URLQueryItem]? in
                var components = URLComponents()
                components.query = fragment
                return components.queryItems }?
            .filter { $0.name == "access_token" }
            .compactMap { $0.value }
            .forEach {
                completion(DropboxProxy(accessToken: $0))
                DropboxLoginProcess.current = nil } }
}
