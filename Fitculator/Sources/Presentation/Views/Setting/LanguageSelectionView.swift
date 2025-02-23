import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var viewModel: SettingViewModel
    let languages = ["한국어", "English"]
    
    var body: some View {
        List {
            ForEach(languages, id: \.self) { language in
                HStack {
                    Text("\(language)")
                    Spacer()
                    if viewModel.selectedLanguage == language {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.tabButtonColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.changeLanguage(to: language)
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("language_setting".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
