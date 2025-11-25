//
//  CropOverlay.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import SwiftUI

struct CropOverlay: View {
    @Binding var cropRect: CGRect
    let imageSize: CGSize
    let containerSize: CGSize
    let aspectRatio: CropAspectRatio
    let originalImageAspectRatio: CGFloat

    @State private var isDragging = false
    @State private var dragHandle: CropHandle? = nil
    @State private var dragStartRect: CGRect = .zero

    private let handleSize: CGFloat = 20
    private let lineWidth: CGFloat = 2

    enum CropHandle {
        case topLeft, topRight, bottomLeft, bottomRight
        case top, bottom, left, right
        case center
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark overlay outside crop area
                DarkOverlay(cropRect: cropRect, containerSize: containerSize)

                // Crop frame
                Rectangle()
                    .strokeBorder(Color.white, lineWidth: lineWidth)
                    .frame(width: cropRect.width, height: cropRect.height)
                    .position(x: cropRect.midX, y: cropRect.midY)

                // Grid lines (rule of thirds)
                GridLines(cropRect: cropRect)

                // Central drag area (for moving entire crop frame)
                Rectangle()
                    .fill(Color.clear)
                    .frame(
                        width: max(cropRect.width - 60, 0),
                        height: max(cropRect.height - 60, 0)
                    )
                    .position(x: cropRect.midX, y: cropRect.midY)
                    .gesture(handleGesture(.center))

                // Corner handles
                CropHandleView(color: .white)
                    .position(x: cropRect.minX, y: cropRect.minY)
                    .gesture(handleGesture(.topLeft))

                CropHandleView(color: .white)
                    .position(x: cropRect.maxX, y: cropRect.minY)
                    .gesture(handleGesture(.topRight))

                CropHandleView(color: .white)
                    .position(x: cropRect.minX, y: cropRect.maxY)
                    .gesture(handleGesture(.bottomLeft))

                CropHandleView(color: .white)
                    .position(x: cropRect.maxX, y: cropRect.maxY)
                    .gesture(handleGesture(.bottomRight))

                // Edge handles
                CropHandleView(color: .white, isEdge: true)
                    .position(x: cropRect.midX, y: cropRect.minY)
                    .gesture(handleGesture(.top))

                CropHandleView(color: .white, isEdge: true)
                    .position(x: cropRect.midX, y: cropRect.maxY)
                    .gesture(handleGesture(.bottom))

                CropHandleView(color: .white, isEdge: true)
                    .position(x: cropRect.minX, y: cropRect.midY)
                    .gesture(handleGesture(.left))

                CropHandleView(color: .white, isEdge: true)
                    .position(x: cropRect.maxX, y: cropRect.midY)
                    .gesture(handleGesture(.right))

                // Dimensions overlay (shown during drag)
                if isDragging {
                    CropDimensionsOverlay(cropRect: cropRect, imageSize: imageSize)
                }
            }
            .frame(width: containerSize.width, height: containerSize.height)
        }
    }

    private func handleGesture(_ handle: CropHandle) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isDragging {
                    // Сохраняем только при первом изменении
                    dragStartRect = cropRect
                    isDragging = true
                    dragHandle = handle
                }
                updateCropRect(handle: handle, translation: value.translation)
            }
            .onEnded { _ in
                isDragging = false
                dragHandle = nil
            }
    }

    private func updateCropRect(handle: CropHandle, translation: CGSize) {
        var newRect = dragStartRect
        let minSize: CGFloat = 50

        // Calculate anchor point (opposite corner)
        let anchorPoint: CGPoint

        switch handle {
        case .topLeft:
            anchorPoint = CGPoint(x: dragStartRect.maxX, y: dragStartRect.maxY)
            newRect = CGRect(
                x: min(dragStartRect.origin.x + translation.width, anchorPoint.x - minSize),
                y: min(dragStartRect.origin.y + translation.height, anchorPoint.y - minSize),
                width: max(dragStartRect.size.width - translation.width, minSize),
                height: max(dragStartRect.size.height - translation.height, minSize)
            )

        case .topRight:
            anchorPoint = CGPoint(x: dragStartRect.minX, y: dragStartRect.maxY)
            newRect = CGRect(
                x: dragStartRect.origin.x,
                y: min(dragStartRect.origin.y + translation.height, anchorPoint.y - minSize),
                width: max(dragStartRect.size.width + translation.width, minSize),
                height: max(dragStartRect.size.height - translation.height, minSize)
            )

        case .bottomLeft:
            anchorPoint = CGPoint(x: dragStartRect.maxX, y: dragStartRect.minY)
            newRect = CGRect(
                x: min(dragStartRect.origin.x + translation.width, anchorPoint.x - minSize),
                y: dragStartRect.origin.y,
                width: max(dragStartRect.size.width - translation.width, minSize),
                height: max(dragStartRect.size.height + translation.height, minSize)
            )

        case .bottomRight:
            anchorPoint = CGPoint(x: dragStartRect.minX, y: dragStartRect.minY)
            newRect = CGRect(
                x: dragStartRect.origin.x,
                y: dragStartRect.origin.y,
                width: max(dragStartRect.size.width + translation.width, minSize),
                height: max(dragStartRect.size.height + translation.height, minSize)
            )

        case .top:
            anchorPoint = CGPoint(x: dragStartRect.midX, y: dragStartRect.maxY)
            newRect.origin.y = min(dragStartRect.origin.y + translation.height, anchorPoint.y - minSize)
            newRect.size.height = max(dragStartRect.size.height - translation.height, minSize)

        case .bottom:
            anchorPoint = CGPoint(x: dragStartRect.midX, y: dragStartRect.minY)
            newRect.size.height = max(dragStartRect.size.height + translation.height, minSize)

        case .left:
            anchorPoint = CGPoint(x: dragStartRect.maxX, y: dragStartRect.midY)
            newRect.origin.x = min(dragStartRect.origin.x + translation.width, anchorPoint.x - minSize)
            newRect.size.width = max(dragStartRect.size.width - translation.width, minSize)

        case .right:
            anchorPoint = CGPoint(x: dragStartRect.minX, y: dragStartRect.midY)
            newRect.size.width = max(dragStartRect.size.width + translation.width, minSize)

        case .center:
            anchorPoint = dragStartRect.origin
            newRect.origin.x = dragStartRect.origin.x + translation.width
            newRect.origin.y = dragStartRect.origin.y + translation.height
        }

        // Apply aspect ratio constraint with anchor point
        if let targetAspectRatio = getTargetAspectRatio() {
            newRect = constrainToAspectRatio(newRect, aspectRatio: targetAspectRatio, handle: handle)
        }

        // Ensure minimum size
        newRect.size.width = max(newRect.size.width, minSize)
        newRect.size.height = max(newRect.size.height, minSize)

        // Constrain to container bounds with snap
        newRect = constrainToContainer(newRect)

        cropRect = newRect
    }

    private func getTargetAspectRatio() -> CGFloat? {
        switch aspectRatio {
        case .free:
            return nil
        case .original:
            return originalImageAspectRatio
        case .custom(let width, let height):
            return CGFloat(width / height)
        }
    }

    private func constrainToAspectRatio(_ rect: CGRect, aspectRatio: CGFloat, handle: CropHandle) -> CGRect {
        var newRect = rect
        
        switch handle {
        case .topLeft, .topRight, .bottomLeft, .bottomRight:
            // Для углов выбираем направление constraint'а по тому, что больше изменилось
            let widthChange = abs(newRect.width - dragStartRect.width)
            let heightChange = abs(newRect.height - dragStartRect.height)
            
            if widthChange > heightChange {
                newRect.size.height = newRect.size.width / aspectRatio
            } else {
                newRect.size.width = newRect.size.height * aspectRatio
            }
            
        case .top, .bottom:
            newRect.size.width = newRect.size.height * aspectRatio
            
        case .left, .right:
            newRect.size.height = newRect.size.width / aspectRatio
            
        case .center:
            break
        }
        
        return newRect
    }

    private func constrainToContainer(_ rect: CGRect) -> CGRect {
        var newRect = rect
        let snapThreshold: CGFloat = 10  // Snap distance in pixels

        // Snap to edges (magnetic alignment)
        if abs(newRect.minX) < snapThreshold {
            newRect.origin.x = 0
        }
        if abs(newRect.minY) < snapThreshold {
            newRect.origin.y = 0
        }
        if abs(newRect.maxX - containerSize.width) < snapThreshold {
            newRect.origin.x = containerSize.width - newRect.width
        }
        if abs(newRect.maxY - containerSize.height) < snapThreshold {
            newRect.origin.y = containerSize.height - newRect.height
        }

        // Hard constraints (don't allow outside bounds)
        newRect.origin.x = max(0, min(newRect.origin.x, containerSize.width - newRect.width))
        newRect.origin.y = max(0, min(newRect.origin.y, containerSize.height - newRect.height))
        newRect.size.width = min(newRect.width, containerSize.width - newRect.origin.x)
        newRect.size.height = min(newRect.height, containerSize.height - newRect.origin.y)

        return newRect
    }
}

struct DarkOverlay: View {
    let cropRect: CGRect
    let containerSize: CGSize

    var body: some View {
        ZStack {
            // Full dark overlay
            Color.black.opacity(0.6)
                .frame(width: containerSize.width, height: containerSize.height)

            // Clear area for crop
            Rectangle()
                .frame(width: cropRect.width, height: cropRect.height)
                .position(x: cropRect.midX, y: cropRect.midY)
                .blendMode(.destinationOut)
        }
        .compositingGroup()
    }
}

struct GridLines: View {
    let cropRect: CGRect

    var body: some View {
        ZStack {
            // Vertical lines
            Path { path in
                let third = cropRect.width / 3
                path.move(to: CGPoint(x: cropRect.minX + third, y: cropRect.minY))
                path.addLine(to: CGPoint(x: cropRect.minX + third, y: cropRect.maxY))
                path.move(to: CGPoint(x: cropRect.minX + third * 2, y: cropRect.minY))
                path.addLine(to: CGPoint(x: cropRect.minX + third * 2, y: cropRect.maxY))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)

            // Horizontal lines
            Path { path in
                let third = cropRect.height / 3
                path.move(to: CGPoint(x: cropRect.minX, y: cropRect.minY + third))
                path.addLine(to: CGPoint(x: cropRect.maxX, y: cropRect.minY + third))
                path.move(to: CGPoint(x: cropRect.minX, y: cropRect.minY + third * 2))
                path.addLine(to: CGPoint(x: cropRect.maxX, y: cropRect.minY + third * 2))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
        }
    }
}

struct CropHandleView: View {
    let color: Color
    var isEdge: Bool = false

    var body: some View {
        ZStack {
            // Invisible larger hitbox for easier grabbing
            Color.clear
                .frame(width: 44, height: 44)

            // Visible handle
            if isEdge {
                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: 30, height: 4)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            } else {
                // Corner handle - более заметный
                ZStack {
                    // Белый круг
                    Circle()
                        .fill(Color.white)
                        .frame(width: 14, height: 14)

                    // Синяя обводка для visibility
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: 14, height: 14)
                }
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
            }
        }
    }
}

// MARK: - Crop Dimensions Overlay

struct CropDimensionsOverlay: View {
    let cropRect: CGRect
    let imageSize: CGSize

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(cropRect.width)) × \(Int(cropRect.height))")
                .font(.system(size: 11, weight: .medium).monospacedDigit())
                .foregroundColor(.white)

            Text(aspectRatioString)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.7))
        .cornerRadius(6)
        .position(x: cropRect.midX, y: cropRect.minY - 30)
    }

    var aspectRatioString: String {
        let ratio = cropRect.width / cropRect.height

        // Try to find common aspect ratios
        let commonRatios: [(CGFloat, String)] = [
            (1.0, "1:1"),
            (4.0/3.0, "4:3"),
            (3.0/2.0, "3:2"),
            (16.0/9.0, "16:9"),
            (2.35, "2.35:1")
        ]

        for (value, name) in commonRatios {
            if abs(ratio - value) < 0.05 {
                return name
            }
        }

        return String(format: "%.2f:1", ratio)
    }
}
