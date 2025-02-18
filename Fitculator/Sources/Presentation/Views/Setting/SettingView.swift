import SwiftUI

struct SettingView: View {
    @State private var selectedGoal: String = ""
    @AppStorage("selectedLang") private var selectedLang: String = Locale.current.language.languageCode?.identifier == "ko" ? "한국어" : "영어" // 언어 설정 필요
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: WorkoutGoalView(selectedGoal: $selectedGoal)) {
                        HStack {
                            Text("운동 목표")
                            Spacer()
                            Text(selectedGoal)
                                .foregroundStyle(.gray)
                        }
                    }
                    NavigationLink("디바이스", destination: DeviceView())
                    NavigationLink(destination: LanguageSelectionView(selectedLang: $selectedLang)) {
                        HStack {
                            Text("언어 설정")
                            Spacer()
                            Text(selectedLang)
                                .foregroundStyle(.gray)
                        }
                    }
                    NavigationLink("계정 정보", destination: AccountInfoView())
                }
                .listRowBackground(Color.gray.opacity(0.2))
                
                Section {
                    NavigationLink("공지사항", destination: NoticeView())
                    Link(destination: URL(string: "https://airtable.com/apprBZkCTk4gpMmSW/pagWPcKsiuiwaS8zs/form")!) {
                        HStack {
                            Text("문의하기")
                        }.foregroundColor(.white)
                    }
                    Link(destination: URL(string: "https://www.fitculator.io/privacy-policy")!) {
                        HStack {
                            Text("개인정보 처리방침")
                        }.foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
                
                Section {
                    VStack(alignment: .leading, spacing: 8, content: {
                        Text("Plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("2025.02.13 - 2025.03.13")
                        Text("다음 결제 예정일: 2025.03.14")
                            .foregroundStyle(Color.gray)
                    })
                    NavigationLink("구독 서비스 종류", destination: PayInfoView())
                } header: {
                    Text("구독 정보")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .font(.title2)
                        .foregroundStyle(Color.white)
                }
                .listRowBackground(Color.gray.opacity(0.2))
            }
            .scrollContentBackground(.hidden)
            .background(Color.fitculatorBackgroundColor.opacity(1))
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct WorkoutGoalView: View {
    @Binding var selectedGoal: String
    let goals = ["다이어트", "근육 증량", "체중 유지", "기타목표"]
    
    var body: some View {
        List {
            ForEach(goals, id: \.self) { goal in
                HStack {
                    Text(goal)
                    Spacer()
                    if selectedGoal == goal {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.tabButtonColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedGoal = goal
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("운동 목표")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageSelectionView: View {
    @Binding var selectedLang: String
    let languages = ["한국어", "영어"]
    
    var body: some View {
        List {
            ForEach(languages, id: \.self) { language in
                HStack {
                    Text("\(language)")
                    Spacer()
                    if selectedLang == language {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.tabButtonColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLang = language
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("언어 설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccountInfoView: View {
    var body: some View {
        Spacer()
        Text("이메일: test@test.com")
        Spacer()
        HStack(spacing: 15) {
            Button("로그아웃") {
                userLogout()
            }
            .foregroundStyle(.red)
            Button("회원탈퇴") {
                userWithdraw()
            }
            .foregroundStyle(.gray)
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("계정 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func userLogout() {
        //viewModel.userLogout()
    }
    
    private func userWithdraw() {
        // viewModel.userWithdraw()
    }
}

struct NoticeView: View {
    var body: some View {
        Text("공지사항입니다~")
            .navigationTitle("공지사항")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// 구독 플랜 모델
struct SubscriptionPlan: Identifiable {
    let id = UUID()
    let title: String
    let features: [String]
}

let subscriptionPlans: [SubscriptionPlan] = [
    SubscriptionPlan(
        title: "Basic",
        features: [
            "운동량 계산 및 분석",
            "피로도 관리",
            "피트니스 특화 챗봇 (질문 답변, 프로그램 피드백 등)",
            "커뮤니티 활동"
        ]
    ),
    SubscriptionPlan(
        title: "Plus",
        features: [
            "Basic 플랜 기능 포함",
            "코치님의 위클리 피드백 & 모니터링"
        ]
    ),
    SubscriptionPlan(
        title: "Pro",
        features: [
            "Plus 플랜 기능 포함",
            "전담 코치 배정",
            "개별 운동 프로그램 제공 (근력, Hyrox)",
            "프로그램 피드백"
        ]
    )
]

struct PayInfoView: View {
    var body: some View {
        List {
            ForEach(subscriptionPlans) { plan in
                SubscriptionView(plan: plan)
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor)
        .navigationTitle("구독 서비스 종류")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SubscriptionView: View {
    var plan: SubscriptionPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom, 4)
            
            ForEach(plan.features, id: \.self) { feature in
                Text("• \(feature)")
                    .foregroundColor(.white)
            }
        }
        .padding(5)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
