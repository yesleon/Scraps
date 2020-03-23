//
//  Document.swift
//  Dailies
//
//  Created by Li-Heng Hsu on 2020/3/22.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import Combine

enum Diff {
    case newIndexPath(IndexPath), newSection(Int), removeIndexPath(IndexPath), removeSection(Int)
}

class Document: UIDocument {
    
    static let shared = Document(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("data"))
    
    var draft: String?
    
    private(set) var thoughtDayLists = [(date: Date, thoughts: [Thought])]()
    
    var publisher = PassthroughSubject<Diff, Never>()
    
    private var dropboxProxy: DropboxProxy?
    
    var subscriptions = Set<AnyCancellable>()
    
    func connectToDropbox(token: String) {
        let proxy = DropboxProxy(token: token)
        self.dropboxProxy = proxy
        
        proxy.getMetadata(of: "/data")
            .sink(receiveCompletion: { completion in
                print(completion)
                switch completion {
                case .failure(_):
                    proxy.upload(try! JSONEncoder().encode(self.thoughtDayLists.flatMap { $0.thoughts }), to: "/data").sink(receiveCompletion: { completion in
                        print(completion)
                    }) { data in
                        
                        print(data)
                    }.store(in: &self.subscriptions)
                case .finished:
                    break
                }
            }) { response in
                print(response.server_modified) }
            .store(in: &subscriptions)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { fatalError() }
        let thoughts = try JSONDecoder().decode([Thought].self, from: data)
        undoManager.disableUndoRegistration()
        thoughts.forEach(addThought)
        undoManager.enableUndoRegistration()
    }
    
    override func contents(forType typeName: String) throws -> Any {
        let data = try JSONEncoder().encode(thoughtDayLists.flatMap { $0.thoughts })
        dropboxProxy?.upload(data, to: "/data").sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { data in
            print(data)
        }).store(in: &subscriptions)
        return data
    }
    
    func load() {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            open()
        } else {
            save(to: fileURL, for: .forCreating) { _ in
                self.open()
            }
        }
    }
    
    func addThought(_ thought: Thought) {
        
        let lastIndex = thoughtDayLists.count - 1
        if !thoughtDayLists.isEmpty,
            Calendar.current.isDate(thought.date, inSameDayAs: thoughtDayLists[lastIndex].date) {
            
            thoughtDayLists[lastIndex].thoughts.append(thought)
            let indexPath = IndexPath(row: thoughtDayLists[lastIndex].thoughts.count-1, section: lastIndex)
            
            publisher.send(.newIndexPath(indexPath))
            undoManager.registerUndo(withTarget: self) {
                $0.removeThought(at: indexPath)
            }
            
        } else {
            thoughtDayLists.append((date: thought.date, thoughts: [thought]))
            let newSection = thoughtDayLists.count - 1
            
            publisher.send(.newSection(newSection))
            undoManager.registerUndo(withTarget: self) {
                $0.removeThought(at: IndexPath(row: 0, section: newSection))
            }
        }
        
        
    }
    
    func removeThought(at indexPath: IndexPath) {
        let thought = thoughtDayLists[indexPath.section].thoughts.remove(at: indexPath.row)

        publisher.send(.removeIndexPath(indexPath))
        undoManager.registerUndo(withTarget: self) {
            $0.thoughtDayLists[indexPath.section].thoughts.insert(thought, at: indexPath.row)
            $0.publisher.send(.newIndexPath(indexPath))
            $0.undoManager.registerUndo(withTarget: $0) {
                $0.removeThought(at: indexPath)
            }
        }
        if thoughtDayLists[indexPath.section].thoughts.isEmpty {
            let section = thoughtDayLists.remove(at: indexPath.section)
            publisher.send(.removeSection(indexPath.section))
            undoManager.registerUndo(withTarget: self) {
                $0.thoughtDayLists.insert(section, at: indexPath.section)
                $0.publisher.send(.newSection(indexPath.section))
            }
        }
    }
    
}

extension Document: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        thoughtDayLists.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughtDayLists[section].thoughts.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = thoughtDayLists[indexPath.section].thoughts[indexPath.row].content
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateFormatter.localizedString(from: thoughtDayLists[section].date, dateStyle: .full, timeStyle: .none)
    }
    
}
