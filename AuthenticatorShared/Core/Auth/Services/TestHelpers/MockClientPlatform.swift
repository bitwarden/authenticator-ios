import BitwardenSdk

@testable import AuthenticatorShared

class MockClientPlatform: ClientPlatformProtocol {
    var fingerprintMaterialString: String?
    var fingerprintResult: Result<String, Error> = .success("a-fingerprint-phrase-string-placeholder")
    var featureFlags: [String: Bool] = ["": false]
    var userFingerprintCalled = false

    func fingerprint(req: BitwardenSdk.FingerprintRequest) async throws -> String {
        try fingerprintResult.get()
    }

    func loadFlags(flags: [String: Bool]) async throws {
        featureFlags = flags
    }

    func userFingerprint(fingerprintMaterial: String) async throws -> String {
        fingerprintMaterialString = fingerprintMaterial
        userFingerprintCalled = true
        return try fingerprintResult.get()
    }
}
