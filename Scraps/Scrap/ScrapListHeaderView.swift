//
//  ScrapListHeaderView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/10.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ScrapListHeaderView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        self.backgroundView = view
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    var subscriptions = Set<AnyCancellable>()
    
    func subscribe(to dateComponents: DateComponents) {
        subscriptions.removeAll()
        
        NotificationCenter.default.significantTimeChangeNotificationPublisher()
            .map { dateComponents }
            .compactMap(Calendar.current.date(from:))
            .sink(receiveValue: { [weak textLabel] date in
                let formatter = DateFormatter()
                formatter.doesRelativeDateFormatting = true
                formatter.dateStyle = .full
                formatter.timeStyle = .none
                textLabel?.text = formatter.string(from: date)
                textLabel?.sizeToFit()
            })
            .store(in: &subscriptions)
    }
    
}
