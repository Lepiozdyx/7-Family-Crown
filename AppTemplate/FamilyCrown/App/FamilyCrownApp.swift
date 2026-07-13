import SwiftUI
import SwiftData

struct FamilyCrownApp: View {
    var body: some View {
        TabBarView()
            .preferredColorScheme(.light)
            .modelContainer(for: [
                EmblemModel.self,
                FamilyModel.self,
                FamilyMember.self,
            ])
    }
}
