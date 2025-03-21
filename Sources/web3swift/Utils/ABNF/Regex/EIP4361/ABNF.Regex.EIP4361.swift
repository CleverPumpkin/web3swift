//
//  ABNF.Regex.EIP4361.swift
//  Web3swift
//
//  Created by Nikita Tarkhov on 21.03.2025.
//

extension ABNF.Regex {
	enum EIP4361 {
		
		// MARK: - Internal static properties
		
		static let issuedAt = dateTime
		static let expirationTime = dateTime
		static let notBefore = dateTime
		static let domain = authority
		
		static let scheme = ABNF.Regex(
			"[a-zA-Z][a-zA-Z0-9+\\-.]*"
		)

		static let resource = ABNF.Regex(
			"- \(uri)"
		)
		
		static let address = ABNF.Regex(
			"0x[0-9A-Fa-f]{40}"
		)

		static let statement = ABNF.Regex(
			"(\(reserved)|\(unreserved)| )+"
		)

		static let uri = ABNF.Regex(
			"\(scheme):\(hierPart)(\\?\(query))?(\\#\(fragment))?"
		)

		static let version = ABNF.Regex(
			"[0-9]+"
		)

		static let chainId = ABNF.Regex(
			"[0-9]+"
		)

		static let nonce = ABNF.Regex(
			"[a-zA-Z0-9]{8,}"
		)

		static let requestId = ABNF.Regex(
			"(\(pchar))*"
		)

		static let resources = ABNF.Regex(
			"(\\n\(resource))*"
		)
	}
}
