//
//  ImageCanvas.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI
import CoreImage

struct ImageSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ImageCanvas: View {
    let image: CIImage?
    let originalImage: CIImage?
    @ObservedObject var editingState: EditingState
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    let onResetZoom: () -> Void

    @State private var previewImage: NSImage?
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    @State private var lastImageExtent: CGRect = .zero
    @State private var imageDisplaySize: CGSize = .zero
    @State private var previewUpdateTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let previewImage = previewImage {
                    ZStack {
                        Image(nsImage: previewImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay(
                                GeometryReader { imageGeometry in
                                    Color.clear
                                        .preference(key: ImageSizePreferenceKey.self, value: imageGeometry.size)
                                }
                            )
                            .onPreferenceChange(ImageSizePreferenceKey.self) { newSize in
                                imageDisplaySize = newSize
                            }

                        // Crop overlay - in same ZStack as image
                        if editingState.isCropActive, let originalImage = originalImage {
                            CropOverlay(
                                cropRect: cropRectBinding,
                                imageSize: originalImage.extent.size,
                                containerSize: imageDisplaySize,
                                aspectRatio: editingState.cropAspectRatio,
                                originalImageAspectRatio: originalImage.extent.width / originalImage.extent.height
                            )
                        }
                    }
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                guard !editingState.isCropActive else { return }
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
                                guard !editingState.isCropActive else { return }
                                let newOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                                offset = constrainOffset(newOffset, scale: scale, imageSize: imageDisplaySize)
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
            .onChange(of: editingState.isCropActive) { _, isActive in
                if isActive {
                    initializeCropRect()
                }
            }
        }
    }

    private var cropRectBinding: Binding<CGRect> {
        Binding(
            get: {
                if let cropRect = editingState.cropRect, let originalImage = originalImage {
                    // Transform from image space to view space
                    return imageToViewCoordinates(cropRect, imageSize: originalImage.extent.size, viewSize: imageDisplaySize)
                } else if originalImage != nil {
                    // Default fallback: 80% of image centered (matches initializeCropRect)
                    let cropWidth = imageDisplaySize.width * 0.8
                    let cropHeight = imageDisplaySize.height * 0.8
                    return CGRect(
                        x: (imageDisplaySize.width - cropWidth) / 2,
                        y: (imageDisplaySize.height - cropHeight) / 2,
                        width: cropWidth,
                        height: cropHeight
                    )
                }
                return .zero
            },
            set: { newViewRect in
                guard let originalImage = originalImage else { return }
                // Transform from view space back to image space
                editingState.cropRect = viewToImageCoordinates(newViewRect, imageSize: originalImage.extent.size, viewSize: imageDisplaySize)
            }
        )
    }

    private func initializeCropRect() {
        guard let originalImage = originalImage, editingState.cropRect == nil else { return }

        let extent = originalImage.extent
        let cropWidth = extent.width * 0.8
        let cropHeight = extent.height * 0.8
        let cropX = (extent.width - cropWidth) / 2
        let cropY = (extent.height - cropHeight) / 2

        editingState.cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
    }

    private func imageToViewCoordinates(_ imageRect: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
        let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        let offsetX = (viewSize.width - scaledImageWidth) / 2
        let offsetY = (viewSize.height - scaledImageHeight) / 2

        return CGRect(
            x: imageRect.origin.x * scale + offsetX,
            y: imageRect.origin.y * scale + offsetY,
            width: imageRect.width * scale,
            height: imageRect.height * scale
        )
    }

    private func viewToImageCoordinates(_ viewRect: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
        let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        let offsetX = (viewSize.width - scaledImageWidth) / 2
        let offsetY = (viewSize.height - scaledImageHeight) / 2

        return CGRect(
            x: (viewRect.origin.x - offsetX) / scale,
            y: (viewRect.origin.y - offsetY) / scale,
            width: viewRect.width / scale,
            height: viewRect.height / scale
        )
    }

    private func constrainOffset(_ offset: CGSize, scale: CGFloat, imageSize: CGSize) -> CGSize {
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale

        // Maximum offset to keep at least 50% of image visible
        let maxOffsetX = scaledWidth / 4
        let maxOffsetY = scaledHeight / 4

        return CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
    }

    private func updatePreview() {
        guard let image = image else {
            // Cancel any ongoing preview generation
            previewUpdateTask?.cancel()
            previewUpdateTask = nil
            previewImage = nil
            return
        }

        // Cancel previous task if still running
        previewUpdateTask?.cancel()

        // Keep old preview visible while generating new one (prevents flickering)
        previewUpdateTask = Task {
            let preview = await ImageProcessor.shared.generatePreviewAsync(from: image)

            // Check if task was cancelled
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.previewImage = preview
            }
        }
    }
}

//#Preview {
//    ImageCanvas(
//        image: nil,
//        originalImage: nil,
//        editingState: EditingState(),
//        scale: .constant(1.0),
//        offset: .constant(.zero),
//        onResetZoom: {}
//    )
//}
