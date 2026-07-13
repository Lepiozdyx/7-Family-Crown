import SwiftUI
import SwiftData

struct CoatsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var emblems: [EmblemModel]

    @State private var showCreate = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                if emblems.isEmpty {
                    emptyState
                } else {
                    emblemGrid
                }
            }

            Button {
                showCreate = true
            } label: {
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
        .bg()
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreate) {
            CreateEmblemView()
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
     
            Spacer()
            Text("Your collection of coats of arms")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
          
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Empty State

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
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Spacer(minLength: 8)

            Text("Click \"+\" to create a coat of arms")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.65))

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Grid
    private var emblemGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(emblems) { emblem in
                    EmblemCell(emblem: emblem)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100) // отступ под FAB
        }
    }
}

// MARK: - Emblem Cell

private struct EmblemCell: View {
    let emblem: EmblemModel

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.18, green: 0.10, blue: 0.08))
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.65, blue: 0.15),
                                    Color(red: 0.6, green: 0.4, blue: 0.05),
                                    Color(red: 0.85, green: 0.65, blue: 0.15),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )

            // Эмблема
            shieldView
                .padding(24)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var shieldView: some View {
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
        .shadow(color: .black.opacity(0.4), radius: 6, y: 4)
    }

    @ViewBuilder
    private func symbolView(index: Int, total: Int, symbol: EmblemSymbols, size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        let symbolSize = w * (total == 1 ? 0.35 : 0.25)

        var xOffset: CGFloat = w / 2
        var yOffset: CGFloat = h / 2

        switch total {
        case 2:
            yOffset = index == 0 ? h * 0.3 : h * 0.7
        case 3:
            if index == 0 { xOffset = w * 0.25; yOffset = h * 0.3 }
            else if index == 1 { xOffset = w * 0.75; yOffset = h * 0.3 }
            else { xOffset = w * 0.5; yOffset = h * 0.7 }
        case 4:
            xOffset = (index % 2 == 0) ? w * 0.3 : w * 0.7
            yOffset = (index < 2) ? h * 0.3 : h * 0.7
        default:
            break
        }

        return Image(symbol.asset)
            .resizable()
            .scaledToFit()
            .frame(width: symbolSize, height: symbolSize)
            .position(x: xOffset, y: yOffset)
    }
}

struct CreateEmblemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColors: [EmblemColors] = [.yellow]
    @State private var selectedSymbols: [EmblemSymbols] = []
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                Spacer()
                Text("Create your own coat of arms")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                // Пустая вьюшка для баланса заголовка
                Image(systemName: "arrow.left").opacity(0)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView {
                shieldPreviewArea
                    .frame(height: 320)
                    .padding(.vertical, 20)
                
                // Выбор Цветов
                VStack(alignment: .leading, spacing: 12) {
                    Text("Color:")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2)) // Золотистый оттенок
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(EmblemColors.allCases, id: \.self) { color in
                                colorButton(for: color)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Выбор Символов
                VStack(alignment: .leading, spacing: 12) {
                    Text("Symbol:")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(EmblemSymbols.allCases, id: \.self) { symbol in
                                symbolButton(for: symbol)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Кнопка сохранения
                Button(action: saveEmblem) {
                    Text("Save")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.15, green: 0.1, blue: 0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color(red: 0.8, green: 0.6, blue: 0.2), lineWidth: 1.5)
                        )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
        .bg()
        .navigationBarHidden(true)
    }
    
    // MARK: - Превью эмблемы
    private var shieldPreviewArea: some View {
        ZStack {
            if selectedColors.isEmpty {
                // На случай непредвиденного поведения (хотя пустой массив мы запретили)
                Color.clear
                    .aspectRatio(0.8, contentMode: .fit)
            } else {
                // Отрисовка выбранных фонов
                ForEach(Array(selectedColors.enumerated()), id: \.element) { index, color in
                    Image(color.asset)
                        .resizable()
                        .scaledToFit()
                        .clipShape(ShieldMask(index: index, total: selectedColors.count))
                }
            }
        }
        .overlay {
            // Оверлей для символов — GeometryReader идеально повторяет размеры отмасштабированного щита
            GeometryReader { geo in
                ForEach(Array(selectedSymbols.enumerated()), id: \.element) { index, symbol in
                    symbolView(for: index, total: selectedSymbols.count, symbol: symbol, size: geo.size)
                }
            }
        }
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
    }
    
    // MARK: - Позиционирование символов
    @ViewBuilder
    private func symbolView(for index: Int, total: Int, symbol: EmblemSymbols, size: CGSize) -> some View {
        let w = size.width
        let h = size.height
        
        let symbolSize = w * (total == 1 ? 0.35 : 0.25) // Уменьшаем символ, если их несколько
        
        var xOffset: CGFloat = w / 2
        var yOffset: CGFloat = h / 2
        
        switch total {
        case 2:
            yOffset = index == 0 ? h * 0.3 : h * 0.7
        case 3:
            // 2 сверху, 1 снизу
            if index == 0 {
                xOffset = w * 0.25
                yOffset = h * 0.3
            } else if index == 1 {
                xOffset = w * 0.75
                yOffset = h * 0.3
            } else {
                xOffset = w * 0.5
                yOffset = h * 0.7
            }
        case 4:
            xOffset = (index % 2 == 0) ? w * 0.3 : w * 0.7
            yOffset = (index < 2) ? h * 0.3 : h * 0.7
        default:
            break
        }
        
        return Image(symbol.asset)
            .resizable()
            .scaledToFit()
            .frame(width: symbolSize, height: symbolSize)
            .position(x: xOffset, y: yOffset)
    }
    
    // MARK: - Кнопки выбора
    private func colorButton(for color: EmblemColors) -> some View {
        let isSelected = selectedColors.contains(color)
        return Button(action: { toggleColor(color) }) {
            Circle()
                .fill(color.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle().stroke(isSelected ? Color.white : Color(red: 0.8, green: 0.6, blue: 0.2), lineWidth: isSelected ? 3 : 2)
                )
                .shadow(radius: isSelected ? 5 : 0)
        }
    }
    
    private func symbolButton(for symbol: EmblemSymbols) -> some View {
        let isSelected = selectedSymbols.contains(symbol)
        return Button(action: { toggleSymbol(symbol) }) {
            ZStack {
                Circle().fill(Color.black.opacity(0.8))
                Image(symbol.asset)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
            }
            .frame(width: 55, height: 55)
            .overlay(
                Circle().stroke(isSelected ? Color.white : Color(red: 0.8, green: 0.6, blue: 0.2), lineWidth: isSelected ? 3 : 2)
            )
            .shadow(radius: isSelected ? 5 : 0)
        }
    }
    
    // MARK: - Логика контролов и сохранения
    private func toggleColor(_ color: EmblemColors) {
        if let index = selectedColors.firstIndex(of: color) {
            // Удаляем цвет, только если он не последний
            if selectedColors.count > 1 {
                selectedColors.remove(at: index)
            }
        } else if selectedColors.count < 4 {
            selectedColors.append(color)
        }
    }
    
    private func toggleSymbol(_ symbol: EmblemSymbols) {
        if let index = selectedSymbols.firstIndex(of: symbol) {
            selectedSymbols.remove(at: index)
        } else if selectedSymbols.count < 4 {
            selectedSymbols.append(symbol)
        }
    }
    
    private func saveEmblem() {
        let newEmblem = EmblemModel(color: selectedColors, symbols: selectedSymbols)
        modelContext.insert(newEmblem)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save emblem: \(error.localizedDescription)")
        }
    }
}

// MARK: - Кастомная фигура для обрезки (Mask)
struct ShieldMask: Shape {
    var index: Int
    var total: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        switch total {
        case 1:
            path.addRect(rect)
        case 2:
            if index == 0 {
                path.addRect(CGRect(x: 0, y: 0, width: w, height: h / 2))
            } else {
                path.addRect(CGRect(x: 0, y: h / 2, width: w, height: h / 2))
            }
        case 3:
            if index == 0 {
                path.addRect(CGRect(x: 0, y: 0, width: w, height: h / 2))
            } else if index == 1 {
                path.addRect(CGRect(x: 0, y: h / 2, width: w / 2, height: h / 2))
            } else {
                path.addRect(CGRect(x: w / 2, y: h / 2, width: w / 2, height: h / 2))
            }
        case 4:
            if index == 0 { // Top Left
                path.addRect(CGRect(x: 0, y: 0, width: w / 2, height: h / 2))
            } else if index == 1 { // Top Right
                path.addRect(CGRect(x: w / 2, y: 0, width: w / 2, height: h / 2))
            } else if index == 2 { // Bottom Left
                path.addRect(CGRect(x: 0, y: h / 2, width: w / 2, height: h / 2))
            } else { // Bottom Right
                path.addRect(CGRect(x: w / 2, y: h / 2, width: w / 2, height: h / 2))
            }
        default:
            path.addRect(rect)
        }
        
        return path
    }
}
