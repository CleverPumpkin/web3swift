//
//  EIP4361.Message.ValidationError.swift
//  Web3swift
//
//  Created by Nikita Tarkhov on 21.03.2025.
//

public extension EIP4361.Message {
	enum ValidationError: Error {
		case invalidValue(key: String, value: String)
	}
}
