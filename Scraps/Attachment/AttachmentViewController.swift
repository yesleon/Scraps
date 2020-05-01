//
//  AttachmentViewController.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/5/1.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import PencilKit
import LinkPresentation

class AttachmentViewController: UIViewController { }


extension AttachmentViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let attachment = (view as? AttachmentView)?.attachment else { return nil }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            let vc = UIViewController()
            vc.view = try! attachment.viewThatFits(.init(width: 500, height: 500))
            vc.preferredContentSize = vc.view.bounds.size
            return vc
        }) { suggestedActions in
            let shareAction = UIAction(title: "Share", image: nil) { action in
                UITraitCollection(userInterfaceStyle: .light).performAsCurrent {
                    if let image = attachment.image() {
                        let vc = UIActivityViewController(activityItems: [image, self], applicationActivities: nil)
                        vc.popoverPresentationController.map {
                            $0.sourceView = self.view
                            $0.sourceRect = self.view.bounds
                        }
                        self.present(vc, animated: true)
                    }
                }
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [shareAction])
        }
    }
    
}

extension AttachmentViewController: UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        nil
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let attachment = (view as? AttachmentView)?.attachment else { return nil }
        if let image = attachment.image() {
            let metadata = LPLinkMetadata()
            metadata.imageProvider = .init(object: image)
            return metadata
        }
        return nil
    }
    
}

extension Attachment {
    
    func image() -> UIImage? {
        switch kind {
        case .image:
            return UIImage(data: content)
        case .linkMetadata:
            return nil
        case .drawing:
            do {
                let drawing = try PKDrawing(data: content)
                return drawing.image(from: drawing.bounds.insetBy(dx: -10, dy: -10), scale: 3.0)
            } catch {
                print(error)
                return nil
            }
        }
    }
    
}
