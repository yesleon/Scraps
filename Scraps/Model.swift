//
//  Model.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/28.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Foundation
import Combine


class Model<Value> {
    
    init(_ value: Value) {
        self.subject = .init(value)
    }
    
    private let subject: CurrentValueSubject<Value, Never>
    
    var valuePublisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
    
    var value: Value {
        subject.value
    }
    
    func modifyValue(handler: (inout Value) throws -> Void) rethrows {
        var value = self.subject.value
        try handler(&value)
        self.subject.value = value
    }
    
}
