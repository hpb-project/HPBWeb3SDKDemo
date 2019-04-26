HPBWeb3SDK provides a convenient way to quickly build your own HPB wallet for iOS developers.

### Features

* Create Account
* Import Account
* Sign transactions
* Send transactions


### Requirements

HPBWeb3SDK requires `Swift 4.2` and deploys to `macOS 10.10`, `iOS 9`.Temporarily does not support swift5. It is best to use Xcode10.1 for development.

### Installation

HPBWeb3SDK is recommended to use cocoapods to install.

#### Podfile
To integrate HPBWeb3SDK into your Xcode project using CocoaPods, specify it in your Podfile:

```
platform :ios, '9.0'

target 'TargetName' do
    inhibit_all_warnings!
    use_frameworks!
    pod 'HPBWeb3SDK', '~> 1.0.0'
end

```

Then, run the following command:

```
$ pod install
```

### Usage

Below is the basic code,Please refer to the Demo for details.

#### Parameter definition

```
 typealias WalletManagerResult = (state: Bool,errorMsg: String? )
 typealias WalletDataResult    = (state: Bool,errorMsg: String?,data:Data?)

```

#### Creat Account

random generation of mnemonic

```
 guard let mnemonicStr = try? BIP39.generateMnemonics(bitsOfEntropy: 128, language: BIP39Language.english),let mnemonic = mnemonicStr else{
            print("Failed to generate wallet!")
        }
        guard let seed = BIP39.seedFromMmemonics(mnemonic, language: BIP39Language.english) else{
             print(false,"Failed to generate wallet!")
        }
        let privateKey = seed.sha256()
        print(privateKey,mnemonic)
```

Generate Kstore files with privateKey and password 

```
 guard let HPBKeystore = try? HPBKeystoreV3(privateKey: privateKey, password: password),let ks = HPBKeystore else{
           print("Failed to generate Keystore file")
        }

```

#### Import Account 

Import private key

```
let keystoreV3 = try HPBKeystoreV3(privateKey: privateData, password: password)
.....

```


Import mnemonic

```
 guard let seed =  BIP39.seedFromMmemonics(mmemonics, language: BIP39Language.english) else{
           print("WalletHandel-Import-Faile")
        }
  HPBWalletManager.importByPrivateKey(seed.sha256(), password: password,tipInfo: tipInfo) {
        }

```

Import kstore file

```
 guard let keystoreV3 = HPBKeystoreV3(kstore),let address = keystoreV3.getAddress() else {
            print("WalletHandel-Keystore-Faile")
        }
        do {
            let privateKeyData =  try keystoreV3.UNSAFE_getPrivateKeyData(password: password, account: address)
           HPBWalletManager.importByPrivateKey(privateKeyData, password: password){
           
            }
        }catch{
            print("WalletHandel-Password-Error")
        }

```

#### Export Account 

Export Kstore file

```
let privateKeyResult = exportPrivateKey(kstoreName, password: password)
.....

```

Export private key

```
 let hpbv3 = HPBKeystoreV3(fileData)
        guard let hpbAddress = hpbv3?.getAddress() else {
           print("Failed to get the address!",nil)
        }
        guard let data = try? hpbv3?.UNSAFE_getPrivateKeyData(password: password, account: hpbAddress)
            else{
               print("Enter the password incorrectly",nil)
        }

```

#### Transaction
