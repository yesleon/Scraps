//
//  CanvasView.swift
//  Treehole
//
//  Created by Li-Heng Hsu on 2020/4/13.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import PencilKit

class CanvasViewController: UIViewController, PKCanvasViewDelegate {

    lazy var canvasView = PKCanvasView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvasView.frame = view.bounds
        canvasView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        canvasView.contentSize = .init(width: .maxDimension, height: .maxDimension)
        view.addSubview(canvasView)
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var zoomScale: CGFloat = 0
            zoomScale = canvasView.zoomScale
            canvasView.setZoomScale(1, animated: true)
            
        if view.frame.width > view.frame.height {
            canvasView.minimumZoomScale = view.safeAreaLayoutGuide.layoutFrame.width/canvasView.contentSize.width
            } else {
                canvasView.minimumZoomScale = view.safeAreaLayoutGuide.layoutFrame.height/canvasView.contentSize.height
            }
            canvasView.setZoomScale(zoomScale, animated: true)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
}
