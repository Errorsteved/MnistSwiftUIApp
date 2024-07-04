import Foundation

struct ImageCounterData: Codable {
    var imageCounter: Int
}

class ModifyJSON {
    static let shared = ModifyJSON()
    
    private let directoryName = "mnistapp/data"
    private let fileName = "imageCounter.json"
    
    private var directoryURL: URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let directoryURL = documentsDirectory?.appendingPathComponent(directoryName)
        
        // 创建目录
        if let directoryURL = directoryURL {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error)")
                return nil
            }
        }
        return directoryURL
    }
    
    private var fileURL: URL? {
        return directoryURL?.appendingPathComponent(fileName)
    }
    
    func save(_ imageCounter: Int) {
        let imageCounterData = ImageCounterData(imageCounter: imageCounter)
        guard let fileURL = fileURL else { return }
        
        do {
            let data = try JSONEncoder().encode(imageCounterData)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    func load() -> Int {
        guard let fileURL = fileURL else { return 0 }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let imageCounterData = try JSONDecoder().decode(ImageCounterData.self, from: data)
            return imageCounterData.imageCounter
        } catch {
            print("Failed to load data: \(error)")
            return 0
        }
    }
}
