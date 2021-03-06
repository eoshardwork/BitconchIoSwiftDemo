//
//  ViewController.swift
//  BitconchIoSwiftDemo
//
//  Created by brave on 2019/10/15.
//  Copyright © 2019 brave. All rights reserved.
//

import UIKit
import EosioSwift
import EosioSwiftAbieosSerializationProvider
import EosioSwiftSoftkeySignatureProvider

class ViewController: UIViewController {
    
    // 参数相关
    // SUPPLY VALUES TO THESE VARIABLES TO RUN EXAMPLE APP
    let endpoint = URL(string: "http://101.200.40.205:8888")! // override with node endpoint URL
    let privateKeys = ["5KFgpXJmRJ88WmKVgy5fxffDJTty8gAfyHuduJKEa5xFxmTsdWq"]
    let currencySymbol = "BUS" // override to the token of your choice (e.g., "BUS")
    //    let permission = "active" // override if needed
    let code = "sys.token" // 合约名称
    
    // Transfer action data variables
    let from = "helloworld1a"
    let to = "helloworld1b"
    let from_address = "B5AxZ1vdK9r6JeLXUjShRXcd4Wzf874VTathjr8ibnQE72npue6"
    let to_address = "B5pfwUdBDTDLLvuLMN8TvMbmMqn2adUEBk3kSEuFkMaxbjaw5dr"
    let quantity = "1.0000 BUS" // override if needed (e.g., "1.0000 BUS")
    let memo = "bravus test" // override if needed
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /// 生成公私钥
        generatorKeyPair()
        
        /// 从私钥导出公钥
        recoverPublicKey()
        
        // 查询x余额
        refreshBalance(code: code, account: from, symbol: currencySymbol) // After the view loads, we use the RPC provider to get the account's currency balance.
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("send token")
        
        excuteTransactionExt()
    }
}

extension ViewController {
    /// 生成公私钥
    func generatorKeyPair() {
        print("Hello, BitconchIO!")
        let (pk, pub) = generateRandomKeyPair(enclave: .Secp256k1)
        print("private key: \(pk!.rawPrivateKey())")
        print("public key : \(pub!.rawPublicKey())")
        
    }
    
    /// 从私钥导出公钥
    func recoverPublicKey() {
//        private key: 5J78qUfry3y4HsUkCMg1Fh6zunhSdfQo48rxNFLZ3UyFtCHAHiG
//        public key : BUS79R4Z87cwVgWWLTVz9huvgULpMjTZPPwUWPfmevmRdguddsZdU
        if let privateKey: PrivateKey = try? PrivateKey(keyString: "5J78qUfry3y4HsUkCMg1Fh6zunhSdfQo48rxNFLZ3UyFtCHAHiG") {
            let publicKey: PublicKey = PublicKey(privateKey: privateKey)
            debugPrint(publicKey.rawPublicKey())
        }
    }
    
    /// 查询余额
    func refreshBalance(code: String, account: String, symbol: String) {
        let rpcProvider: EosioRpcProvider = EosioRpcProvider(endpoint: endpoint)
        
        // Set up the currency balance request.
        let balanceRequest = EosioRpcCurrencyBalanceRequest(code: code, account: from, symbol: currencySymbol)
        
        // Pass it into our RPC Provider instance. Handle success and failure as appropriate.
        // Remember, you can also get promises back with: `rpcProvider.getCurrencyBalance(.promise, requestParameters: balanceRequest)`.
        rpcProvider.getCurrencyBalance(requestParameters: balanceRequest) { result in
            switch result {
            case .success(let balance):
                print(balance.currencyBalance[0])
            case .failure(let error):
                print("BALANCE REFRESH FAILURE")
                print(error)
                print(error.reason)
            }
        }
    }
    
    /// 测试交易并返回交易体
    func excuteTransaction() {
        /// 执行交易，获取交易体
        let parameter = TransactionParameter(endpoint: self.endpoint, code: self.code, from: self.from, to: self.to, quantity: self.quantity, memo: self.memo, privateKeys: self.privateKeys)
        
        BitconchIoTransaction.executeTransferTransaction(parameter: parameter) { (result, body) in
            // Handle our result, success or failure, appropriately.
            switch result {
            case .failure (let error):
                print("ERROR SIGNING OR BROADCASTING TRANSACTION")
                print(error)
                print(error.reason)
            case .success:
                print(body)
            }
        }
    }
    
    /// 测试交易并返回交易体ext
    func excuteTransactionExt() {
        /// 执行交易，获取交易体
        let parameter = TransactionParameterExt(endpoint: self.endpoint, code: self.code, from: self.from, from_address: self.from_address, to_address: self.to_address, quantity: self.quantity, memo: self.memo, privateKeys: self.privateKeys)
        
        BitconchIoTransaction.executeTransferTransactionExt(parameter: parameter) { (result, body) in
            // Handle our result, success or failure, appropriately.
            switch result {
            case .failure (let error):
                print("ERROR SIGNING OR BROADCASTING TRANSACTION")
                print(error)
                print(error.reason)
            case .success:
                print(body)
            }
        }
    }
}
