import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FamilyView()
                .tabItem {
                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 24))
                        Text("Family")
                    }
                }
                .tag(0)
            
            CoatsView()
                .tabItem {
                    VStack {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 24))
                        Text("Coats of arms")
                    }
                }
                .tag(1)
        }
//        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .tint(Color.orange)
    }
}

struct Mock: View {
    var body: some View {
        VStack {
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .bg()
    }
}

#Preview {
    TabBarView()
}
