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
    
    func withOldValue(initialValue: Output) -> AnyPublisher<(oldValue: Output, newValue: Output), Failure> {
        self
            .scan((oldValue: initialValue, newValue: initialValue), { oldPair, newValue in
                (oldValue: oldPair.newValue, newValue: newValue)
            })
            .eraseToAnyPublisher()
    }
    
}
