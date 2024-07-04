//
//  DrawView.swift
//  mnistapp
//
//  Created by errorsteve on 2024/7/1.
//

import SwiftUI

struct DrawView: View {
    @State private var image: UIImage? = nil
    @State private var scaledImage: UIImage? = nil
    @State private var lineWidth: CGFloat = 5.0 // 默认线条宽度
    @State private var numberInput: String = ""
    @State private var isEditing: Bool = false
    @EnvironmentObject var sharedData: SharedData
    @ObservedObject var ModelPredict: ModelPredictor
    var body: some View {
        ZStack{
            Image("back1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(1.8) // 缩小比例为 0.5
                .edgesIgnoringSafeArea(.all)
                .offset(x: 155, y: 60)
                .opacity(0.8)
            VStack{
                Spacer()
                Rectangle()
                    .frame(width: 600,height: 90)
                    .foregroundColor(.white)
                    .opacity(0.9)
            }
            .ignoresSafeArea()
            
            VStack {
                CanvasView(image: $image, lineWidth: $lineWidth)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .aspectRatio(contentMode: .fit)
                    .modifier(RotatingBorder())
                
                HStack{
                    if let scaledImage = scaledImage {
                        Image(uiImage: scaledImage)
                            .resizable()
                            .frame(width: 28, height: 28)
                            .border(Color.green, width: 3)
                            .padding(.horizontal)
                    }
                    
                    Text(ModelPredict.prediction.isEmpty ? "Number" :  ModelPredict.prediction)
                        .font(.custom("Futura", size: 30))
                }
                .padding(.top, 30)
                
                HStack{
                    Slider(value: $lineWidth, in: 1...20, step: 1)
                        .accentColor(.blue)
                        .padding()
                    Text("\(Int(lineWidth))")
                        .font(.custom("Futura", size: 30))
                        .foregroundColor(.white)
                        
                }
                .padding(.horizontal,120)
                
                HStack{
                    /*Button("Convert") {
                     if let image = image {
                     scaledImage = resizeImage(image: image, targetSize: CGSize(width: 28, height: 28))
                     }
                     }
                     .padding()*/
                    
                    Button(action:{
                        image = nil
                        scaledImage = nil
                    }) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 50)
                            Text("Clear")
                                .foregroundColor(.white)
                                .font(.custom("Futura", size: 25))
                        }
                    }
                    .padding()
                    
                    Button(action:{
                        if let image = image {
                            scaledImage = resizeImage(image: image, targetSize: CGSize(width: 28, height: 28))
                        }
                        if let scaledImage = scaledImage, let cgImage = scaledImage.cgImage {
                            ModelPredict.predict(image: cgImage)
                        } else {
                            print("Nothing to predict")
                        }
                    })
                    {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 50)
                            Text("Predict")
                                .foregroundColor(.white)
                                .font(.custom("Futura", size: 25))
                        }
                    }
                    .padding()
                }
                HStack{
                    Button(action: {
                        if let scaledImage = scaledImage {
                            markImageAsError(image: scaledImage)
                        } else {
                            print("没有可标记的图像")
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 50)
                            Text("Save")
                                .foregroundColor(.white)
                                .font(.custom("Futura", size: 25))
                        }
                    }
                    .padding()
                    
                    TextField("输入数字", text: $numberInput, onEditingChanged: { editing in
                        isEditing = editing
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .padding()
                }
            }
            .background(Color.clear) // 背景设置为透明
            .contentShape(Rectangle()) // 设置点击区域
            .onTapGesture {
                if isEditing {
                    hideKeyboard()
                }
            }
        }
    }
    
    private func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor that preserves aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Create a graphics context and draw the scaled image into it
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(origin: .zero, size: targetSize))
        
        image.draw(in: CGRect(x: (targetSize.width - scaledImageSize.width) / 2,
                              y: (targetSize.height - scaledImageSize.height) / 2,
                              width: scaledImageSize.width,
                              height: scaledImageSize.height))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Convert to grayscale
        let grayScaleImage = convertToGrayScale(image: scaledImage)
        
        return grayScaleImage
    }
    
    func convertToGrayScale(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        let ciImage = CIImage(image: image)
        
        let grayscale = ciImage?.applyingFilter("CIPhotoEffectMono")
        
        let cgImage = context.createCGImage(grayscale!, from: grayscale!.extent)
        
        return UIImage(cgImage: cgImage!)
    }
    
    func markImageAsError(image: UIImage) {
        sharedData.saveImage(image: image, numberInput: numberInput)
        let picsdirectory = sharedData.getDocumentsDirectory().appendingPathComponent("mnistapp/pics")
        sharedData.loadImages(from: picsdirectory)
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var image: UIImage?
    @Binding var lineWidth: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panGesture))
        view.addGestureRecognizer(panGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let image = image {
            uiView.layer.contents = image.cgImage
        } else {
            uiView.layer.contents = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, lineWidth: $lineWidth)
    }
    
    class Coordinator: NSObject {
        var parent: CanvasView
        var path = UIBezierPath()
        var previousTouchPoint = CGPoint.zero
        @Binding var lineWidth: CGFloat
        
        init(_ parent: CanvasView, lineWidth: Binding<CGFloat>) {
            self.parent = parent
            _lineWidth = lineWidth
            super.init()
            path.lineWidth = lineWidth.wrappedValue
        }
        
        @objc func panGesture(gesture: UIPanGestureRecognizer) {
            let touchPoint = gesture.location(in: gesture.view)
            
            if gesture.state == .began {
                path.move(to: touchPoint)
                previousTouchPoint = touchPoint
            } else if gesture.state == .changed {
                path.addLine(to: touchPoint)
                previousTouchPoint = touchPoint
                
                UIGraphicsBeginImageContext(gesture.view!.frame.size)
                if let context = UIGraphicsGetCurrentContext() {
                    gesture.view!.layer.render(in: context)
                    context.setLineWidth(lineWidth)
                    context.setStrokeColor(UIColor.white.cgColor)
                    context.addPath(path.cgPath)
                    context.strokePath()
                }
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                parent.image = image
                gesture.view!.layer.contents = image?.cgImage
            } else if gesture.state == .ended {
                UIGraphicsBeginImageContext(gesture.view!.frame.size)
                if let context = UIGraphicsGetCurrentContext() {
                    gesture.view!.layer.render(in: context)
                    context.setLineWidth(lineWidth)
                    context.setStrokeColor(UIColor.white.cgColor)
                    context.addPath(path.cgPath)
                    context.strokePath()
                }
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                parent.image = image
                gesture.view!.layer.contents = image?.cgImage
                path.removeAllPoints()
            }
        }
    }
}

#Preview {
    DrawView(ModelPredict: ModelPredictor())
}
