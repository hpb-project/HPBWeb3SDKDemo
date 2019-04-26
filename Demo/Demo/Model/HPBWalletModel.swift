//
//  HPBWalletModel.swift
//  Test
//
//  Created by 刘晓亮 on 2019/4/11.
//  Copyright © 2019 Zhaoxi Network. All rights reserved.
//

import Foundation

class HPBWalletRealmModel{
     var  addressStr: String?
     var  kstoreName: String?
     var  walletName: String?
     var  mnemonics:  String?
     var  tipInfo  :  String?
    
    func configModel(_ address: String,
                     kstoreName: String? = nil,
                     walletName: String,
                     mnemonics: String?,
                     tipInfo: String? = nil){
        self.addressStr = address
        self.kstoreName = kstoreName
        self.walletName = walletName
        self.mnemonics = mnemonics
        self.tipInfo = tipInfo
    }

}
