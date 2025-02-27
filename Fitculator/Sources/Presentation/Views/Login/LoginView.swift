//
//  LoginView.swift
//  Fitculator
//
//  Created by 임재현 on 2/26/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject var authState: AuthState
    
    init(container: DIContainer) {
            _viewModel = StateObject(wrappedValue: container.makeLoginViewModel())
        }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                GeometryReader { geometry in
                    LoginContentView(viewModel: viewModel, geometry: geometry)
                }
//                .toolbarBackground(.white, for: .navigationBar)
//                .toolbarBackground(.visible, for: .navigationBar)
//                .toolbarColorScheme(.light, for: .navigationBar)
            }
            
        } else {
            NavigationView {
                GeometryReader { geometry in
                    LoginContentView(viewModel: viewModel, geometry: geometry)
                }
                .navigationBarTitleDisplayMode(.inline)
                .background(.white)
//                .onAppear {
//                    let appearance = UINavigationBarAppearance()
//                    appearance.configureWithOpaqueBackground()
//                    appearance.backgroundColor = .white
//                    UINavigationBar.appearance().standardAppearance = appearance
//                    UINavigationBar.appearance().compactAppearance = appearance
//                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
//                }
            }
        }

    }
}

struct LoginContentView: View {
    @ObservedObject var viewModel: LoginViewModel
    let geometry: GeometryProxy
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
            HeaderView()
            LoginFormView(viewModel: viewModel)
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .offset(y: offset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.fitculatorBackgroundColor)
        .edgesIgnoringSafeArea(.bottom)
        .setupKeyboardHandling(geometry: geometry, offset: $offset)
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("Fitculator")
//                    .foregroundStyle(.black)
//            }
//        }

 //       .navigationBarTitleDisplayMode(.inline)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack {
            Text("Fitculator")
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .padding(.top, 40)
                .padding(.horizontal, 8)
            
            
            Image("Logo")
                .resizable()
                .background(Color.fitculatorBackgroundColor)
                .frame(width: 230, height: 230)
        }
    }
}

struct LoginFormView: View {
    @ObservedObject var viewModel: LoginViewModel
   
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Take care of your health by meeting the WHO's recommended exercise guidelines through Fitculator")
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.top, 8)
            
            VStack(spacing: 16) {
                LoginTextField(viewModel: viewModel)
                LoginButton(viewModel: viewModel)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.fitculatorBackgroundColor)
        }
    }
}

struct LoginTextField: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 에러 메시지 표시
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(Color.fitculatorBackgroundColor)
                    .padding(.leading, 20)
            }
            
            TextField("", text: $viewModel.userId)
                .padding(.leading, 20)
                .foregroundStyle(.white)
                .submitLabel(.search)
                .clearButton(text: $viewModel.userId)
                .frame(height: 60)
                .background(Color.fitculatorBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.errorMessage != nil ? Color.red : Color.white, lineWidth: 2)  // 에러 시 빨간 테두리
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    HStack {
                        Text("Enter Your ID")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .opacity(viewModel.userId.isEmpty ? 1 : 0)
                    .allowsHitTesting(false)
                )
                .padding(.horizontal, 20)
                .tint(.white)
                .onChange(of: viewModel.userId) { _ in
                    viewModel.validateInput()  // 입력값이 변경될 때마다 유효성 검사
                }
        }
    }
}

struct LoginButton: View {
    @ObservedObject var viewModel: LoginViewModel
    @EnvironmentObject var authState: AuthState
    
    var body: some View {
        Button {
            print("\(viewModel.userId)")
            Task {
                do {
                    let success = try await viewModel.login()
                    if success {
                        authState.isLoggedIn = true
                        authState.userId = viewModel.userId
                        print("\(authState.userId) 저장완료")
                    }
                } catch {
                    print("Login failed: \(error)")
                }
            }
        } label: {
            Text("Log in")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.isValidInput ? Color.blue : Color.gray)
               
        }
        .disabled(!viewModel.isValidInput)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 20)
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(ClearButton(text: text))
    }
    

    
    func setupKeyboardHandling(geometry: GeometryProxy, offset: Binding<CGFloat>, focusField: Field? = nil) -> some View {
        modifier(KeyboardHandlingModifier(geometry: geometry, offset: offset, focusField: focusField))
        }
}

struct ClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
    }
}



struct KeyboardHandlingModifier: ViewModifier {
    let geometry: GeometryProxy
    @Binding var offset: CGFloat
    var focusField: Field?
    
    func body(content: Content) -> some View {
        content.onAppear {
            setupKeyboardNotifications()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            
            print("키보드 표시됨, 현재 필드: \(String(describing: focusField))")
            
            // 메모 부분일 때는 더 많이 올림
            if focusField == .memo {
                withAnimation(.easeOut(duration: 0.3)) {
                    // 메모 필드는 화면 거의 아래쪽에 있으므로 더 많이 올림
                    offset = -(keyboardFrame.height + 200)
                }
            } else {
                // 다른 필드는 키보드 높이만큼만 올림
                let overlap = keyboardFrame.height * 0.3
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = -overlap
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                offset = 0
            }
        }
    }
}
