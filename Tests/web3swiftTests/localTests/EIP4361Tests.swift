//
//  EIP4361Tests.swift
//  Web3swift
//
//  Created by Nikita Tarkhov on 21.03.2025.
//

import XCTest
import BigInt

@testable
import Web3Core

@testable
import web3swift

final class EIP4361Tests: XCTestCase {
	
	// MARK: - Private properties
	
	private let cases = [
"""
example.com wants you to sign in with your Ethereum account:
0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

I accept the ExampleOrg Terms of Service: https://example.com/tos

URI: https://example.com/login
Version: 1
Chain ID: 1
Nonce: 32891756
Issued At: 2021-09-30T16:25:24Z
Resources:
- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/
- https://example.com/my-web2-claim.json
""",
"""
example.com:3388 wants you to sign in with your Ethereum account:
0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

I accept the ExampleOrg Terms of Service: https://example.com/tos

URI: https://example.com/login
Version: 1
Chain ID: 1
Nonce: 32891756
Issued At: 2021-09-30T16:25:24Z
Resources:
- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/
- https://example.com/my-web2-claim.json
""",
"""
https://example.com wants you to sign in with your Ethereum account:
0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2


URI: https://example.com/login
Version: 1
Chain ID: 1
Nonce: 32891756
Issued At: 2021-09-30T16:25:24Z
Resources:
- ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/
- https://example.com/my-web2-claim.json
"""
	]
	
	// MARK: - Internal methods
	
	func testMessageGenerator() throws {
		let messages: [EIP4361.Message] = [
			try .init(
				domain: "example.com",
				address: .init("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")!,
				statement: "I accept the ExampleOrg Terms of Service: https://example.com/tos",
				uri: URL(string: "https://example.com/login")!,
				version: .v1,
				chainId: 1,
				nonce: "32891756",
				issuedAt: ISO8601DateFormatter().date(from: "2021-09-30T16:25:24Z")!,
				resources: [
					URL(string: "ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/")!,
					URL(string: "https://example.com/my-web2-claim.json")!,
				]
			),
			try .init(
				domain: "example.com:3388",
				address: .init("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")!,
				statement: "I accept the ExampleOrg Terms of Service: https://example.com/tos",
				uri: URL(string: "https://example.com/login")!,
				version: .v1,
				chainId: 1,
				nonce: "32891756",
				issuedAt: ISO8601DateFormatter().date(from: "2021-09-30T16:25:24Z")!,
				resources: [
					URL(string: "ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/")!,
					URL(string: "https://example.com/my-web2-claim.json")!,
				]
			),
			try .init(
				scheme: "https",
				domain: "example.com",
				address: .init("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")!,
				uri: URL(string: "https://example.com/login")!,
				version: .v1,
				chainId: 1,
				nonce: "32891756",
				issuedAt: ISO8601DateFormatter().date(from: "2021-09-30T16:25:24Z")!,
				resources: [
					URL(string: "ipfs://bafybeiemxf5abjwjbikoz4mc3a3dla6ual3jsgpdr4cjr3oz3evfyavhwq/")!,
					URL(string: "https://example.com/my-web2-claim.json")!,
				]
			)
		]
		
		for (index, message) in messages.enumerated() {
			let encoded = message.encoded
			
			XCTAssertEqual(encoded, self.cases[index])
		}
		
		XCTAssertThrowsError(
			try EIP4361.Message(
				domain: "https://test.com",
				address: .init("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")!,
				uri: URL(string: "https://example.com/login")!,
				version: .v1,
				chainId: 1,
				nonce: "32891756",
				issuedAt: Date()
			)
		)
		
		XCTAssertThrowsError(
			try EIP4361.Message(
				scheme: "$cheme",
				domain: "test.com",
				address: .init("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")!,
				uri: URL(string: "https://example.com/login")!,
				version: .v1,
				chainId: 1,
				nonce: "32891756",
				issuedAt: Date()
			)
		)
	}
}
