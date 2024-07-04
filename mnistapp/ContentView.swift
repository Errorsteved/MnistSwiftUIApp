import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var sharedData = SharedData()
    var body: some View {
        TabView(selection: $selectedTab,
                content:  {
            DrawView(ModelPredict: ModelPredictor())
                .environmentObject(sharedData)
                .tabItem {
                    VStack{
                        Image(systemName: selectedTab == .home ?  "squareshape.dotted.squareshape" : "squareshape.squareshape.dotted")
                        Text("Predicts")
                            .font(.custom("Futura", size: 10))
                    }
                }
                .tag(Tab.home)
            Errorpics()
                .environmentObject(sharedData)
                .tabItem {
                    Image(systemName: selectedTab == .home ?  "photo" : "photo.fill")
                    Text("ErrorPics")
                        .font(.custom("Futura", size: 10))
                }
                .tag(Tab.errorpics)
        })
        
    }
}
enum Tab {
    case home
    case errorpics
}
#Preview {
    ContentView()
}
