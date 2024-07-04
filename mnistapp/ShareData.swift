//
//  ShareData.swift
//  mnistapp
//
//  Created by errorsteve on 2024/7/2.
//
import SwiftUI
import Foundation
class SharedData: ObservableObject {
    @Published var savedImagePath: String = ""
    //@Published var imageCounter: Int = 0
    @Published var images: [(image: UIImage, name: String)] = []
    static let shared = SharedData()
        
        @Published var imageCounter: Int = 0 {
            didSet {
                ModifyJSON.shared.save(imageCounter)
            }
        }
        
        public init() {
            self.imageCounter = ModifyJSON.shared.load()
        }
    
    func loadImages(from directoryURL: URL) {
        let fileManager = FileManager.default
        var loadedImages: [(image: UIImage, name: String)] = []
        
        if let files = try? fileManager.contentsOfDirectory(atPath: directoryURL.path) {
            for file in files {
                let fileURL = directoryURL.appendingPathComponent(file)
                if let uiImage = UIImage(contentsOfFile: fileURL.path) {
                    loadedImages.append((image: uiImage, name: file))
                }
            }
        }
        
        images = loadedImages
    }
    
    func deleteAllImages(in directoryURL: URL) {
        let fileManager = FileManager.default
        
        if let files = try? fileManager.contentsOfDirectory(atPath: directoryURL.path) {
            for file in files {
                let fileURL = directoryURL.appendingPathComponent(file)
                try? fileManager.removeItem(at: fileURL)
            }
            imageCounter = 0
        }
        
        images.removeAll()
    }
    
    func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        
        func createDirectoryIfNeeded(directory: URL) {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: directory.path) {
                try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        func saveImage(image: UIImage, numberInput: String) {
            if let markedImage = image.pngData() {
                let number = numberInput.isEmpty ? "0" : numberInput
                let directory = getDocumentsDirectory().appendingPathComponent("mnistapp")
                createDirectoryIfNeeded(directory: directory)
                let picsdirectory = directory.appendingPathComponent("pics")
                print(picsdirectory)
                createDirectoryIfNeeded(directory: picsdirectory)
                let filename = picsdirectory.appendingPathComponent("\(imageCounter)_digital_\(number).png")
                try? markedImage.write(to: filename)
                imageCounter += 1
                savedImagePath = filename.path // 保存图片路径
                print("Saved image path: \(savedImagePath)") // 打印保存路径
            }
        }
}


