import SwiftUI

struct CustomNavigationBar: View {
    let isDisplayHome: Bool // true는 Home false는 지난주 데이터.
    let homeBtnAction: () -> Void
    let calendarBtnAction: () -> Void
    let notificationBtnAction: () -> Void
    
    init(
        isDisplayHome: Bool,
        homeBtnAction: @escaping () -> Void,
        calendarBtnAction: @escaping () -> Void,
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
                Button {
                    calendarBtnAction()
                } label: {
                    Image(systemName: "calendar")
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                }
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

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavigationBar(isDisplayHome: true, homeBtnAction: {}, calendarBtnAction: {}, notificationBtnAction: {})
    }
}
