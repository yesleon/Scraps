//
//  Combine+.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/10.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine

typealias AnyCancellable = Combine.AnyCancellable
typealias AnyPublisher = Combine.AnyPublisher
typealias Publisher = Combine.Publisher

extension Publisher where Failure == Never {
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root?) -> AnyCancellable {
        sink(receiveValue: {
            object?[keyPath: keyPath] = $0
        })
    }
    func withOldValue(initialOldValue: Output) -> AnyPublisher<(oldValue: Output, newValue: Output), Failure> {
        scan((oldValue: initialOldValue, newValue: initialOldValue), { oldPair, newValue in
            (oldValue: oldPair.newValue, newValue: newValue)
        })
            .eraseToAnyPublisher()
    }
    func previousResult(initialResult: Output) -> AnyPublisher<Output, Failure> {
        withOldValue(initialOldValue: initialResult)
            .map(\.oldValue)
        .eraseToAnyPublisher()
    }
}
