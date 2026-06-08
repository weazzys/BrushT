import SwiftUI

struct NotesJournalView: View {
    @StateObject private var viewModel: NotesJournalViewModel
    @ObservedObject private var brushStore: BrushRecordStore
    @Environment(\.dismiss) private var dismiss
    @State private var isAddNotePresented = false

    init(brushStore: BrushRecordStore) {
        self.brushStore = brushStore
        _viewModel = StateObject(wrappedValue: NotesJournalViewModel(brushStore: brushStore))
    }

    var body: some View {
        ZStack {
            AppBackground()

            if viewModel.isEmpty {
                AppFormCard {
                    VStack(spacing: 12) {
                        Image(systemName: "note.text")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(AppTheme.blue)
                        Text("Заметок пока нет")
                            .font(.headline)
                            .foregroundStyle(AppTheme.text)
                        Text("Нажмите плюс, чтобы добавить первую заметку.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
                .padding(20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.noteRecords) { record in
                            NoteCardView(record: record) {
                                viewModel.deleteNote(from: record)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Заметки")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Готово") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddNotePresented = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Добавить заметку")
            }
        }
        .sheet(isPresented: $isAddNotePresented) {
            NavigationStack {
                AddNoteView(viewModel: viewModel) {
                    isAddNotePresented = false
                }
            }
        }
        .onReceive(brushStore.$records) { _ in
            viewModel.refresh()
        }
        .appToolbarStyle()
    }
}

private struct AddNoteView: View {
    @ObservedObject var viewModel: NotesJournalViewModel
    let onClose: () -> Void

    var body: some View {
        ZStack {
            AppSheetBackground()

            VStack(spacing: 20) {
                AppFormCard(title: "Новая заметка") {
                    AppNotesEditor(
                        placeholder: "Например: чувствительность, совет врача, новая паста...",
                        text: $viewModel.newNoteText,
                        minHeight: 150
                    )
                }

                Button {
                    viewModel.addNote()
                    onClose()
                } label: {
                    Label("Сохранить", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AppPrimaryButtonStyle())
                .disabled(!viewModel.canSaveNote)
                .opacity(viewModel.canSaveNote ? 1 : 0.55)

                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Добавить заметку")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Отмена") {
                    viewModel.newNoteText = ""
                    onClose()
                }
            }
        }
        .appToolbarStyle()
    }
}
