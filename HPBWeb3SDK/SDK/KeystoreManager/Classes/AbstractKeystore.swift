//
//  AbstractKeystore.swift
//  web3swift
//
//  Created by Alexander Vlasov on 10.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public typealias TransactionIntermediate = web3.web3contract.TransactionIntermediate


public protocol AbstractKeystore {
    var addresses: [HPBAddress]? {get}
    var isHDKeystore: Bool {get}
    func UNSAFE_getPrivateKeyData(password: String, account: HPBAddress) throws -> Data
}

public enum AbstractKeystoreError: Error {
    case noEntropyError
    case keyDerivationError
    case aesError
    case invalidAccountError
    case invalidPasswordError
    case encryptionError(String)
}
