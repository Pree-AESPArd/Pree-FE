//
//  SmallCircularProgressBarRepresentable.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import Foundation

import SwiftUI

struct SmallCircularProgressBarRepresentable: UIViewRepresentable {
    var value: Double

    func makeUIView(context: Context) -> SmallCircularProgressBar {
        let progressBar = SmallCircularProgressBar()
        progressBar.value = value
        return progressBar
    }

    func updateUIView(_ uiView: SmallCircularProgressBar, context: Context) {
        uiView.value = value
    }
}

#Preview {
    SmallCircularProgressBarRepresentable(value: 0.2)
        .frame(width: 60, height: 60)
}
