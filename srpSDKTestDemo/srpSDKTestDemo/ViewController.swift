//
//  ViewController.swift
//  srpSDKTestDemo
//
//  Created by 小福 on 2019/3/19.
//  Copyright © 2019 小福. All rights reserved.
//

import UIKit
import srpSDKFramework

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设备cid值，服务器提供的盐值，手机号码,密码
        let cid = "8aac99bfdff6870b28f74fcfb191a2e9"
        let salt = "9747df036755404c971255ab358a3a8d"
        let phone = "13818120453"
        
        // password = phone
        let UUID = TTAIChain.uuidForDevice
        let password = (phone + UUID).md5
        print("password is ", password)
        
        // srp三步
        let srp = srpLink()
        srp.srpRegister(cid: cid, salt: salt, phone: phone, password: password){
            (flag) in
            if flag {
                // 登录成功
                // 跳转到主页
                print("登录成功")
            }else{
                print("登录失败")
            }
        }
        
//        // 需要srp登录、校验
//        srp.srpLoginVerify(phone: phone, salt: salt, password: password){
//            (flag) in
//            if flag {
//                // 登录成功
//                // 跳转到主页
//                print("登录成功")
//            }else{
//                print("登录失败")
//            }
//        }
    }

}

extension String {
    //获取子字符串
    func substingInRange(_ r: Range<Int>) -> String? {
        if r.lowerBound < 0 || r.upperBound > self.count {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy:r.lowerBound)
        let endIndex   = self.index(self.startIndex, offsetBy:r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
