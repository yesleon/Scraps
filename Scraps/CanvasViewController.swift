//
//  CanvasView.swift
//  Scraps
//
//  Created by Li-Heng Hsu on 2020/4/13.
//  Copyright © 2020 Li-Heng Hsu. All rights reserved.
//

import UIKit
import PencilKit

class CanvasViewController: UIViewController {

    lazy var canvasView = PKCanvasView()
    
    var saveHandler: (PKDrawing) -> Void = { _ in }
    
    override func loadView() {
        canvasView.contentSize = .init(width: .maxDimension, height: .maxDimension)
        canvasView.backgroundColor = .systemBackground
        view = canvasView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isModalInPresentation = true
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .save) { [weak self] _ in
            guard let self = self else { return }
            self.presentingViewController?.dismiss(animated: true)
            self.saveHandler(self.canvasView.drawing)
        }
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.presentingViewController?.dismiss(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let window = view.window {
            let toolPicker = PKToolPicker.shared(for: window)
            toolPicker?.addObserver(canvasView)
            toolPicker?.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let zoomScale = canvasView.zoomScale
        canvasView.setZoomScale(1, animated: true)
        defer {
            canvasView.setZoomScale(zoomScale, animated: true)
        }
        
        if view.frame.width > view.frame.height {
            canvasView.minimumZoomScale = view.safeAreaLayoutGuide.layoutFrame.width/canvasView.contentSize.width
        } else {
            canvasView.minimumZoomScale = view.safeAreaLayoutGuide.layoutFrame.height/canvasView.contentSize.height
        }
        
        
    }
    
}
