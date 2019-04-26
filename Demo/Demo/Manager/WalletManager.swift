//
//  WalletManager.swift
//  Demo
//
//  Created by liuxiaoliang on 2018/6/8.
//  Copyright © 2018年 HPB Foundation. All rights reserved.


import Foundation
import HPBWeb3SDK


struct HPBWalletManager {
    typealias WalletManagerResult = (state: Bool,errorMsg: String? )
    typealias WalletDataResult    = (state: Bool,errorMsg: String?,data:Data?)
}


extension HPBWalletManager{
    
    /// random generation of mnemonic
    @discardableResult
    static func generateMnemonics(complete: ((Data,String)->Void)? ) -> WalletManagerResult{
        guard let mnemonicStr = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: BIP39Language.english),let mnemonic = mnemonicStr else{
            return WalletManagerResult(false,"Failed to generate wallet!")
        }
        guard let seed = BIP39.seedFromMmemonics(mnemonic, language: BIP39Language.english) else{
             return WalletManagerResult(false,"Failed to generate wallet!")
        }
        let privateKey = seed.sha256()
        complete?(privateKey,mnemonic)
        return WalletManagerResult(true,nil)
    }
    
    
    /// Generate Kstore files with privateKey and password and store them locally
    @discardableResult
    static func generateKstoreFileBy(_ privateKey: Data,password: String,complete: ((String,String)->Void)?) -> WalletManagerResult{
        
        guard let HPBKeystore = try? HPBKeystoreV3(privateKey: privateKey, password: password),let ks = HPBKeystore else{
            return WalletManagerResult(false,"Failed to generate Keystore file")
        }
        guard  let keydata = try? JSONEncoder().encode(ks.keystoreParams)
            else{
            return WalletManagerResult(false,"Failed to get Keystore file")
        }
        guard let adress = ks.getAddress() else{
           return WalletManagerResult(false,"Failed to get Keystore file")
        }
        
        //Create a normal keystore file (randomly generated)
        //let filename = HPBFileManager.generateFileName(address: adress.addressData)
        
        //FIXME: In the actual process to be replaced with random generation
        let   filename = "Test"
        if FileManager.default.createFile(atPath: HPBFileManager.getKstoreDirectory() + filename, contents: keydata, attributes: nil){
            complete?(filename,adress.address.lowercased())
            return WalletManagerResult(true,nil)
        }else{
            return  WalletManagerResult(false,"Failed to generate Keystore file")
        }
    }
    
    
}

extension HPBWalletManager{
    
    private static func getLocalKstoreData(_ kstoreName: String) -> WalletDataResult{
        let kstorePath  =  HPBFileManager.getKstoreDirectory().appending(kstoreName)
        guard let fileData =  FileManager.default.contents(atPath: kstorePath) else{
            return WalletDataResult(false,"File reading error!",nil)
        }
         return WalletDataResult(true,nil,fileData)
    }
    
    /// Export Kstore file
    static func exportKstore(_ kstoreName: String,password: String) -> WalletDataResult{
        
        //First look at whether you can export the private key
        let privateKeyResult = exportPrivateKey(kstoreName, password: password)
        if privateKeyResult.state == false{
            return privateKeyResult
        }
        let getDataResult = HPBWalletManager.getLocalKstoreData(kstoreName)
        guard let fileData = getDataResult.data else{
            return getDataResult
        }
        return WalletDataResult(true,nil,fileData)
    }
    
    
    /// Export private key
    static func exportPrivateKey(_ kstoreName: String,password: String) -> WalletDataResult{
        
        let result = HPBWalletManager.getLocalKstoreData(kstoreName)
        guard let fileData = result.data else{
            return result
        }
        let hpbv3 = HPBKeystoreV3(fileData)
        guard let hpbAddress = hpbv3?.getAddress() else {
            return WalletDataResult(false,"Failed to get the address!",nil)
        }
        guard let data = try? hpbv3?.UNSAFE_getPrivateKeyData(password: password, account: hpbAddress)
            else{
                return WalletDataResult(false,"Enter the password incorrectly",nil)
        }
         return WalletDataResult(true,nil,data)
    }
}



extension HPBWalletManager{
    
    /// Import private key
    static func importByPrivateKey(_ privateData: Data,password: String,isUpdataPassword: Bool = false,success:((HPBWalletRealmModel)->Void)?) -> WalletManagerResult{
        do {
            let keystoreV3 = try HPBKeystoreV3(privateKey: privateData, password: password)
            guard let kV3 = keystoreV3 else {
                return WalletManagerResult(false,"The private key is not standardized, please check")
            }
            guard let keydata = try? JSONEncoder().encode(kV3.keystoreParams)else{
                return WalletManagerResult(false,"Import failed")
            }
            guard let adress = kV3.getAddress() else{
                return WalletManagerResult(false,"Import failed")
            }
            
            //Create a normal keystore file
            let filename = HPBFileManager.generateFileName(address: adress.addressData)
            if FileManager.default.createFile(atPath: HPBFileManager.getKstoreDirectory() + filename, contents: keydata, attributes: nil){
        
               let walletname = "New Wallet"
               let walletModel = HPBWalletRealmModel()
                walletModel.configModel(adress.address,
                                        kstoreName: filename,
                                        walletName: walletname,
                                        mnemonics: nil)
                success?(walletModel)
                return WalletManagerResult(true,nil)
            }else{
                return WalletManagerResult(false,"WalletHandel-Keystore-Creat-Faile")
            }
        }catch{
            return WalletManagerResult(false,"WalletHandel-Import-Faile")
        }
    }
    
    
    
   /// Import mnemonic
    static func importByMnemonics(mmemonics: String,password: String,tipInfo:String? = nil,success:((HPBWalletRealmModel)->Void)?) -> WalletManagerResult{
        guard let seed =  BIP39.seedFromMmemonics(mmemonics, language: BIP39Language.english) else{
            return WalletManagerResult(false,"WalletHandel-Import-Faile")
        }
        return HPBWalletManager.importByPrivateKey(seed.sha256(), password: password) {
            $0.mnemonics = nil  
            success?($0)
   
        }
    }
    
    
    ///Import kstore file
    @discardableResult
    static func importByKstore(kstore: String,password: String,isMapping:String? = "0",success:((HPBWalletRealmModel)->Void)?) -> WalletManagerResult{
        guard let keystoreV3 = HPBKeystoreV3(kstore),let address = keystoreV3.getAddress() else {
            return WalletManagerResult(false,"WalletHandel-Keystore-Faile")
        }
        do {
            let privateKeyData =  try keystoreV3.UNSAFE_getPrivateKeyData(password: password, account: address)
            return HPBWalletManager.importByPrivateKey(privateKeyData, password: password){
                success?($0)
            }
        }catch{
            return WalletManagerResult(false,"WalletHandel-Password-Error")
        }
    }
    
}


