//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import Result
import BigInt

extension web3.web3contract {

    public class TransactionIntermediate{
        public var transaction:HPBTransaction
        public var contract: ContractProtocol
        public var method: String
        public var options: Web3Options? = Web3Options.defaultOptions()
        var web3: web3
        public init (transaction: HPBTransaction, web3 web3Instance: web3, contract: ContractProtocol, method: String, options: Web3Options?) {
            self.transaction = transaction
            self.web3 = web3Instance
            self.contract = contract
            self.contract.options = options
            self.method = method
            self.options = Web3Options.merge(web3.options, with: options)
            if self.web3.provider.network != nil {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        public func setNonce(_ nonce: BigUInt) throws {
            self.transaction.nonce = nonce
            if (self.web3.provider.network != nil) {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending", callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
            guard let operation = ContractSendOperation.init(web3, queue: web3.queue, intermediate: self, options: options, onBlock: onBlock, password: password) else {
                guard let dispatchQueue =  queue.underlyingQueue else {return}
                return dispatchQueue.async {
                    callback(Result<AnyObject, Web3Error>.failure(Web3Error.dataError))
                }
            }
            operation.next = OperationChainingType.callback(callback, queue)
            self.web3.queue.addOperation(operation)
        }
        
        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Result<[String:String], Web3Error> {
            
            var externalResult: Result<[String:String], Web3Error>!
            let semaphore = DispatchSemaphore(value: 0)
            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
                switch res {
                case .success(let result):
                    guard let unwrappedResult = result as? String else {
                        externalResult = Result.failure(Web3Error.dataError)
                        break
                    }
                    let resultDict = ["txhash" : unwrappedResult] as [String: String]
                    externalResult = Result<[String:String], Web3Error>(resultDict)
                case .failure(let error):
                    externalResult = Result.failure(error)
                    break
                }
                semaphore.signal()
            }
            send(password: password, options: options, onBlock: onBlock, callback: callback, queue: self.web3.queue)
            _ = semaphore.wait(timeout: .distantFuture)
            return externalResult

        }
        
        public func sendSigned() -> Result<[String:String], Web3Error> {
            print(self.transaction)
            return self.web3.hpb.sendRawTransaction(self.transaction)
        }
        
        
        public func call(options: Web3Options?, onBlock: String = "latest") -> Result<[String:Any], Web3Error> {
            
            var externalResult: Result<[String:Any], Web3Error>!
            let semaphore = DispatchSemaphore(value: 0)
            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
                switch res {
                case .success(let result):
                    guard let unwrappedResult = result as? [String:Any] else {
                        externalResult = Result.failure(Web3Error.dataError)
                        break
                    }
                    externalResult = Result<[String:Any], Web3Error>(unwrappedResult)
                case .failure(let error):
                    externalResult = Result.failure(error)
                    break
                }
                semaphore.signal()
            }
            call(options: options, onBlock: onBlock, callback: callback, queue: self.web3.queue)
            _ = semaphore.wait(timeout: .distantFuture)
            return externalResult
        }
        
        public func call(options: Web3Options?, onBlock: String = "latest", callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
//            let mergedOptions = Web3Options.merge(self.options, with: options)
//            self.options = mergedOptions
            guard let operation = ContractCallOperation(web3, queue: web3.queue, intermediate: self, onBlock: onBlock, options: options) else {
                guard let dispatchQueue =  queue.underlyingQueue else {return}
                return dispatchQueue.async {
                    callback(Result<AnyObject, Web3Error>.failure(Web3Error.dataError))
                }
            }
            operation.next = OperationChainingType.callback(callback, queue)
            self.web3.queue.addOperation(operation)
        }
        
        public func estimateGas(options: Web3Options?, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
            let mergedOptions = Web3Options.merge(self.options, with: options)
            return self.web3.hpb.estimateGas(self.transaction, options: mergedOptions, onBlock: onBlock)
        }
        
        public func estimateGas(options: Web3Options?, onBlock: String = "latest", callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
            let mergedOptions = Web3Options.merge(self.options, with: options)
            self.options = mergedOptions
            guard let operation = ContractEstimateGasOperation.init(web3, queue: web3.queue, intermediate: self, onBlock: onBlock) else {
                guard let dispatchQueue =  queue.underlyingQueue else {return}
                return dispatchQueue.async {
                    callback(Result<AnyObject, Web3Error>.failure(Web3Error.dataError))
                }
            }
            operation.next = OperationChainingType.callback(callback, queue)
            self.web3.queue.addOperation(operation)
        }
    }
}
