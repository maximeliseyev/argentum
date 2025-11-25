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
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let onResetZoom: () -> Void

    @State private var previewImage: NSImage?
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var lastImageExtent: CGRect = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let previewImage = previewImage {
                    Image(nsImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    let newScale = scale * delta
                                    scale = min(max(newScale, 0.1), 10.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                        .tint(.white.opacity(0.5))
                }
            }
            .onChange(of: image) { oldValue, newValue in
                updatePreview()

                // Only reset zoom if the image size changed (new file loaded)
                // Don't reset if it's just filters being applied to the same image
                if let newImage = newValue {
                    let newExtent = newImage.extent
                    if newExtent != lastImageExtent {
                        lastImageExtent = newExtent
                        onResetZoom()
                    }
                } else {
                    lastImageExtent = .zero
                    onResetZoom()
                }
            }
            .onAppear {
                if let image = image {
                    lastImageExtent = image.extent
                }
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
    ImageCanvas(
        image: nil,
        scale: .constant(1.0),
        offset: .constant(.zero),
        onResetZoom: {}
    )
}
