import SwiftUI

struct EditInfoView: View {
    @StateObject var viewModel = EditInfoViewModel()
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width / 2
            NavigationStack {
                VStack {
                    VStack {
                        Image(systemName: "sun.max")
                            .resizable()
                            .frame(width: width, height: width)
                            .padding()
                            .aspectRatio(contentMode: .fit)
                            .background(Color.brightBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: width))
                            .foregroundStyle(.white)
                    }
                    
                    List(viewModel.infoList, id: \.self) { info in
                        Text(info)
                            .listRowBackground(Color.fitculatorBackgroundColor.opacity(0.8))
                    }
                }
                .background(Color.fitculatorBackgroundColor)
                .navigationTitle("내 정보")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            print("수정버튼 눌림")
                        } label: {
                            Text("수정")
                                .font(.headline)
                        }
                        .tint(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    EditInfoView()
}
