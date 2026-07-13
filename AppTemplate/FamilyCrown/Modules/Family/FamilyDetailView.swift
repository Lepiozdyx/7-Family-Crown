import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Family Detail View

struct FamilyDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let family: FamilyModel

    @Query private var emblems: [EmblemModel]
    @State private var showAddMember = false
    @State private var selectedMember: FamilyMember? = nil

    private var emblem: EmblemModel? {
        emblems.first { $0.id == family.emblem }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Shield
                        Group {
                            if let emblem {
                                EmblemShieldView(emblem: emblem)
                            } else {
                                Image(.emptyAsset)
                                    .resizable()
                                    .scaledToFit()
                                    .opacity(0.5)
                            }
                        }
                        .frame(width: 160, height: 160)
                        .shadow(color: .black.opacity(0.5), radius: 12, y: 6)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                        // Dynasty name badge
                        Text(family.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.18, green: 0.08, blue: 0.05))
                            )
                            .padding(.bottom, 28)

                        // Members list or empty
                        if family.members.isEmpty {
                            emptyMembersState
                        } else {
                            membersList
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .bg()

            // FAB
            Button { showAddMember = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.65, blue: 0.0),
                                     Color(red: 0.95, green: 0.45, blue: 0.0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .orange.opacity(0.5), radius: 10, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 36)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddMember) {
            CreateMemberView(family: family)
        }
        .fullScreenCover(item: $selectedMember) { member in
            CreateMemberView(family: family, editingMember: member)
        }
    }

    // MARK: Background

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.50, green: 0.18, blue: 0.10),
                     Color(red: 0.22, green: 0.06, blue: 0.04)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: Empty

    private var emptyMembersState: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 60)
            Text("Nothing here yet")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.85, blue: 0.1),
                                 Color(red: 0.95, green: 0.6, blue: 0.0)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
            Text("Click \"+\" to add a family member")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.55))
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Members List

    private var membersList: some View {
        List {
            ForEach(family.members) { member in
                Button { selectedMember = member } label: {
                    memberRow(member)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
            }
            .onDelete { indexSet in
                family.members.remove(atOffsets: indexSet)
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .frame(height: CGFloat(family.members.count) * 78)
    }

    private func memberRow(_ member: FamilyMember) -> some View {
        HStack {
            // Photo or placeholder
            Group {
                if let data = member.photo, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .frame(width: 38, height: 38)
            .clipShape(Circle())
            .background(Circle().fill(Color.white.opacity(0.08)))

            Text(member.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Text(member.title.displayName)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.22, green: 0.10, blue: 0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.65, blue: 0.15),
                                         Color(red: 0.55, green: 0.35, blue: 0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        )
    }
}

// MARK: - Create Member View

struct CreateMemberView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let family: FamilyModel
    var editingMember: FamilyMember? = nil

    @State private var name = ""
    @State private var surname = ""
    @State private var selectedTitle: Title = .knight
    @State private var role = ""
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil

    private var isEditing: Bool { editingMember != nil }

    var body: some View {
        ZStack {
//            background

            VStack {
                VStack(spacing: 0) {
                    // Nav
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text(isEditing ? "Edit Member" : "New Member")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "arrow.left").opacity(0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    ScrollView(showsIndicators: false) {
                        photoPicker
                            .padding(.bottom, 32)
                        
                        // Fields
                        VStack(spacing: 0) {
                            fieldSection(label: "Name") {
                                fieldRow(text: $name, placeholder: "First name")
                            }
                            
                            fieldSection(label: "Surname") {
                                fieldRow(text: $surname, placeholder: "Last name")
                            }
                            
                            fieldSection(label: "Title") {
                                Picker("", selection: $selectedTitle) {
                                    ForEach(Title.allCases, id: \.self) { title in
                                        Text(title.displayName).tag(title)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(Color(red: 0.25, green: 0.10, blue: 0.05))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color(red: 0.98, green: 0.95, blue: 0.88))
                                )
                            }
                            
                            fieldSection(label: "Role") {
                                fieldRow(text: $role, placeholder: "Optional description")
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 32)
                        
                        // Save
                        Button { saveMember() } label: {
                            Text(isEditing ? "Save Changes" : "Add Member")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(canSave ? Color(red: 0.4, green: 0.15, blue: 0.0) : .white.opacity(0.4))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    canSave
                                    ? LinearGradient(
                                        colors: [Color(red: 0.95, green: 0.72, blue: 0.1),
                                                 Color(red: 0.75, green: 0.45, blue: 0.0)],
                                        startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(
                                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)],
                                        startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .disabled(!canSave)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        
                    }
                }
            }
            .bg()
        }
        .navigationBarHidden(true)
        .hideKeyboardOnTap()
        .onAppear {
            // Заполняем поля если режим редактирования
            if let m = editingMember {
                name = m.name
                surname = m.surname
                selectedTitle = m.title
                role = m.role ?? ""
                photoData = m.photo
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !surname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: Background

    private var background: some View {
        LinearGradient(
            colors: [Color(red: 0.38, green: 0.08, blue: 0.04),
                     Color(red: 0.16, green: 0.03, blue: 0.02)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: Photo Picker

    private var photoPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.25, green: 0.08, blue: 0.05))
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.9, green: 0.7, blue: 0.2),
                                             Color(red: 0.6, green: 0.35, blue: 0.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                    )
                    .frame(width: 180, height: 180)

                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 174, height: 174)
                        .clipShape(Circle())
                } else {
                    Text("upload photo")
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.4).opacity(0.6))
                }
            }
        }
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    // MARK: Field Helpers

    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(red: 0.85, green: 0.6, blue: 0.25))
                .padding(.leading, 4)
            content()
        }
        .padding(.bottom, 16)
    }

    private func fieldRow(text: Binding<String>, placeholder: String) -> some View {
        HStack {
            TextField("", text: text, prompt:
                Text(placeholder)
                    .foregroundColor(Color(red: 0.75, green: 0.55, blue: 0.35).opacity(0.6))
            )
            .font(.system(size: 16))
            .foregroundColor(Color(red: 0.25, green: 0.10, blue: 0.05))
            .tint(Color(red: 0.7, green: 0.4, blue: 0.1))

            Image(systemName: "pencil")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.75, green: 0.55, blue: 0.35).opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.98, green: 0.95, blue: 0.88))
        )
    }

    // MARK: Save

    private func saveMember() {
        if let member = editingMember {
            // Редактирование — обновляем существующий
            member.name = name.trimmingCharacters(in: .whitespaces)
            member.surname = surname.trimmingCharacters(in: .whitespaces)
            member.title = selectedTitle
            member.role = role.trimmingCharacters(in: .whitespaces).isEmpty ? nil : role.trimmingCharacters(in: .whitespaces)
            member.photo = photoData
        } else {
            // Создание нового
            let member = FamilyMember(
                title: selectedTitle,
                name: name.trimmingCharacters(in: .whitespaces),
                surname: surname.trimmingCharacters(in: .whitespaces),
                role: role.trimmingCharacters(in: .whitespaces).isEmpty ? nil : role.trimmingCharacters(in: .whitespaces),
                photo: photoData
            )
            family.members.append(member)
        }
        dismiss()
    }
}

// MARK: - Title Display Name

extension Title {
    var displayName: String {
        switch self {
        case .king:            return "King"
        case .queen:           return "Queen"
        case .knight:          return "Knight"
        case .chester:         return "Chester"
        case .chronicler:      return "Chronicler"
        case .royalWinemaker:  return "Royal Winemaker"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FamilyModel.self, EmblemModel.self, configurations: config)
    let family = FamilyModel(emblem: UUID(), name: "The Ivanov Dynasty", members: [])
    container.mainContext.insert(family)
    return FamilyDetailView(family: family)
        .modelContainer(container)
}
