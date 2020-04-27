//
//  Combine+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/10.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Combine

typealias AnyCancellable = Combine.AnyCancellable
typealias AnyPublisher = Combine.AnyPublisher
typealias Publisher = Combine.Publisher

extension Publisher where Failure == Never {
    
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root?) -> AnyCancellable {
        sink { object?[keyPath: keyPath] = $0 }
    }
    
    func previousResult(initialResult: Output) -> AnyPublisher<Output, Failure> {
        self
            .scan((previousResult: initialResult, result: initialResult), { oldPair, result in
                (previousResult: oldPair.result, result: result)
            })
            .map(\.previousResult)
            .eraseToAnyPublisher()
    }
    
}
