import SwiftUI

struct CustomNavigationBar: View {
    let isDisplayHome: Bool // true는 Home false는 지난주 데이터.
    let homeBtnAction: () -> Void
    let calendarBtnAction: (_ selectedDate: Date) -> Void
    let notificationBtnAction: () -> Void
    @State private var date = Date()
    @State var test: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(
        isDisplayHome: Bool,
        homeBtnAction: @escaping () -> Void,
        calendarBtnAction: @escaping (_ selectedDate: Date) -> Void,
        notificationBtnAction: @escaping () -> Void
    ) {
        self.isDisplayHome = isDisplayHome
        self.homeBtnAction = homeBtnAction
        self.calendarBtnAction = calendarBtnAction
        self.notificationBtnAction = notificationBtnAction
    }
    
    var body: some View {
        HStack {
            Image("LogoImage")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 160, maxHeight: 36)
                .padding(.leading, 0)
          
            Spacer()
          
            if isDisplayHome {
                Image(systemName: "calendar")
                    .font(.title3)
                    .overlay{
                        
                        DatePicker(
                            "",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .blendMode(
                            .destinationOver
                        )
                        .onChange(of: date) {
                            calendarBtnAction(date)
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.trailing, 10)
                Button {
                    notificationBtnAction()
                } label: {
                    Image(systemName: "bell.fill")
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                }
                .padding(.trailing, 20)
            } else {
                Button {
                    homeBtnAction()
                } label: {
                    Image(systemName: "house.fill")
                }
                .padding(.trailing, 20)
            }
            
        }
        .background(Color.fitculatorBackgroundColor)
        .frame(height: 44)
    }
}

//struct CustomNavigationBar_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomNavigationBar(isDisplayHome: true, homeBtnAction: {}, calendarBtnAction: {selectedDate in }, notificationBtnAction: {})
//    }
//}
