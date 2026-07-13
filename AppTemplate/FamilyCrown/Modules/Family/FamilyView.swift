import SwiftUI
import SwiftData

// MARK: - Family View

struct FamilyView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var families: [FamilyModel]

    @State private var showCreate = false

    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24),
    ]

    @State private var selectedFamily: FamilyModel? = nil

    var body: some View {
        VStack(spacing: 0) {
            
            if families.isEmpty {
                emptyState
            } else {
                familyGrid
            }
            
            HStack {
                Spacer()
                fabButton
            }
        }
        .bg()
        .sheet(isPresented: $showCreate) {
            CreateFamilyView()
        }
        .fullScreenCover(item: $selectedFamily) { family in
            FamilyDetailView(family: family)
        }
    }

    // MARK: Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(.emptyAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 240)
                .shadow(color: .black.opacity(0.4), radius: 16, y: 8)

            Spacer(minLength: 24)

            Text("Nothing here yet")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.85, blue: 0.1), Color(red: 0.95, green: 0.6, blue: 0.0)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Spacer(minLength: 8)

            Text("Click \"+\" to create your kingdom")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.65))

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Grid

    private var familyGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 32) {
                ForEach(families) { family in
                    FamilyCell(family: family) {
                        selectedFamily = family
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }

    // MARK: FAB

    private var fabButton: some View {
        Button { showCreate = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.65, blue: 0.0),
                                 Color(red: 0.95, green: 0.45, blue: 0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .orange.opacity(0.5), radius: 10, y: 4)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 36)
    }
}

// MARK: - Family Cell

private struct FamilyCell: View {
    let family: FamilyModel
    let onTap: () -> Void
    @Query private var emblems: [EmblemModel]

    private var emblem: EmblemModel? {
        emblems.first { $0.id == family.emblem }
    }

    var body: some View {
        Button { onTap() } label: {
        VStack(spacing: 16) {
            shieldView
                .frame(height: 150)
                .shadow(color: .black.opacity(0.5), radius: 8, y: 6)

            Text(family.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(Color(red: 0.42, green: 0.20, blue: 0.08))
                )
        }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var shieldView: some View {
        if let emblem {
            EmblemShieldView(emblem: emblem)
        } else {
            Image(.emptyAsset)
                .resizable()
                .scaledToFit()
                .opacity(0.5)
        }
    }
}

// MARK: - Emblem Shield View (переиспользуемый)

struct EmblemShieldView: View {
    let emblem: EmblemModel

    var body: some View {
        ZStack {
            ForEach(Array(emblem.color.enumerated()), id: \.element) { index, color in
                Image(color.asset)
                    .resizable()
                    .scaledToFit()
                    .clipShape(ShieldMask(index: index, total: emblem.color.count))
            }
        }
        .overlay(
            GeometryReader { geo in
                ForEach(Array(emblem.symbols.enumerated()), id: \.element) { index, symbol in
                    symbolView(index: index, total: emblem.symbols.count, symbol: symbol, size: geo.size)
                }
            }
        )
    }

    @ViewBuilder
    private func symbolView(index: Int, total: Int, symbol: EmblemSymbols, size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        let symbolSize = w * (total == 1 ? 0.35 : 0.25)
        var xOffset = w / 2
        var yOffset = h / 2

        switch total {
        case 2:
            yOffset = index == 0 ? h * 0.3 : h * 0.7
        case 3:
            if index == 0 { xOffset = w * 0.25; yOffset = h * 0.3 }
            else if index == 1 { xOffset = w * 0.75; yOffset = h * 0.3 }
            else { yOffset = h * 0.7 }
        case 4:
            xOffset = (index % 2 == 0) ? w * 0.3 : w * 0.7
            yOffset = (index < 2) ? h * 0.3 : h * 0.7
        default: break
        }

        return Image(symbol.asset)
            .resizable()
            .scaledToFit()
            .frame(width: symbolSize, height: symbolSize)
            .position(x: xOffset, y: yOffset)
    }
}

// MARK: - Create Family View

struct CreateFamilyView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var emblems: [EmblemModel]

    @State private var dynastyName = ""
    // Храним только UUID — не ссылку на объект
    @State private var selectedEmblemID: UUID? = nil

    private var selectedEmblem: EmblemModel? {
        guard let id = selectedEmblemID else { return nil }
        return emblems.first { $0.id == id }
    }

    private let maxChars = 60

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.50, green: 0.18, blue: 0.10),
                         Color(red: 0.22, green: 0.06, blue: 0.04)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Nav
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("New Kingdom")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "xmark").opacity(0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                    // Превью щита
                    shieldPreview
                        .frame(height: 200)
                        .padding(.bottom, 32)

                    // Название
                    nameSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)

                    // Выбор эмблемы
                    emblemSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)

                    // Кнопка
                    Button { saveFamily() } label: {
                        Text("Create Kingdom")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                Group {
                                    if canSave {
                                        LinearGradient(
                                            colors: [Color(red: 0.85, green: 0.55, blue: 0.05),
                                                     Color(red: 0.6, green: 0.3, blue: 0.0)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(
                                        canSave ? Color(red: 0.85, green: 0.65, blue: 0.15) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .disabled(!canSave)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .hideKeyboardOnTap()
    }

    private var canSave: Bool {
        !dynastyName.trimmingCharacters(in: .whitespaces).isEmpty && selectedEmblemID != nil
    }

    // MARK: Shield Preview

    private var shieldPreview: some View {
        Group {
            if let emblem = selectedEmblem {
                EmblemShieldView(emblem: emblem)
                    .shadow(color: .black.opacity(0.5), radius: 12, y: 8)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "shield.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.25))
                    Text("Select an emblem below")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.35))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Dynasty Name")

            ZStack(alignment: .bottomTrailing) {
                TextField("", text: $dynastyName, prompt:
                    Text("e.g. The Ivanov Dynasty")
                        .foregroundColor(.white.opacity(0.25))
                )
                .font(.system(size: 16))
                .foregroundColor(.white)
                .tint(.orange)
                .padding(14)
                .onChange(of: dynastyName) { _, new in
                    if new.count > maxChars { dynastyName = String(new.prefix(maxChars)) }
                }

                Text("\(dynastyName.count)/\(maxChars)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.trailing, 12)
                    .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(red: 0.8, green: 0.6, blue: 0.2).opacity(0.4), lineWidth: 1.5)
                    )
            )
        }
    }

    // MARK: Emblem Section

    private var emblemSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Choose Emblem")

            if emblems.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.95, green: 0.72, blue: 0.1))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No emblems yet")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Go to the Emblems tab to create one first")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.45))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.95, green: 0.72, blue: 0.1).opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color(red: 0.95, green: 0.72, blue: 0.1).opacity(0.3), lineWidth: 1)
                        )
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(emblems) { emblem in
                            emblemPickerCell(emblem)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func emblemPickerCell(_ emblem: EmblemModel) -> some View {
        let isSelected = selectedEmblemID == emblem.id

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedEmblemID = emblem.id
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color(red: 0.18, green: 0.10, blue: 0.08))
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected
                                ? LinearGradient(
                                    colors: [Color(red: 0.95, green: 0.72, blue: 0.1),
                                             Color(red: 0.75, green: 0.45, blue: 0.0)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(
                                    colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)],
                                    startPoint: .leading, endPoint: .trailing),
                                lineWidth: isSelected ? 3 : 1.5
                            )
                    )
                    .shadow(color: isSelected ? .orange.opacity(0.4) : .clear, radius: 8)

                EmblemShieldView(emblem: emblem)
                    .padding(16)
            }
            .frame(width: 90, height: 90)
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }

    // MARK: Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
            .textCase(.uppercase)
            .tracking(1)
    }

    // MARK: Save

    private func saveFamily() {
        guard !dynastyName.trimmingCharacters(in: .whitespaces).isEmpty,
              let emblemID = selectedEmblemID else { return }

        let family = FamilyModel(
            emblem: emblemID,
            name: dynastyName.trimmingCharacters(in: .whitespaces),
            members: []
        )
        context.insert(family)
        dismiss()
    }
}

#Preview("Empty") {
    FamilyView()
        .modelContainer(for: [FamilyModel.self, EmblemModel.self], inMemory: true)
}
