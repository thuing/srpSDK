//
//  TTAIChain.swift
//  srpSDKFramework
//
//  Created by 小福 on 2019/3/22.
//  Copyright © 2019 小福. All rights reserved.
//

import Foundation

public class TTAIChain {
    
//    public init(uuidForDeviceKey: String){
//        // MARK: - 成员变量
//        // "com.srpSDKFramework"
//        let uuidForDeviceKey = uuidForDeviceKey
//    }
//
    
    static let uuidForDeviceKey = "com.srpSDKFramework"
    
    
    // MARK: - 公开方法
    /// 全局单例
    public static var shared: TTAIChain = {
        let instance = TTAIChain()
        return instance
    }()

    /// 设备的UUID
    public static var uuidForDevice: String {
        
        set {
            TTAIChain.shared.setValue(value: newValue, key: TTAIChain.uuidForDeviceKey, userDefaults: true, keychain: true, accessGroup: nil, synchronizable: false)
        }
        
        get {
            let uuid = TTAIChain.shared.getValueForKey(key: TTAIChain.uuidForDeviceKey, userDefaults: true, keychain: true, accessGroup: nil, synchronizable: false)
            return uuid!
        }
    }
    
    
    public static var  uuidForEquipment: String = {
        
        var deviceUUID = TTAIChain.uuid
        return deviceUUID;
    }()
    
    public static var uuid: String {
        var deviceUUID = UUID().uuidString.lowercased()
        deviceUUID = deviceUUID.replacingOccurrences(of: "-", with: "")
        return deviceUUID
    }
    
    // MARK: - 私有方法
    
    /// 创建uuid值
    /// 6da13cc6ae084f5ea4be6d20892c97fa
    /// 1a870ef59c904641969f33c9e142b0ae 6s
    
    func getValueForKey(key: String, userDefaults: Bool, keychain: Bool, accessGroup: String?,synchronizable: Bool) -> String? {
        
        var value: String?
        
        if keychain {
            let keychain = KeychainSwift()
            keychain.accessGroup = accessGroup
            value = keychain.get(key)
        }
        
        if value == nil {
            
            //如果为空的话，设置UUID
            value = TTAIChain.uuidForEquipment
            
            //保存到keychin
            self.setValue(value: value!, key: key, userDefaults: userDefaults, keychain: keychain, accessGroup: accessGroup, synchronizable: synchronizable)
        }
        
        return value
    }
    
    
    /// 保存键值到keychain
    ///
    /// - Parameters:
    ///   - value: 值
    ///   - key: 键
    ///   - userDefaults: 是否本地沙盒
    ///   - keychain: 是否keychain
    ///   - accessGroup: 应用组名
    ///   - synchronizable: 是否同步到多个设备 ,不可同步到其他设备
    func setValue(value: String, key: String, userDefaults: Bool, keychain: Bool, accessGroup: String?, synchronizable: Bool) {
        
        if keychain {
            
            let keychain = KeychainSwift()
            keychain.accessGroup = accessGroup
            keychain.synchronizable = synchronizable
            keychain.set(value, forKey: key)
            
        }
    }
}


