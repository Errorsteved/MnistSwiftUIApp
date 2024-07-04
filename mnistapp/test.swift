import SwiftUI

struct test: View {
    var body: some View {
        Image("back1")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .modifier(RotatingBorder())
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
