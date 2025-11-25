//
//  FileManagerService.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 25.11.2025.
//

import Foundation
import Combine
import AppKit

class FileManagerService: ObservableObject {
    @Published var openedFolders: [URL] = []
    @Published var recentFiles: [FileItem] = []
    @Published var selectedFiles: Set<URL> = []

    private let fileManager = FileManager.default
    private let supportedExtensions = ["tif", "tiff", "jpg", "jpeg"]

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder to browse images"

        if panel.runModal() == .OK, let url = panel.url {
            addOpenedFolder(url)
        }
    }

    func addOpenedFolder(_ url: URL) {
        if !openedFolders.contains(url) {
            openedFolders.append(url)
        }
    }

    func removeOpenedFolder(_ url: URL) {
        openedFolders.removeAll { $0 == url }
    }

    func getFiles(in directory: URL) -> [FileItem] {
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        ) else { return [] }

        var items: [FileItem] = []

        for case let fileURL as URL in enumerator {
            guard supportedExtensions.contains(fileURL.pathExtension.lowercased()) else { continue }

            do {
                let attributes = try fileURL.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])

                let item = FileItem(
                    url: fileURL,
                    name: fileURL.lastPathComponent,
                    size: Int64(attributes.fileSize ?? 0),
                    modified: attributes.contentModificationDate ?? Date()
                )
                items.append(item)
            } catch {
                continue
            }
        }

        return items.sorted { $0.name < $1.name }
    }

    func addToRecent(_ url: URL) {
        // Remove if already exists
        recentFiles.removeAll { $0.url == url }

        // Add to beginning
        if let attributes = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]) {
            let item = FileItem(
                url: url,
                name: url.lastPathComponent,
                size: Int64(attributes.fileSize ?? 0),
                modified: attributes.contentModificationDate ?? Date()
            )
            recentFiles.insert(item, at: 0)

            // Keep only last 10
            if recentFiles.count > 10 {
                recentFiles = Array(recentFiles.prefix(10))
            }
        }
    }

    func toggleSelection(_ url: URL, multiSelect: Bool) {
        if multiSelect {
            if selectedFiles.contains(url) {
                selectedFiles.remove(url)
            } else {
                selectedFiles.insert(url)
            }
        } else {
            selectedFiles = [url]
        }
    }

    func clearSelection() {
        selectedFiles.removeAll()
    }

    func openQuickFolder(_ directory: FileManager.SearchPathDirectory) {
        guard let url = fileManager.urls(for: directory, in: .userDomainMask).first else { return }
        addOpenedFolder(url)
    }
}
