import SwiftUI

struct AddView: View {
    @State var text: String
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var offset: CGFloat = 0
    @FocusState private var focusedField: Field?
    @State private var selectedExerciseType: String? = nil
    @State private var showDropdown: Bool = false
    
    enum Field {
            case exerciseTime
            case minHeartRate
            case maxHeartRate
            case memo
        }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            
            VStack {
            dateSection
            
            exerciseTypeSection
                    .zIndex(1)
            
            exerciseTimeSection
                .focused($focusedField, equals: .exerciseTime)
                .zIndex(0)
            
            heartRateSection
                    .zIndex(0)
            
            memoSection
            
            buttonSection
        }
        .background(Color.fitculatorBackgroundColor)
        .offset(y: -offset)
        .onTapGesture {
            focusedField = nil
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation {
                offset = 0
            }
        }
        .onAppear {
            setupKeyboardNotifications()
        }
        .onDisappear {
            removeKeyboardNotifications()
        }
    }

    }
    
    private var dateSection: some View {
        VStack {
            HStack {
                Text("날짜 및 시간")
                    .font(.system(size:16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            HStack {
                Text(selectedDate,style: .date)
                    .padding(.leading)
                    .foregroundStyle(.white)
                
                Spacer()
                
                ZStack {
                   DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(width: 35, height: 35)
                        .clipped()
                        .tint(Color.fitculatorBackgroundColor)
                        .background(Color.fitculatorBackgroundColor)
                        
                            
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                        .frame(width: 35, height: 35)
                        .background(Color.fitculatorBackgroundColor)
                        .allowsHitTesting(false)
                }
                
                .padding(.trailing, 10)
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.gray,lineWidth: 2)
            )
        }
        .background(Color.fitculatorBackgroundColor)
        .padding(.horizontal,20)

    }
    
    private var exerciseTypeSection: some View {
        ZStack(alignment: .top) {  // ZStack을 사용하여 겹치게 배치
            VStack(spacing:0) {
                HStack {
                    Text("운동종류")
                        .font(.system(size:16))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                
                HStack {
                    Button {
                        selectedExerciseType = "유산소"
                        showDropdown.toggle()
                    } label: {
                        Text("유산소")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.gray, lineWidth: 2)
                            )
                    }
                    
                    Button {
                        selectedExerciseType = "근력"
                        showDropdown.toggle()
                    } label: {
                        Text("근력")
                            .frame(maxWidth:.infinity)
                            .frame(height:50)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.gray, lineWidth: 2)
                            )
                    }
                }
            }
            .background(Color.fitculatorBackgroundColor)
            .padding(.horizontal,20)
            .padding(.top, 8)
            .zIndex(0)  // 버튼들이 드롭다운 메뉴 위에 보이도록

            // 드롭다운 메뉴
            if showDropdown {
                DropTow()
                    .offset(y: 90)  // 버튼 아래에 위치하도록 조정
                    .zIndex(2)  // 드롭다운이 버튼 아래에 위치하도록
            }
        }
    }
    
//    private var exerciseTypeSection: some View {
//        VStack {
//            HStack {
//                Text("운동종류")
//                    .font(.system(size:16))
//                    .foregroundStyle(.white)
//                
//                Spacer()
//            }
//            
//            HStack {
//                Button {
//                    print("유산소")
//                    selectedExerciseType = "유산소"
//                    showDropdown.toggle()
//                } label: {
//                    Text("유산소")
//                           .frame(maxWidth: .infinity)
//                           .frame(height: 50)
//                           .foregroundStyle(.white)
//                           .overlay(
//                               RoundedRectangle(cornerRadius: 4)
//                                   .stroke(.gray, lineWidth: 2)
//                           )
//                }
//                
//                Button {
//                    print("근력")
//                } label: {
//                   Text("근력")
//                        .frame(maxWidth:.infinity)
//                        .frame(height:50)
//                        .foregroundStyle(.white)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 4)
//                                .stroke(.gray, lineWidth: 2)
//                        )
//                }
//            }
//            
//            if showDropdown {
//                DropTow()
//                    .transition(.move(edge: .top).combined(with: .opacity))
//            }
//        }
//        .background(Color.fitculatorBackgroundColor)
//        .padding(.horizontal,20)
//        .padding(.top, 8)
//
//    }
    
    private var exerciseTimeSection: some View {
            VStack {
                HStack {
                    Text("운동시간 (분)")
                        .font(.system(size:16))
                        .foregroundStyle(.white)
                    Spacer()
                }
                
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text("운동시간")
                            .foregroundStyle(Color.gray)
                    }
                    .keyboardType(.numberPad)
                    .foregroundColor(.white)
                    .padding(.leading, 10)
                    .frame(height: 50)
                    .background(Color.fitculatorBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.gray, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    
    private var heartRateSection: some View {
         VStack {
             HStack {
                 Text("심박수")
                     .font(.system(size: 16))
                     .foregroundStyle(.white)
                 Spacer()
             }
             
             HStack(spacing: 20) {
                 
                 HStack {
                     TextField("", text: $text)
                         .keyboardType(.numberPad)
                         .focused($focusedField, equals: .minHeartRate)
                         .placeholder(when: text.isEmpty) {
                             Text("최저 심박수")
                                 .foregroundStyle(Color.gray)
                         }
                         .foregroundStyle(.white)
                         .padding(.leading, 10)
                     
                     if !text.isEmpty {
                         Text("bpm")
                             .foregroundStyle(.gray)
                             .padding(.trailing, 10)
                        }
                     
                 }
                     .frame(height: 50)
                     .background(Color.fitculatorBackgroundColor)
                     .overlay(
                         RoundedRectangle(cornerRadius: 4)
                             .stroke(.gray, lineWidth: 2)
                     )
                 
                 HStack {
                     TextField("", text: $text)
                         .keyboardType(.numberPad)
                         .focused($focusedField, equals: .maxHeartRate)
                         .placeholder(when: text.isEmpty) {
                             Text("최대 심박수")
                                 .foregroundStyle(Color.gray)
                         }
                         .foregroundStyle(.white)
                         .padding(.leading, 10)
                     
                     if !text.isEmpty {
                         Text("bpm")
                             .foregroundStyle(.gray)
                             .padding(.trailing, 10)
                        }
                     
                 }
                 

                     .frame(height: 50)
                     .background(Color.fitculatorBackgroundColor)
                     .overlay(
                         RoundedRectangle(cornerRadius: 4)
                             .stroke(.gray, lineWidth: 2)
                     )
             }
         }
         .padding(.horizontal, 20)
     }
    
    private var memoSection: some View {
         VStack {
             HStack {
                 Text("메모")
                     .font(.system(size: 16))
                     .foregroundStyle(.white)
                 Spacer()
             }
             
             CustomTextView(text: $text)
                 .focused($focusedField, equals: .memo)
                 .frame(height: 200)
                 .padding()
                 .background(Color.gray.opacity(0.2))
                 .cornerRadius(8)
         }
         .padding(.horizontal, 20)
     }
     
     private var buttonSection: some View {
         HStack {
             Button {
                 print("메모")
             } label: {
                 Text("메모")
                     .font(.system(size: 16, weight: .semibold))
                     .foregroundColor(.white)
                     .frame(maxWidth: .infinity)
                     .frame(height: 50)
                     .background(Color.gray)
                     .clipShape(.capsule)
             }
         }
         .padding(.horizontal, 20)
     }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            
            let keyboardHeight = keyboardFrame.height

            if focusedField == .memo {
                withAnimation(.easeOut(duration: duration)) {
                    self.offset = keyboardHeight - 170
                }
            } else {
                withAnimation(.easeOut(duration: duration)) {
                    self.offset = 0
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation {
                offset = 0
            }
        }
    }
    
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func hideKeyboard() {
        focusedField = nil
        
        withAnimation {
            offset = 0
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),to: nil,from: nil,for: nil)
        
    }
    
    
    
}

struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    @FocusState var isFocused: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .white
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        
        init(_ textView: CustomTextView) {
            self.parent = textView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }
                
        func textViewDidEndEditing(_ textView: UITextView) {
            parent.isFocused = false
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }}


#Preview {
    AddView(text: "hi")
}

struct DropMenu: Identifiable {
    var id = UUID()
    var title: String
}

let drop = [
    DropMenu(title: "Item1"),
    DropMenu(title: "Item2"),
    DropMenu(title: "Item3"),
    DropMenu(title: "Item4"),
    DropMenu(title: "Item5"),
    DropMenu(title: "Item6")
    
]


struct DropdownView: View {
    @State var show: Bool = false
    @State var name: String = "Item1"
    
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                    ScrollView {
                        VStack(spacing:17){
                            ForEach(drop) { item in
                                Button {
                                    withAnimation {
                                        name = item.title
                                        show.toggle()
                                    }
                                } label: {
                                    Text(item.title).foregroundStyle(.white.opacity(0.6))
                                        .bold()
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.vertical,15)
                        
                    }
                }
                .frame(height: show ? 200 : 50)
                .offset(y: show ? 0 : -135)
                .foregroundStyle(.gray)
                ZStack {
                    RoundedRectangle(cornerRadius: 10).frame(height: 60)
                        .foregroundStyle(.gray)
                    HStack {
                        Text(name).font(.title2)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                    .bold()
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                }
                .offset(y: -133)
                .onTapGesture {
                    withAnimation {
                        show.toggle()
                    }
                }
            }
        }
        .padding()
        .frame(height: 200)
        .offset(y:40)
    }
}

struct DropTow: View {
    @State var show: Bool = false
    @State var name: String = "Item1"
    
    var body: some View {
        VStack {
                ZStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                        ScrollView {
                            VStack(spacing:17){
                                ForEach(drop.indices,id:\.self) { item in
                                    if item != 0 {
                                        Rectangle().frame(height: 1)
                                            .foregroundStyle(.gray)
                                    }
                                    Button {
                                        withAnimation {
                                            name = drop[item].title
                                            show.toggle()
                                        }
                                    } label: {
                                        Text(drop[item].title).foregroundStyle(.black).font(.title2)
                                            .bold()
                                          
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.vertical,15)
                            
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundStyle(.gray)
                            .padding(1)

                    }
                    
                                    
                    .frame(height: show ? 200 : 50)
                    .offset(y: show ? 0 : -135)
                    .foregroundStyle(.white)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).frame(height: 60)
                            .foregroundStyle(.white)
                        HStack {
                            Text(name).font(.title2)
                            Spacer()
                            
                            Image(systemName: "triangle.fill")
                                .rotationEffect(.degrees(show ? 0 : 90 ))
                        }
                        .bold()
                        .padding(.horizontal)
                        .foregroundStyle(.black)
                        
                        RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 1).frame(height: 60)
                            .padding(1)
                    }
                    .offset(y: -133)
                    .onTapGesture {
                        withAnimation {
                            show.toggle()
                        }
                    }
                }
            .background(.yellow)
        }
        .background(.red)
        .padding()
        .frame(height: 280)
        .offset(y:40)
    }
}


