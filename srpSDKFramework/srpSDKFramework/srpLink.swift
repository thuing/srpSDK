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
    
    public init(){
       
    }
    
    /// srp Link
    ///
    /// - Parameters:
    ///   - cid: The equipment‘s cid
    ///   - salt: The user's password salt, received from the server
    ///   - phone: The user's phone number
    ///   - password: Defined password
    /// - Returns: true 成功 false 失败
    public func srpRegister(cid:String,salt:String,phone:String,password:String,completion:@escaping (Bool) -> Void) {
        
        var flag:Bool = false
        let srp = TTSRPUtil()
        var initPwd = " "
        let reqUrl = "http://106.13.115.145/taisecurity/check/srpGetPInit"
        let paraDicP:Dictionary<String, Any> = ["userName":phone,"stableParam":password]
        
        Alamofire.request(reqUrl, method: .post, parameters: paraDicP, encoding: URLEncoding.default, headers: nil).responseJSON{ (response) in
            if(response.error) == nil{
                print("请求成功")
                let jsonValue = response.result.value
                // 得到info
                if jsonValue != nil {
                    print(jsonValue as Any)
                    let json = JSON(jsonValue!)
                    let code = json["code"].intValue
                    let data = json["data"].stringValue
                    if code == 200 {
                        initPwd = (srp.twoStringXor(str1: data, str2: password)).md5
                        UserDefaults.standard.set(password, forKey: uStableParam)
                        UserDefaults.standard.set(data, forKey: uChangeParam)
                        print("initp,即存储的密码值",initPwd)
 
                    // 将salt 和 pwd 转化为data
                    let sData = srp.stringToBigInt(str: salt).serialize()
                    let pData = srp.stringToBigInt(str: initPwd).serialize()
                    
                    // 计算x
                    let x = srp.doneInNU(value: srp.calculate_x(algorithm: .sha1, salt: sData, password: pData))
                    let v = String(srp.doneInNU(value: srp.calculate_v(x: x)))
                    print("@发送给服务器v的值为:",v)
                    
                    let reqUrlSrp1 = "http://106.13.115.145/taisecurity/check/register"
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
                                    
                                    let reqUrlSrp2 = "http://106.13.115.145/taisecurity/check/checkStart"
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
                                                    
                                                    let reqUrlSrp3 = "http://106.13.115.145/taisecurity/check/verify"
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
                                                                    let token = json["data"]["token"].stringValue
                                                                    // 校验H
                                                                    let HClient = srp.doneInNU(value: srp.calculate_H(algorithm: .sha1, A: BigInt(A)!.serialize(), M: M.serialize(), K: K.serialize()))
                                                                    if HService == HClient {
                                                                        let storedS = String(S)
                                                                        UserDefaults.standard.set(storedS, forKey: uSDKSRP)
                                                                        UserDefaults.standard.set(token, forKey: utoken)
                                                                        flag = true
                                                                        completion(flag)
                                                                    }
                                                                }
                                                                else{
                                                                    flag = false
                                                                    completion(flag)
                                                                    fatalError("request error")
                                                            }
                                                        }
                                                    }else{
                                                            // 判断如果请求失败
                                                            print("请求失败\(String(describing: response.error))")
                                                            flag = false
                                                            completion(flag)
                                                            fatalError("request error")
                                                        }
                                                    }
                                                    }else{
                                                        flag = false
                                                        completion(flag)
                                                        fatalError("request error")
                                                }
                                            }else{
                                                print("请求失败\(String(describing: response.error))")
                                                flag = false
                                                completion(flag)
                                                fatalError("request error")
                                            }
                                        }
                                    }
                                }else{
                                    flag = false
                                    completion(flag)
                                    fatalError("request error")
                                }
                            }else{
                                print("请求失败\(String(describing: response.error))")
                                flag = false
                                completion(flag)
                                fatalError("request error")
                            }
                        }
                    }
                    }else{
                        flag = false
                        completion(flag)
                        fatalError("request error")
                    }
                }else{
                    // 判断如果请求失败
                    print("请求失败\(String(describing: response.error))")
                    flag = false
                    completion(flag)
                    fatalError("request error")
                }
            }
        }
    }
    
    
    // srp 登录和校验
    public func srpLoginVerify(phone:String,salt:String,password:String,completion:@escaping (Bool) -> Void){
        
        var flag:Bool = false
        let srp = TTSRPUtil()
        
        // 将salt 和 pwd 转化为data
        let sData = srp.stringToBigInt(str: salt).serialize()
        let pData = srp.stringToBigInt(str: password).serialize()
        
        // 计算x
        let x = srp.doneInNU(value: srp.calculate_x(algorithm: .sha1, salt: sData, password: pData))
        
        // 计算出发送给服务端的A
        let A = String(srp.doneInNU(value: srp.g.power(srp.a, modulus: srp.N)))
        
        let reqUrlSrp2 = "http://106.13.115.145/taisecurity/check/checkStart"
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
                        
                        // 计算 S=（B-k*g^x）^ (a+u*x)
                        let S = srp.doneInNU(value: (B! - srp.k * srp.g.power(x, modulus: srp.N)).power(srp.a + u * x, modulus: srp.N))
                        
                        // 计算 K=H(S) sha1 算法
                        let H = Digest.hasher(.sha1)
                        let K = srp.doneInNU(value: BigInt(H(S.serialize())))
                        
                        // 计算M
                        let IData = srp.stringToData(str: phone)
                        let SData = srp.stringToData(str: salt)
                        
                        let M = srp.doneInNU(value: srp.calculate_M(algorithm: .sha1, username: IData, salt: SData, A: BigInt(A)!.serialize(), B: B!.serialize(), K: K.serialize()))
                        
                        /* srp 第三步 校验接口 */
                        let reqUrlSrp3 = "http://106.13.115.145/taisecurity/check/verify"
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
                                        
                                        if HService == HClient {
                                            flag = true
                                            completion(flag)
                                        }
                                    }else{
                                        flag = false
                                        completion(flag)
                                        fatalError("request error")
                                    }
                                }
                            }else{
                                // 判断如果请求失败
                                print("请求失败\(String(describing: response.error))")
                                flag = false
                                completion(flag)
                                fatalError("request error")
                            }
                        }
                        
                    }else{
                        flag = false
                        completion(flag)
                        fatalError("request error")
                    }
                }
            }else{
                print("请求失败\(String(describing: response.error))")
                flag = false
                completion(flag)
                fatalError("request error")
            }
        }
    }
    
}
    

