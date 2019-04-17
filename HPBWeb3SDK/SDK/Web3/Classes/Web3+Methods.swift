//
//  Web3+Methods.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public enum JSONRPCmethod: String, Encodable {
    
    case gasPrice = "hpb_gasPrice"
    case blockNumber = "hpb_blockNumber"
    case getNetwork = "net_version"
    case sendRawTransaction = "hpb_sendRawTransaction"
    case sendTransaction = "hpb_sendTransaction"
    case estimateGas = "hpb_estimateGas"
    case call = "hpb_call"
    case getTransactionCount = "hpb_getTransactionCount"
    case getBalance = "hpb_getBalance"
    case getCode = "hpb_getCode"
    case getStorageAt = "hpb_getStorageAt"
    case getTransactionByHash = "hpb_getTransactionByHash"
    case getTransactionReceipt = "hpb_getTransactionReceipt"
    case getAccounts = "hpb_accounts"
    case getBlockByHash = "hpb_getBlockByHash"
    case getBlockByNumber = "hpb_getBlockByNumber"
    case personalSign = "hpb_sign"
    case unlockAccount = "personal_unlockAccount"
    case getLogs = "hpb_getLogs"
    
    public var requiredNumOfParameters: Int {
        get {
            switch self {
            case .call:
                return 2
            case .getTransactionCount:
                return 2
            case .getBalance:
                return 2
            case .getStorageAt:
                return 2
            case .getCode:
                return 2
            case .getBlockByHash:
                return 2
            case .getBlockByNumber:
                return 2
            case .gasPrice:
                return 0
            case .blockNumber:
                return 0
            case .getNetwork:
                return 0
            case .getAccounts:
                return 0
            default:
                return 1
            }
        }
    }
}

public struct JSONRPCRequestFabric {
    public static func prepareRequest(_ method: JSONRPCmethod, parameters: [Encodable]) -> JSONRPCrequest {
        var request = JSONRPCrequest()
        request.method = method
        let pars = JSONRPCparams(params: parameters)
        request.params = pars
        return request
    }
}
