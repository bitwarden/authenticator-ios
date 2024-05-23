import Foundation

class GoogleImporter {
    static func importItems(data: Data) throws -> [AuthenticatorItemView] {
        guard let string = String(data: data, encoding: .utf8),
              let urlComponents = URLComponents(string: string),
              urlComponents.scheme == "otpauth-migration",
              urlComponents.host == "offline",
              let queryItems = urlComponents.queryItems,
              let encoded = queryItems.first(where: { $0.name == "data" })?.value,
              let encodedData = encoded.data(using: .utf8),
              let decodedData = Data(base64Encoded: encodedData)
        else {
            return []
        }

        let payload = try GoogleMigrationPayload(serializedData: decodedData)

        return payload.otpParameters.compactMap { item in
            guard item.type == .otpTotp else { return nil }
            let secret = item.secret.base32String()
            let otp = OTPAuthModel(
                accountName: nil,
                algorithm: .sha1,
                digits: (5 ... 10).contains(Int(item.digits)) ? Int(item.digits) : 6,
                issuer: item.issuer.nilIfEmpty,
                period: 30,
                secret: secret
            )
            return AuthenticatorItemView(
                favorite: false,
                id: UUID().uuidString,
                name: item.name,
                totpKey: otp.otpAuthUri,
                username: nil
            )
        }
    }
}
