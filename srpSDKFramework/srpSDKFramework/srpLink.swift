//
//  srpLink.swift
//  srpSDKFramework
//
//  Created by 小福 on 2019/3/19.
//  Copyright © 2019 小福. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BigInt
import Cryptor

// srp接口

public class srpLink {
    
//    public init(uuidForDeviceKey: String){
//
//        // 初始化UUID
//
//        let UUIDKeyChain = TTAIChain.init(uuidForDeviceKey: uuidForDeviceKey)
//        let UUID = TTAIChain.uuidForDevice
//        
//    }
    
    public init(){
       
    }
    
    /// srp接入
    ///
    /// - Parameters:
    ///   - reqUrl: The request url
    ///   - cid: The equipment‘s cid
    ///   - salt: The user's password salt, received from the server.
    ///   - phone: The user's phone number
    /// - Returns: true 成功 false 失败
    
    // 第一步 注册接口
    public func srpRegister(cid:String,salt:String,phone:String) {
        
        let srp = TTSRPUtil()
        // password = phone前十位 + UUID + phone/前十位
        let phoneFirst = phone.substingInRange(0..<10)
        //let UUIDKeyChain = TTAIChain()
        let UUID = TTAIChain.uuidForDevice
        // b93c22bab80545bb9f65f6193f378873
        print("UUID is ",UUID)
        let password = phoneFirst! + srp.dy_getDeviceUUID()!.substingInRange(0..<4)! + phoneFirst!
        print("password is ", password)
        
        // 将salt 和 pwd 转化为data
        let sData = srp.stringToBigInt(str: salt).serialize()
        let pData = srp.stringToBigInt(str: password).serialize()
        
        // 计算x
        let x = srp.doneInNU(value: srp.calculate_x(algorithm: .sha1, salt: sData, password: pData))
        let v = String(srp.doneInNU(value: srp.calculate_v(x: x)))
        print("@发送给服务器v的值为:",v)
        
        let reqUrlSrp1 = "http://101.91.223.96:9000/taisecurity/check/register"
        let paraDicSrp:Dictionary<String, Any> = ["phone":phone,"cid":cid, "v":v]
        
        Alamofire.request(reqUrlSrp1, method: .post, parameters:paraDicSrp , encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if(response.error == nil){
                print("请求成功")
                let jsonValue = response.result.value
                // 得到info
                if jsonValue != nil {
                    print(jsonValue as Any)
                    let json = JSON(jsonValue!)
                    let code = json["code"].intValue
                    if code == 200 {
                        
                        // srp 第二步
                        // 计算出发送给服务端的A
                        let A = String(srp.doneInNU(value: srp.g.power(srp.a, modulus: srp.N)))
                        print("@发送给服务器端A值为:",A)
                        
                        let reqUrlSrp2 = "http://101.91.223.96:9000/taisecurity/check/checkStart"
                        let paraDicSrp:Dictionary<String, Any> = ["paramA":A, "userName":phone]
                        
                        Alamofire.request(reqUrlSrp2, method: .post, parameters:paraDicSrp , encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
                            if(response.error == nil){
                                print("请求成功")
                                let jsonValue = response.result.value
                                // 得到info
                                if jsonValue != nil {
                                    print(jsonValue as Any)
                                    let json = JSON(jsonValue!)
                                    let code = json["code"].intValue
                                    if code == 200 {
                                        let B = BigInt(json["data"]["B"].stringValue)
                                        
                                        // 计算u=H(A+B) sha1算法
                                        let u = srp.doneInNU(value: srp.calculate_u(algorithm: .sha1, A: BigInt(A)!.serialize(), B: B!.serialize()))
                                        print("@共同计算u的值为:",u)
                                        
                                        // 计算 S=（B-k*g^x）^(a+u*x)
                                        let S = srp.doneInNU(value: (B! - srp.k * srp.g.power(x, modulus: srp.N)).power(srp.a + u * x, modulus: srp.N))
                                        print("客户端S值:",S)
                                        
                                        // 计算 K=H(S) sha1 算法
                                        let H = Digest.hasher(.sha1)
                                        let K = srp.doneInNU(value: BigInt(H(S.serialize())))
                                        print("客户端K值:",K as Any)
                                        
                                        // 计算M
                                        let IData = srp.stringToData(str: phone)
                                        let SData = srp.stringToData(str: salt)
                                        
                                        let M = srp.doneInNU(value: srp.calculate_M(algorithm: .sha1, username: IData, salt: SData, A: BigInt(A)!.serialize(), B: B!.serialize(), K: K.serialize()))
                                        print("客户端计算的M:",M)
                                        
                                        /* srp 第三步 校验接口 */
                                        
                                        let reqUrlSrp3 = "http://101.91.223.96:9000/taisecurity/check/verify"
                                        let paraDicSrp:Dictionary<String, Any> = ["userName":phone,"paramM":String(M)]
                                        Alamofire.request(reqUrlSrp3, method: .post, parameters:paraDicSrp , encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
                                            if(response.error == nil){
                                                print("请求成功")
                                                let jsonValue = response.result.value
                                                // 得到info
                                                if jsonValue != nil {
                                                    print(jsonValue as Any)
                                                    if code == 200 {
                                                        let json = JSON(jsonValue!)
                                                        let HService = BigInt(json["data"]["H"].stringValue)
                                                        
                                                        // 校验H
                                                        let HClient = srp.doneInNU(value: srp.calculate_H(algorithm: .sha1, A: BigInt(A)!.serialize(), M: M.serialize(), K: K.serialize()))
                                                        print("H is " ,HClient)
                                                        if HService == HClient {
                                                            let storedS = String(S)
                                                            print("srp3 ")
                                                            print("存储的S",storedS)
                                                        }
                                                    }else{
                                                }
                                            }
                                        }else{
                                                // 判断如果请求失败
                                                print("请求失败\(String(describing: response.error))")
                                            }
                                        }
                                        }else{
                                    }
                                }else{
                                    print("请求失败\(String(describing: response.error))")
                                }
                            }
                        }
                    }else{
                        
                    }
                }else{
                    print("请求失败\(String(describing: response.error))")
                }
            }
        }
    }
    
    
}
