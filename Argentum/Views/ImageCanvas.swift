//
//  ImageCanvas.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI
import CoreImage

struct ImageCanvas: View {
    let image: CIImage?

    @State private var previewImage: NSImage?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.1)

                if let previewImage = previewImage {
                    Image(nsImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ProgressView()
                }
            }
            .onChange(of: image) { oldValue, newValue in
                updatePreview()
            }
            .onAppear {
                updatePreview()
            }
        }
    }

    private func updatePreview() {
        guard let image = image else {
            previewImage = nil
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let preview = ImageProcessor.shared.generatePreview(from: image)
            DispatchQueue.main.async {
                self.previewImage = preview
            }
        }
    }
}

#Preview {
    ImageCanvas(image: nil)
}
