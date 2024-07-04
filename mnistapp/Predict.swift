import SwiftUI
import CoreML

// 创建一个 ObservableObject 类来管理模型预测
class ModelPredictor: ObservableObject {
    @Published var preimage: UIImage? = nil
    @Published var prediction: String = ""
    @Published var probabilities: [Double] = []
    
    // 加载 Core ML 模型
    let model: mnist_model = {
        do {
            let config = MLModelConfiguration()
            return try mnist_model(configuration: config)
        } catch {
            print("加载模型失败: \(error)")
            fatalError("加载模型失败")
        }
    }()
    
    func predict(image: CGImage) {
        // 将图像转换为模型输入格式
        guard let pixelBuffer = image.pixelBuffer(width: 28, height: 28) else {
            print("图像转换失败")
            return
        }
        
        // 使用模型进行预测
        do {
            let output = try model.prediction(conv2d_input: pixelBuffer)
            // 获取预测结果
            let predictedLabel = self.argmax(output.Identity)
            let probabilities = self.softmax(output.Identity)
            print("predictedLabel: \(predictedLabel)")
            print("probabilities: \(probabilities)")
            DispatchQueue.main.async {
                self.prediction = "预测标签: \(predictedLabel)"
                self.probabilities = probabilities
                print("\(self.prediction)")
            }
        } catch {
            print("预测失败: \(error)")
        }
    }
    
    // 计算 argmax
    func argmax(_ multiArray: MLMultiArray) -> Int {
        var maxIndex = 0
        var maxValue = multiArray[0].doubleValue
        for i in 1..<multiArray.count {
            if multiArray[i].doubleValue > maxValue {
                maxValue = multiArray[i].doubleValue
                maxIndex = i
            }
        }
        return maxIndex
    }
    
    // 计算 softmax 概率分布
    func softmax(_ multiArray: MLMultiArray) -> [Double] {
        let count = multiArray.count
        var values = [Double](repeating: 0.0, count: count)
        
        // 计算每个值的指数并求和
        var sum = 0.0
        for i in 0..<count {
            values[i] = exp(multiArray[i].doubleValue)
            sum += values[i]
        }
        
        // 计算 softmax 概率分布
        for i in 0..<count {
            values[i] /= sum
        }
        
        return values
    }
}


// 扩展 CGImage 以转换为 CVPixelBuffer
extension CGImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
            var pixelBuffer: CVPixelBuffer?
            let attrs = [
                kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
                kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_OneComponent8
            ] as CFDictionary
            let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                             kCVPixelFormatType_OneComponent8, attrs, &pixelBuffer)
            guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
                return nil
            }
            
            CVPixelBufferLockBaseAddress(buffer, [])
            let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                    space: CGColorSpaceCreateDeviceGray(),
                                    bitmapInfo: CGImageAlphaInfo.none.rawValue)
            
            context?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
            CVPixelBufferUnlockBaseAddress(buffer, [])
            
            return buffer
        }
}
