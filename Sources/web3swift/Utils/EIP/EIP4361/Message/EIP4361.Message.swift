//
//  EIP4361.Message.swift
//  Web3swift
//
//  Created by Nikita Tarkhov on 21.03.2025.
//

import Foundation
import BigInt

@preconcurrency
import Web3Core

public extension EIP4361 {
	struct Message: Sendable {
		
		// MARK: - Public properties
		
		public var encoded: String {
			let header = [
				[scheme, domain].compactMap { $0 }.joined(separator: .schemeSepearator) + " wants you to sign in with your Ethereum account:",
				address.address,
				.empty,
				statement,
				.empty
			]
			
			let fullMessage = header.compactMap { $0 } + fields.map(\.encoded)
			
			return fullMessage.joined(separator: .newline)
		}
		
		// MARK: - Private properties
		
		private let scheme: String?
		private let domain: String
		private let address: EthereumAddress
		private let statement: String?
		private let fields: [Field]
		
		// MARK: - Initialization
		
		public init(
			scheme: String? = nil,
			domain: String,
			address: EthereumAddress,
			statement: String? = nil,
			uri: URL,
			version: Version = .v1,
			chainId: BigUInt,
			nonce: String,
			issuedAt: Date,
			expirationTime: Date? = nil,
			notBefore: Date? = nil,
			requestId: String? = nil,
			resources: [URL]? = nil
		) throws(ValidationError) {
			let correctedStatement = statement?.components(separatedBy: .newlines).joined()
			
			guard
				domain.isValid(regex: .EIP4361.domain)
			else {
				throw ValidationError.invalidValue(key: "domain", value: domain)
			}
			
			guard
				address.address.isValid(regex: .EIP4361.address)
			else {
				throw ValidationError.invalidValue(key: "adress", value: address.address)
			}
			
			if let correctedStatement, !correctedStatement.isValid(regex: .EIP4361.statement) {
				throw ValidationError.invalidValue(key: "statement", value: correctedStatement)
			}
			
			if let scheme, !scheme.isValid(regex: .EIP4361.scheme) {
				throw ValidationError.invalidValue(key: "scheme", value: scheme)
			}
			
			self.scheme = scheme
			self.domain = domain
			self.address = address
			self.statement = correctedStatement
			
			var fields: [Field] = [
				.uri(uri),
				.version(version),
				.chainId(chainId),
				.nonce(nonce),
				.issuedAt(issuedAt)
			]
			
			if let expirationTime = expirationTime {
				fields.append(.expirationTime(expirationTime))
			}
			
			if let notBefore = notBefore {
				fields.append(.notBefore(notBefore))
			}
			
			if let requestId = requestId {
				fields.append(.requestId(requestId))
			}
			
			if let resources = resources {
				fields.append(.resources(resources))
			}
			
			guard let firstInvalidField = fields.first(where: { !$0.isValid }) else {
				self.fields = fields
				
				return
			}
			
			throw ValidationError.invalidValue(
				key: firstInvalidField.key,
				value: firstInvalidField.formattedValue
			)
		}
	}
}

private extension EIP4361.Message {
	enum Field: Sendable {
		case uri(URL)
		case version(Version)
		case chainId(BigUInt)
		case nonce(String)
		case issuedAt(Date)
		case expirationTime(Date)
		case notBefore(Date)
		case requestId(String)
		case resources([URL])
		
		// MARK: - Fileprivate properties
		
		var encoded: String {
			[key, valueSeparator, formattedValue].joined()
		}
		
		var isValid: Bool {
			switch self {
			case let .uri(uri):
				uri.absoluteString.isValid(regex: .EIP4361.uri)
				
			case let .nonce(nonce):
				nonce.isValid(regex: .EIP4361.nonce)
				
			case let .requestId(requestId):
				requestId.isValid(regex: .EIP4361.requestId)
				
			case let .resources(resources):
				resources.allSatisfy { $0.absoluteString.isValid(regex: .EIP4361.uri) }
				
			default:
				true
			}
		}
		
		var key: String {
			switch self {
			case .uri:
				"URI"
				
			case .version:
				"Version"
				
			case .chainId:
				"Chain ID"
				
			case .nonce:
				"Nonce"
				
			case .issuedAt:
				"Issued At"
				
			case .expirationTime:
				"Expiration Time"
				
			case .notBefore:
				"Not Before"
				
			case .requestId:
				"Request ID"
				
			case .resources:
				"Resources"
			}
		}
		
		var formattedValue: String {
			switch self {
			case let .uri(uri):
				uri.absoluteString
				
			case let .version(version):
				version.rawValue.description
				
			case let .chainId(chainId):
				String(chainId, radix: 10)
				
			case let .nonce(nonce):
				nonce
				
			case let .issuedAt(date),
				 let .expirationTime(date),
				 let .notBefore(date):
				ISO8601DateFormatter().string(from: date)
			
			case let .requestId(requestId):
				requestId
				
			case let .resources(resources):
				resources
					.map {
						"- \($0.absoluteString)"
					}
					.joined(separator: .newline)
			}
		}
		
		// MARK: - Private properties
		
		private var valueSeparator: String {
			guard case .resources = self else {
				return .colon + .whitespace
			}
			
			return .colon + .newline
		}
	}
}

// MARK: - Constants

private extension String {
	
	// MARK: - Fileprivate static properties
	
	static let empty = ""
	static let colon = ":"
	static let newline = "\n"
	static let whitespace = " "
	static let schemeSepearator = "://"
}
