//
//  DropboxProxy.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/23.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine



class DropboxProxy: NSObject {
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    let accessToken: String
    
    func download(_ path: String) -> AnyPublisher<Data, URLError> {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "content.dropboxapi.com"
        components.path = "/2/files/download"
        return components.url.map { url -> URLRequest in
            var request = URLRequest(url: url)
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            request.setValue("{\"path\": \"\(path)\"}", forHTTPHeaderField: "Dropbox-API-Arg")
            return request }
            .map(URLSession.shared.dataTaskPublisher(for:))!
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    func upload(_ data: Data, to path: String) -> AnyPublisher<Data, URLError> {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "content.dropboxapi.com"
        components.path = "/2/files/upload"
        return components.url.map { url -> URLRequest in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            request.setValue("{\"path\": \"\(path)\",\"mode\": \"overwrite\",\"autorename\": false,\"mute\": false,\"strict_conflict\": false}", forHTTPHeaderField: "Dropbox-API-Arg")
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            return request }
            .map(URLSession.shared.dataTaskPublisher(for:))!
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    func getMetadata(of path: String) -> AnyPublisher<GetMetadataResponse, Error> {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.dropboxapi.com"
        components.path = "/2/files/get_metadata"
        return components.url.map { url -> URLRequest in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = "{\"path\": \"\(path)\",\"include_media_info\": false,\"include_deleted\": false,\"include_has_explicit_shared_members\": false}".data(using: .utf8)
            return request }
            .map(URLSession.shared.dataTaskPublisher(for:))!
            .map(\.data)
            .decode(type: GetMetadataResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    
}

struct GetMetadataResponse: Codable {
    var server_modified: Date
}
