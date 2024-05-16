// MARK: - ImportFileFormat

/// An enum describing the format of an import file.
/// This includes additional information necessary to perform the import
/// (such as password in the case of importing encrypted files).
///
public enum ImportFileFormat: Equatable {
    /// A Bitwarden `.json` file type.
    case bitwardenJson

    /// A Raivo `.json` file type.
    case raivoJson
}