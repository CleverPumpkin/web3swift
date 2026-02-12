import XCTest
import Web3Core

@testable import web3swift

final class SignatureRecoveryCompatibilityTests: XCTestCase {

    private struct Fixture {
        let message: Data
        let hash: Data
        let signature: Data
        let expectedAddress: EthereumAddress
        let expectedAddressString: String
    }

    private func makeFixture() throws -> Fixture {
        let privateKey = Data(repeating: 0x01, count: 32)
        let message = Data("web3swift-xcode-compatibility".utf8)

        let hash = try XCTUnwrap(Utilities.hashPersonalMessage(message))
        let signature = try XCTUnwrap(SECP256K1.signForRecovery(hash: hash, privateKey: privateKey).serializedSignature)
        let publicKey = try XCTUnwrap(Utilities.privateToPublic(privateKey))
        let expectedAddress = try XCTUnwrap(Utilities.publicToAddress(publicKey))
        let expectedAddressString = try XCTUnwrap(Utilities.publicToAddressString(publicKey))

        return Fixture(
            message: message,
            hash: hash,
            signature: signature,
            expectedAddress: expectedAddress,
            expectedAddressString: expectedAddressString
        )
    }

    func testHashECRecoverRecoversExpectedAddress() throws {
        let fixture = try makeFixture()

        let recoveredAddress = Utilities.hashECRecover(hash: fixture.hash, signature: fixture.signature)

        XCTAssertEqual(recoveredAddress, fixture.expectedAddress)
    }

    func testPersonalECRecoverRecoversExpectedAddress() throws {
        let fixture = try makeFixture()

        let recoveredAddress = Utilities.personalECRecover(fixture.message, signature: fixture.signature)

        XCTAssertEqual(recoveredAddress, fixture.expectedAddress)
    }

    func testBrowserFunctionsPersonalECRecoverRecoversExpectedAddress() throws {
        let fixture = try makeFixture()
        let provider = Web3HttpProvider(
            url: URL(string: "http://localhost:8546")!,
            network: .Mainnet
        )
        let web3 = Web3(provider: provider)

        let recoveredAddress = web3.browserFunctions.personalECRecover(
            fixture.message,
            signature: fixture.signature
        )

        XCTAssertEqual(recoveredAddress, fixture.expectedAddressString)
    }
}
