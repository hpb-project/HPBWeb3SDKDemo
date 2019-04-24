Pod::Spec.new do |s|
s.name             = "HPBWeb3SDK"
s.version          = "1.0.0"
s.summary          = "HPBWeb3SDK rewritten from web3Swift for easy iOS rapid development and connection to HPB main network"

s.description      = <<-DESC
HPBWeb3SDK rewritten from web3Swift for easy iOS rapid development and connection to HPB main network
DESC

s.homepage         = "https://github.com/HPBBlockchain/HPBWeb3SDKDemo"
s.license          = 'Apache License 2.0'
s.author           = { "Jason" => "hpblian2018@qq.com" }
s.source           = { :git => "https://github.com/hpb-project/HPBWeb3SDKDemo"}

s.swift_version = '4.2'
s.module_name = 'HPBWeb3SDK'
s.ios.deployment_target = "9.0"
s.source_files = "HPBWeb3SDK/SDK/*/*/*.swift"

s.frameworks = 'CoreImage'
s.dependency 'Result', '~> 3.0.0'
s.dependency 'Alamofire', '~> 4.8.2'
s.dependency 'Alamofire-Synchronous','~> 4.0.0'
s.dependency 'libsodium', '~> 1.0.12'
s.dependency 'secp256k1_ios', '~> 0.1.3'
s.dependency 'CryptoSwift', '~> 0.9.0'
s.dependency 'BigInt' , '~> 3.0.0'
end
