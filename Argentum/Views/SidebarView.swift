//
//  SidebarView.swift
//  Argentum
//
//  Created by Maxim Eliseyev on 25.11.2025.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedFile: URL?
    @ObservedObject var fileManager: FileManagerService

    @State private var expandedFolders: Set<URL> = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Files")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primaryText)

                Spacer()

                Button(action: { fileManager.openFolder() }) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 13))
                        .foregroundColor(.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Spacing.regular)
            .padding(.vertical, Spacing.small)
            .background(Color.panelBackground)

            Divider()

            // File browser
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Quick access folders
                    QuickAccessSection(fileManager: fileManager)

                    if !fileManager.openedFolders.isEmpty {
                        Divider()
                            .padding(.vertical, Spacing.small)

                        // Opened folders
                        ForEach(fileManager.openedFolders, id: \.self) { folder in
                            FolderTreeView(
                                folder: folder,
                                selectedFile: $selectedFile,
                                expandedFolders: $expandedFolders,
                                fileManager: fileManager
                            )
                        }
                    }

                    // Recent files
                    if !fileManager.recentFiles.isEmpty {
                        Divider()
                            .padding(.vertical, Spacing.small)

                        RecentFilesSection(
                            selectedFile: $selectedFile,
                            recentFiles: fileManager.recentFiles
                        )
                    }
                }
                .padding(.vertical, Spacing.small)
            }
        }
        .background(Color.panelBackground)
    }
}

// MARK: - Quick Access Section

struct QuickAccessSection: View {
    @ObservedObject var fileManager: FileManagerService

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.tiny) {
            Text("QUICK ACCESS")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.tertiaryText)
                .padding(.horizontal, Spacing.regular)

            QuickAccessButton(
                icon: "folder",
                title: "Documents",
                action: { fileManager.openQuickFolder(.documentDirectory) }
            )

            QuickAccessButton(
                icon: "photo.on.rectangle",
                title: "Pictures",
                action: { fileManager.openQuickFolder(.picturesDirectory) }
            )

            QuickAccessButton(
                icon: "desktopcomputer",
                title: "Desktop",
                action: { fileManager.openQuickFolder(.desktopDirectory) }
            )
        }
    }
}

struct QuickAccessButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.small) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.secondaryText)
                    .frame(width: 16)

                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.primaryText)

                Spacer()
            }
            .padding(.horizontal, Spacing.regular)
            .padding(.vertical, Spacing.small - 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Folder Tree View

struct FolderTreeView: View {
    let folder: URL
    @Binding var selectedFile: URL?
    @Binding var expandedFolders: Set<URL>
    @ObservedObject var fileManager: FileManagerService

    @State private var items: [FileItem] = []

    var isExpanded: Bool {
        expandedFolders.contains(folder)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Folder header
            Button(action: { toggleExpanded() }) {
                HStack(spacing: Spacing.small) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.tertiaryText)
                        .frame(width: 12)

                    Image(systemName: "folder.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.accentColor)

                    Text(folder.lastPathComponent)
                        .font(.system(size: 12))
                        .foregroundColor(.primaryText)

                    Spacer()

                    Text("\(items.count)")
                        .font(.system(size: 10))
                        .foregroundColor(.tertiaryText)
                }
                .padding(.horizontal, Spacing.regular)
                .padding(.vertical, Spacing.small)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button("Remove from List") {
                    fileManager.removeOpenedFolder(folder)
                }
                Button("Reveal in Finder") {
                    Task { @MainActor in
                        NSWorkspace.shared.activateFileViewerSelecting([folder])
                    }
                }
            }

            // Folder contents
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(items) { item in
                        FileItemRow(
                            item: item,
                            isSelected: selectedFile == item.url,
                            onSelect: {
                                selectedFile = item.url
                                fileManager.addToRecent(item.url)
                            }
                        )
                        .padding(.leading, 24)
                    }
                }
            }
        }
        .onAppear {
            loadItems()
        }
        .onChange(of: folder) { _, _ in
            loadItems()
        }
    }

    private func toggleExpanded() {
        if isExpanded {
            expandedFolders.remove(folder)
        } else {
            expandedFolders.insert(folder)
            loadItems()
        }
    }

    private func loadItems() {
        items = fileManager.getFiles(in: folder)
    }
}

// MARK: - File Item Row

struct FileItemRow: View {
    let item: FileItem
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var thumbnail: NSImage?

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.small) {
                // Thumbnail or icon
                Group {
                    if let thumb = thumbnail {
                        Image(nsImage: thumb)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 12))
                            .foregroundColor(.tertiaryText)
                    }
                }
                .frame(width: 24, height: 24)
                .background(Color.black.opacity(0.1))
                .cornerRadius(4)

                // File info
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 12))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)

                    Text(item.formattedSize)
                        .font(.system(size: 10))
                        .foregroundColor(.tertiaryText)
                }

                Spacer()

                // Status indicator
                if isSelected {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, Spacing.regular)
            .padding(.vertical, Spacing.small)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(CornerRadius.small)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onAppear {
            loadThumbnail()
        }
        .onDrag {
            NSItemProvider(object: item.url as NSURL)
        }
        .contextMenu {
            Button("Reveal in Finder") {
                Task { @MainActor in
                    NSWorkspace.shared.activateFileViewerSelecting([item.url])
                }
            }
        }
    }

    private func loadThumbnail() {
        Task.detached(priority: .background) {
            guard let ciImage = CIImage(contentsOf: item.url) else { return }
            let thumb = await ImageProcessor.shared.generateThumbnail(from: ciImage, size: 24)

            await MainActor.run {
                self.thumbnail = thumb
            }
        }
    }
}

// MARK: - Recent Files Section

struct RecentFilesSection: View {
    @Binding var selectedFile: URL?
    let recentFiles: [FileItem]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.tiny) {
            Text("RECENT")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.tertiaryText)
                .padding(.horizontal, Spacing.regular)

            ForEach(recentFiles.prefix(5)) { item in
                FileItemRow(
                    item: item,
                    isSelected: selectedFile == item.url,
                    onSelect: { selectedFile = item.url }
                )
            }
        }
    }
}
