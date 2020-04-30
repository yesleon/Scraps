//
//  ScrapListViewDataSource.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/12.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit

class ScrapListViewDataSource: UITableViewDiffableDataSource<DateComponents, Scrap.ID> {
    
    static func make(tableView: UITableView) -> ScrapListViewDataSource {
        ScrapListViewDataSource(tableView: tableView, cellProvider: { tableView, indexPath, scrapID in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? ScrapListViewCell else { return nil }
            cell.subscribe(to: ScrapList.shared.publisher(for: scrapID))
            return cell
        })
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func subscribe() {
        subscriptions.removeAll()
        
        ScrapList.shared.valuePublisher
            .combineLatest(ScrapFilterList.shared.valuePublisher, NotificationCenter.default.significantTimeChangeNotificationPublisher())
            .map({ scraps, filters, _ in
                scraps.sorted(by: { $0.date > $1.date })
                    .filter { filters.shouldInclude($0) }
                    .reduce([(dateComponents: DateComponents, scrapIDs: [Scrap.ID])](), { list, scrap in
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: scrap.date)
                        var list = list
                        if list.last?.dateComponents == dateComponents {
                            list[list.index(before: list.endIndex)].scrapIDs.append(scrap.id)
                        } else {
                            list.append((dateComponents: dateComponents, scrapIDs: [scrap.id]))
                        }
                        return list
                    })
            })
            .map({ scrapsByDates in
                var snapshot = NSDiffableDataSourceSnapshot<DateComponents, Scrap.ID>()
                scrapsByDates.forEach {
                    snapshot.appendSections([$0.dateComponents])
                    snapshot.appendItems($0.scrapIDs, toSection: $0.dateComponents)
                }
                return snapshot
            })
            .receive(on: RunLoop.main)
            .sink { self.apply($0, animatingDifferences: $0.numberOfSections != 0) }
            .store(in: &subscriptions)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
}
