//
//  NotificationCenter+.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/5.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

extension NotificationCenter {
    
    func significantTimeChangeNotificationPublisher() -> AnyPublisher<Void, Never> {
        publisher(for: UIApplication.significantTimeChangeNotification).map({ _ in }).prepend(Just(())).eraseToAnyPublisher()
    }
    
}
