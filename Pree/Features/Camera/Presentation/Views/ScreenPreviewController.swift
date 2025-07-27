//
//  ScreenPreviewController.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI
import ReplayKit

struct ScreenPreviewController: UIViewControllerRepresentable {
    let preview: RPPreviewViewController

    func makeUIViewController(context: Context) -> RPPreviewViewController {
        preview.previewControllerDelegate = context.coordinator
        return preview
    }
    func updateUIViewController(_: RPPreviewViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(preview) }
    
    class Coordinator: NSObject, RPPreviewViewControllerDelegate {
        let controller: RPPreviewViewController
        init(_ c: RPPreviewViewController) { controller = c }
        func previewControllerDidFinish(_: RPPreviewViewController) {
            controller.dismiss(animated: true)
        }
    }
}
