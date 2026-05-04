import Foundation
import SwiftUI
import UIKit

final class ImageStore {
    static let shared = ImageStore()

    private let fileManager = FileManager.default
    private let folderName = "RestaurantPhotos"

    private init() {}

    func saveImageData(_ data: Data) throws -> String {
        let fileName = UUID().uuidString + ".jpg"
        let url = try photosFolderURL().appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    func loadImage(fileName: String) -> Image? {
        guard let url = try? photosFolderURL().appendingPathComponent(fileName),
              let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }

    func deleteImage(fileName: String) {
        guard let url = try? photosFolderURL().appendingPathComponent(fileName) else {
            return
        }
        try? fileManager.removeItem(at: url)
    }

    private func photosFolderURL() throws -> URL {
        let documents = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folderURL = documents.appendingPathComponent(folderName, isDirectory: true)
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        return folderURL
    }
}
