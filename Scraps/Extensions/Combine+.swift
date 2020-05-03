//
//  Combine+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/10.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Combine

typealias AnyCancellable = Combine.AnyCancellable

extension Publisher where Failure == Never {
    
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root?) -> AnyCancellable {
        sink { object?[keyPath: keyPath] = $0 }
    }
    
    func withPreviousResult(initialResult: Output) -> AnyPublisher<(previousResult: Output, result: Output), Failure> {
        self
            .scan((previousResult: initialResult, result: initialResult), { oldPair, result in
                (previousResult: oldPair.result, result: result)
            })
            .eraseToAnyPublisher()
    }
    
    func previousResult(initialResult: Output) -> AnyPublisher<Output, Failure> {
        self
            .withPreviousResult(initialResult: initialResult)
            .map(\.previousResult)
            .eraseToAnyPublisher()
    }
    
}
