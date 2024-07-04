import SwiftUI

struct Errorpics: View {
    @EnvironmentObject var sharedData: SharedData
    
    var body: some View {
        let directory = getDocumentsDirectory().appendingPathComponent("mnistapp")
        let picsdirectory = directory.appendingPathComponent("pics")
        VStack {
            Button(action: {
                sharedData.deleteAllImages(in: directory)
            }) {
                Text("删除所有图片")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding()
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            if sharedData.images.isEmpty {
                VStack{
                    Spacer()
                    Text("无图片")
                        .onAppear {
                            sharedData.loadImages(from: picsdirectory)
                        }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        // 对 images 进行排序
                        let sortedImages = sharedData.images.sorted { image1, image2 in
                            let number1 = Int(image1.name.split(separator: "_").first!) ?? 0
                            let number2 = Int(image2.name.split(separator: "_").first!) ?? 0
                            return number1 > number2
                        }
                        
                        ForEach(sortedImages, id: \.name) { imageItem in
                            VStack {
                                Image(uiImage: imageItem.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                Text(imageItem.name)
                            }
                            .padding()
                        }
                    }
                }
            }
            
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct Errorpics_Previews: PreviewProvider {
    static var previews: some View {
        let dir = URL(fileURLWithPath: "/Users/errorstd/Library/Developer/CoreSimulator/Devices/E48CB8C0-F6A6-407A-BFC0-2DFE9E61D356/data/Containers/Data/Application/EF93EBE0-D4FA-45CA-A305-E429C1FAB649/Documents/mnistapp/pics")
        let sharedData = SharedData()
        sharedData.loadImages(from: dir)
        
        return Errorpics()
            .environmentObject(sharedData)
    }
}

