import UIKit

// MARK: Alert+Vault

extension Alert {
    /// An alert presenting the user with more options for a vault list item.
    ///
    /// - Parameters:
    ///   - cipherView: The cipher view to show.
    ///   - hasPremium: Whether the user has a premium account.
    ///   - id: The id of the item.
    ///   - showEdit: Whether to show the edit option (should be `false` for items in the trash).
    ///   - action: The action to perform after selecting an option.
    ///
    /// - Returns: An alert presenting the user with options to select an attachment type.
    @MainActor
    static func moreOptions( // swiftlint:disable:this function_body_length
        authenticatorItemView: AuthenticatorItemView,
        id: String,
        action: @escaping (_ action: MoreOptionsAction) async -> Void
    ) -> Alert {
        // All the cipher types have the option to view the cipher.
        var alertActions = [
            AlertAction(title: Localizations.view, style: .default) { _, _ in await action(.view(id: id)) },
        ]

        // Add the option to edit the cipher if desired.
        alertActions.append(AlertAction(title: Localizations.edit, style: .default) { _, _ in
            await action(.edit(authenticatorItemView: authenticatorItemView))
        })

        // Return the alert.
        return Alert(
            title: authenticatorItemView.name,
            message: nil,
            preferredStyle: .actionSheet,
            alertActions: alertActions + [AlertAction(title: Localizations.cancel, style: .cancel)]
        )
    }
}
