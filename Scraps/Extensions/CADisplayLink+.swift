//
//  CADisplayLink+.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/4.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import Combine
import QuartzCore


extension CADisplayLink {
    
    static func publisher(in runLoop: RunLoop, forMode mode: RunLoop.Mode) -> AnyPublisher<CADisplayLink, Never> {
        let subject = PassthroughSubject<CADisplayLink, Never>()
        var link: CADisplayLink? = CADisplayLink(handler: subject.send)
        return subject
            .handleEvents(receiveSubscription: { _ in link?.add(to: runLoop, forMode: mode) },
                          receiveCancel: { link = nil })
            .eraseToAnyPublisher()
    }
    
}


