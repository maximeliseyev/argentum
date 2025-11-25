//
//  ImageDocument.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 24.11.2025.
//

import Foundation
import Combine
import CoreImage
import AppKit

class ImageDocument: ObservableObject {
    @Published var originalImage: CIImage?
    @Published var processedImage: CIImage?
    @Published var fileURL: URL?

    var fileName: String? {
        fileURL?.lastPathComponent
    }

    func loadImage(from url: URL) {
        guard url.pathExtension.lowercased() == "tiff" ||
              url.pathExtension.lowercased() == "tif"  ||
              url.pathExtension.lowercased() == "jpeg" ||
              url.pathExtension.lowercased() == "jpg" else {
            print("Error: File is not a TIFF or JPEG image")
            return
        }

        // Start accessing security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            print("Error: Could not access security-scoped resource")
            return
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        if let image = CIImage(contentsOf: url) {
            self.originalImage = image
            self.processedImage = image
            self.fileURL = url
        } else {
            print("Error: Could not load image from \(url)")
        }
    }

    func reset() {
        self.processedImage = self.originalImage
    }
}
