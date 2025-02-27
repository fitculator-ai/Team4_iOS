class SettingsService {
    private let networkService = NetworkService(session: .shared)
    
    var settingRepository: SettingRepository
    var settingDataSource: SettingDataSource
    var userDetailUseCase: UserDetailUseCase
    var userAccountUseCase: UserAccountUseCase
    var editUserDetailUseCase: EditUserDetailUseCase
    var uploadProfileImageUseCase: UploadProfileImageUseCase
    
    init() {
        self.settingDataSource = SettingDataSource(networkService: networkService)
        self.settingRepository = SettingRepository(dataSource: settingDataSource)
        
        self.userDetailUseCase = UserDetailUseCase(repository: settingRepository)
        self.userAccountUseCase = UserAccountUseCase(repository: settingRepository)
        self.editUserDetailUseCase = EditUserDetailUseCase(repository: settingRepository)
        self.uploadProfileImageUseCase = UploadProfileImageUseCase(repository: settingRepository)
    }
    
    func createViewModel() -> SettingViewModel {
        return SettingViewModel(userDetailUseCase: userDetailUseCase,
                                userAccountUseCase: userAccountUseCase,
                                editUserDetailUseCase: editUserDetailUseCase,
                                uploadProfileImage: uploadProfileImageUseCase)
    }
}
