import XCTest

@testable import AuthenticatorShared

final class ConfigServiceTests: AuthenticatorTestCase { // swiftlint:disable:this type_body_length
    // MARK: Properties

    var appSettingsStore: MockAppSettingsStore!
    var configApiService: ConfigAPIService!
    var errorReporter: MockErrorReporter!
    var now: Date!
    var stateService: MockStateService!
    var subject: DefaultConfigService!
    var timeProvider: MockTimeProvider!

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()

        appSettingsStore = MockAppSettingsStore()
        configApiService = MockConfigAPIService()
        errorReporter = MockErrorReporter()
        now = Date(year: 2024, month: 2, day: 14, hour: 8, minute: 0, second: 0)
        stateService = MockStateService()
        timeProvider = MockTimeProvider(.mockTime(now))
        subject = DefaultConfigService(
            appSettingsStore: appSettingsStore,
            configApiService: configApiService,
            errorReporter: errorReporter,
            stateService: stateService,
            timeProvider: timeProvider
        )
    }

    override func tearDown() {
        super.tearDown()

        appSettingsStore = nil
        configApiService = nil
        errorReporter = nil
        stateService = nil
        subject = nil
        timeProvider = nil
    }

    // MARK: Tests - getConfig remote interactions

    // TODO: BWA-92
    // To backfill these tests, or obviate it by pulling the ConfigService into a shared library.

    // MARK: Tests - getConfig initial values

    /// `getFeatureFlag(:)` returns the initial value for local-only booleans if it is configured.
    func test_getFeatureFlag_initialValue_localBool() async {
        let value = await subject.getFeatureFlag(
            .testLocalInitialBoolFlag,
            defaultValue: false,
            forceRefresh: false
        )
        XCTAssertTrue(value)
    }

    /// `getFeatureFlag(:)` returns the initial value for local-only integers if it is configured.
    func test_getFeatureFlag_initialValue_localInt() async {
        let value = await subject.getFeatureFlag(
            .testLocalInitialIntFlag,
            defaultValue: 10,
            forceRefresh: false
        )
        XCTAssertEqual(value, 42)
    }

    /// `getFeatureFlag(:)` returns the initial value for local-only strings if it is configured.
    func test_getFeatureFlag_initialValue_localString() async {
        let value = await subject.getFeatureFlag(
            .testLocalInitialStringFlag,
            defaultValue: "Default",
            forceRefresh: false
        )
        XCTAssertEqual(value, "Test String")
    }

    /// `getFeatureFlag(:)` returns the initial value for remote-configured booleans if it is configured.
    func test_getFeatureFlag_initialValue_remoteBool() async {
        let value = await subject.getFeatureFlag(
            .testRemoteInitialBoolFlag,
            defaultValue: false,
            forceRefresh: false
        )
        XCTAssertTrue(value)
    }

    /// `getFeatureFlag(:)` returns the initial value for remote-configured integers if it is configured.
    func test_getFeatureFlag_initialValue_remoteInt() async {
        let value = await subject.getFeatureFlag(
            .testRemoteInitialIntFlag,
            defaultValue: 10,
            forceRefresh: false
        )
        XCTAssertEqual(value, 42)
    }

    /// `getFeatureFlag(:)` returns the initial value for remote-configured integers if it is configured.
    func test_getFeatureFlag_initialValue_remoteString() async {
        let value = await subject.getFeatureFlag(
            .testRemoteInitialStringFlag,
            defaultValue: "Default",
            forceRefresh: false
        )
        XCTAssertEqual(value, "Test String")
    }

    // MARK: Tests - getFeatureFlag

    /// `getFeatureFlag(:)` can return a boolean if it's in the configuration
    func test_getFeatureFlag_bool_exists() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: ["test-remote-feature-flag": .bool(true)],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testRemoteFeatureFlag, defaultValue: false, forceRefresh: false)
        XCTAssertTrue(value)
    }

    /// `getFeatureFlag(:)` returns the default value for booleans
    func test_getFeatureFlag_bool_fallback() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: [:],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testRemoteFeatureFlag, defaultValue: true, forceRefresh: false)
        XCTAssertTrue(value)
    }

    /// `getFeatureFlag(:)` returns the default value if the feature is not remotely configurable for booleans
    func test_getFeatureFlag_bool_notRemotelyConfigured() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: ["test-remote-feature-flag": .bool(true)],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testLocalFeatureFlag, defaultValue: false, forceRefresh: false)
        XCTAssertFalse(value)
    }

    /// `getFeatureFlag(:)` can return an integer if it's in the configuration
    func test_getFeatureFlag_int_exists() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: ["test-remote-feature-flag": .int(42)],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testRemoteFeatureFlag, defaultValue: 30, forceRefresh: false)
        XCTAssertEqual(value, 42)
    }

    /// `getFeatureFlag(:)` returns the default value for integers
    func test_getFeatureFlag_int_fallback() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: [:],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testRemoteFeatureFlag, defaultValue: 30, forceRefresh: false)
        XCTAssertEqual(value, 30)
    }

    /// `getFeatureFlag(:)` returns the default value if the feature is not remotely configurable for integers
    func test_getFeatureFlag_int_notRemotelyConfigured() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: ["test-remote-feature-flag": .int(42)],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testLocalFeatureFlag, defaultValue: 30, forceRefresh: false)
        XCTAssertEqual(value, 30)
    }

    /// `getFeatureFlag(:)` can return a string if it's in the configuration
    func test_getFeatureFlag_string_exists() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: ["test-remote-feature-flag": .string("exists")],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testRemoteFeatureFlag, defaultValue: "fallback", forceRefresh: false)
        XCTAssertEqual(value, "exists")
    }

    /// `getFeatureFlag(:)` returns the default value for strings
    func test_getFeatureFlag_string_fallback() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: [:],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testRemoteFeatureFlag, defaultValue: "fallback", forceRefresh: false)
        XCTAssertEqual(value, "fallback")
    }

    /// `getFeatureFlag(:)` returns the default value if the feature is not remotely configurable for strings
    func test_getFeatureFlag_string_notRemotelyConfigured() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: ["test-remote-feature-flag": .string("exists")],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        let value = await subject.getFeatureFlag(.testLocalFeatureFlag, defaultValue: "fallback", forceRefresh: false)
        XCTAssertEqual(value, "fallback")
    }

    /// `getDebugFeatureFlags(:)` returns the default value if the feature is not remotely configurable for strings
    func test_getDebugFeatureFlags() async {
        stateService.serverConfig["1"] = ServerConfig(
            date: Date(year: 2024, month: 2, day: 14, hour: 7, minute: 50, second: 0),
            responseModel: ConfigResponseModel(
                environment: nil,
                featureStates: ["email-verification": .bool(true)],
                gitHash: "75238191",
                server: nil,
                version: "2024.4.0"
            )
        )
        appSettingsStore.overrideDebugFeatureFlag(name: "email-verification", value: false)
        let flags = await subject.getDebugFeatureFlags()
        let emailVerificationFlag = try? XCTUnwrap(flags.first { $0.feature.rawValue == "email-verification" })
        XCTAssertFalse(emailVerificationFlag?.isEnabled ?? true)
    }

    // MARK: Tests - Other

    /// `toggleDebugFeatureFlag` will correctly change the value of the flag given.
    func test_toggleDebugFeatureFlag() async throws {
        let flags = await subject.toggleDebugFeatureFlag(
            name: FeatureFlag.enablePasswordManagerSync.rawValue,
            newValue: true
        )
        XCTAssertTrue(appSettingsStore.overrideDebugFeatureFlagCalled)
        let flag = try XCTUnwrap(flags.first { $0.feature == .enablePasswordManagerSync })
        XCTAssertTrue(flag.isEnabled)
    }

    /// `refreshDebugFeatureFlags` will reset the flags to the original state before overriding.
    func test_refreshDebugFeatureFlags() async throws {
        let flags = await subject.refreshDebugFeatureFlags()
        XCTAssertTrue(appSettingsStore.overrideDebugFeatureFlagCalled)
        let flag = try XCTUnwrap(flags.first { $0.feature == .enablePasswordManagerSync })
        XCTAssertFalse(flag.isEnabled)
    }

    // MARK: Private

    /// Asserts the config publisher is publishing the right values.
    /// - Parameters:
    ///   - isPreAuth: The expected value of `isPreAuth`
    ///   - userId: The expected value of `userId`
    ///   - gitHash: The expected value of `gitHash`
    private func assertConfigPublisherWith(
        isPreAuth: Bool,
        userId: String?,
        gitHash: String?,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        var publisher = try await subject.configPublisher().makeAsyncIterator()
        let result = try await publisher.next()
        let metaConfig = try XCTUnwrap(XCTUnwrap(result))
        XCTAssertEqual(metaConfig.isPreAuth, isPreAuth, file: file, line: line)
        XCTAssertEqual(metaConfig.userId, userId, file: file, line: line)
        XCTAssertEqual(metaConfig.serverConfig?.gitHash, gitHash, file: file, line: line)
    }
} // swiftlint:disable:this file_length
