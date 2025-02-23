import SwiftUI

struct SettingView: View {
    @StateObject private var viewModel = SettingViewModel()
    @State private var selectedGoal: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: WorkoutGoalView(selectedGoal: $selectedGoal)) {
                        HStack {
                            Text("fitness_goal".localized)
                            Spacer()
                            Text(selectedGoal)
                                .foregroundStyle(.gray)
                        }
                    }
                    NavigationLink("device".localized, destination: DeviceView())
                    NavigationLink(destination: LanguageSelectionView(viewModel: viewModel)) {
                        HStack {
                            Text("language_setting".localized)
                            Spacer()
                            Text(viewModel.selectedLanguage)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .listRowBackground(Color.brightBackgroundColor)
                
                Section {
                    NavigationLink("notice".localized, destination: NoticeView())
                    Link(destination: URL(string: "https://airtable.com/apprBZkCTk4gpMmSW/pagWPcKsiuiwaS8zs/form")!) {
                        HStack {
                            Text("contact_us".localized)
                        }
                        .foregroundColor(.white)
                    }
                    Link(destination: URL(string: "https://www.fitculator.io/privacy-policy")!) {
                        HStack {
                            Text("privacy_policy".localized)
                        }
                        .foregroundColor(.white)
                    }
                }
                .listRowBackground(Color.brightBackgroundColor)
                
                // TODO: 유저의 구독 정보 연결 필요
                Section {
                    VStack(alignment: .leading, spacing: 8, content: {
                        Text("\(viewModel.user.subscriptionPlan.title)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("2025.02.13 - 2025.03.13")
                        HStack {
                            Text("next_billing_date".localized)
                            Text("2025.03.14")
                        }
                        .foregroundStyle(Color.gray)
                    })
                    NavigationLink("subscription_type".localized, destination: PayInfoView())
                } header: {
                    Text("subscription_info".localized)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .font(.title2)
                        .foregroundStyle(Color.white)
                }
                .listRowBackground(Color.brightBackgroundColor)
            }
            .scrollContentBackground(.hidden)
            .background(Color.fitculatorBackgroundColor.opacity(1))
        }
        .navigationTitle("settings".localized)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

struct NoticeView: View {
    var body: some View {
        Text("공지사항입니다~")
            .navigationTitle("notice".localized)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: 구독 서비스
struct SubscriptionPlan: Identifiable {
    let id = UUID()
    let title: String
    let features: [String]
}

let subscriptionPlans: [SubscriptionPlan] = [
    SubscriptionPlan(
        title: "Basic",
        features: [
            "workout_analysis".localized,
            "fatigue_management".localized,
            "fitness_chatbot".localized,
            "communityAct".localized
        ]
    ),
    SubscriptionPlan(
        title: "Plus",
        features: [
            "basic_plan".localized,
            "weekly_coach_feedback".localized
        ]
    ),
    SubscriptionPlan(
        title: "Pro",
        features: [
            "plus_plan".localized,
            "personal_coach".localized,
            "custom_workout_program".localized,
            "program_feedback".localized
        ]
    )
]

// MARK: 구독 서비스 종류 소개
struct PayInfoView: View {
    var body: some View {
        List {
            ForEach(subscriptionPlans) { plan in
                SubscriptionView(plan: plan)
            }
            .listRowBackground(Color.brightBackgroundColor)
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor)
        .navigationTitle("subscription_type".localized)
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
