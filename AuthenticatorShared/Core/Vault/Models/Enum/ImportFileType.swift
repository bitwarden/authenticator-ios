// MARK: - ImportFileType

/// An enum describing the format of an import file by file type.
/// This includes additional information necessary to perform the import
/// (such as password in the case of importing encrypted files).
///
public enum ImportFileType: Equatable {
    /// A Bitwarden `.json` file type.
    case bitwardenJson

    /// A Raivo `.json` file type.
    case raivoJson

    /// The file extension type to use in the file picker.
    var fileExtension: String {
        switch self {
        case .bitwardenJson,
             .raivoJson:
            "json"
        }
    }
}
