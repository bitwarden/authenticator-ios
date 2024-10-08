import Foundation

@testable import AuthenticatorShared

class MockConfigAPIService: ConfigAPIService {
    var configResult: Result<ConfigResponseModel, Error> = .failure(AuthenticatorTestError.example)
    func getConfig() async throws -> ConfigResponseModel {
        return try configResult.get()
    }
}
