//
//  ZBUUID.swift
//  ZBUUID
//
//  Created by Nick luo on 2018/12/22.
//  Copyright © 2018 Nick luo. All rights reserved.
//

import UIKit

public class ZBUUID: NSObject {
    
    // MARK: - 成员变量
  
    static let uuidForDeviceKey = "zb_uuidForDevice";
 
    // MARK: - 公开方法
    /// 全局单例
    public static var shared: ZBUUID = {
        let instance = ZBUUID()
        return instance
    }()
    
    /// 重写初始化
    public override init() {
        super.init()
    }
    
    /// 设备的UUID
    public static var uuidForDevice: String {
        
        set {
            ZBUUID.shared.setValue(value: newValue, key: ZBUUID.uuidForDeviceKey, userDefaults: true, keychain: true, accessGroup: nil, synchronizable: false)
        }
        
        get {
            let uuid = ZBUUID.shared.getValueForKey(key: ZBUUID.uuidForDeviceKey, userDefaults: true, keychain: true, accessGroup: nil, synchronizable: false)
            return uuid!
        }
        
    }
    

    /// 获取一个由苹果分配给应用开发者对每个设备唯一的IDFV作为UUID
    /// 获取设备的IDFV
    //
    //  顾名思义，是给Vendor标识用户用的，每个设备在所属同一个Vender的应用里，都有相同的值。其中的Vender是指应用提供商，但准确点说，是通过BundleID的反转的前两部分进行匹配，如果相同就是同一个Vender，例如对于com.taobao.app1, com.taobao.app2 这两个BundleID来说，就属于同一个Vender，共享同一个idfv的值。和idfa不同的是，idfv的值是一定能取到的，所以非常适合于作为内部用户行为分析的主id，来标识用户，替代OpenUDID。
    //
    //  注意：如果用户将属于此Vender的所有App卸载，则idfv的值会被重置，即再重装此Vender的App，idfv的值和之前不同。
    public static var  uuidForVendor: String = {
        
        var deviceUUID = ""
        if let idfv = UIDevice.current.identifierForVendor?.uuidString {
            deviceUUID = idfv.lowercased()
            deviceUUID = deviceUUID.replacingOccurrences(of: "-", with: "")
            
        } else {
            //idfv有可能获取不到，那就用
            deviceUUID = ZBUUID.uuid
        }
        
        return deviceUUID;
    }()
    
    /// 获取不到idfv，只能使用随机的uuid
    public static var uuid: String {
        var deviceUUID = UUID().uuidString.lowercased()
        deviceUUID = deviceUUID.replacingOccurrences(of: "-", with: "")
        return deviceUUID
    }
    
    
    // MARK: - 私有方法

    /// 获取keychain或userDefaults上的值，没有的话，创建uuid值
    ///
    func getValueForKey(key: String, userDefaults: Bool, keychain: Bool, accessGroup: String?,synchronizable: Bool) -> String? {
        
        var value: String?
        
        if keychain {
            let keychain = KeychainSwift()
            keychain.accessGroup = accessGroup
            value = keychain.get(key)
        }
        
        if value == nil && userDefaults {
            value = UserDefaults.standard.value(forKey: key) as? String
           
            //如果为空的话，设置UUID
             value = ZBUUID.uuidForVendor
            
            //保存到keychin
             self.setValue(value: value!, key: key, userDefaults: userDefaults, keychain: keychain, accessGroup: accessGroup, synchronizable: synchronizable)
            
        }else{
            //注意：如果用户将属于此Vender的所有App卸载，则idfv的值会被重置，即再重装此Vender的App，idfv的值和之前不同。
            // 所以如果KeyChian存在value的情况下，比较KeyChian中的value与取到 ZBUUID.uuidForVendor，不相等的话，更新KeyChian值
            
              let newValue = ZBUUID.uuidForVendor
              if value != newValue {
                
                //如果不为空的话，设置UUID
                value = ZBUUID.uuidForVendor
                
                //保存到keychin
                self.setValue(value: value!, key: key, userDefaults: userDefaults, keychain: keychain, accessGroup: accessGroup, synchronizable: synchronizable)
              }
        }
        
        return value
    }
    
    
    /// 保存键值到本地沙盒和keychain
    ///
    /// - Parameters:
    ///   - value: 值
    ///   - key: 键
    ///   - userDefaults: 是否本地沙盒
    ///   - keychain: 是否keychain
    ///   - accessGroup: 应用组名
    ///   - synchronizable: 是否同步到多个设备
    func setValue(value: String, key: String, userDefaults: Bool, keychain: Bool, accessGroup: String?, synchronizable: Bool) {
        
        if userDefaults {
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize();
        }
        
        if keychain {
            
            let keychain = KeychainSwift()
            keychain.accessGroup = accessGroup
            keychain.synchronizable = synchronizable
            keychain.set(value, forKey: key)
        }
    }
}


//// MARK: - 给UIDevice类扩展获取AIUUID的方法
//public extension UIDevice {
//
//    public var ai_uuid: String {
//        return ZBUUID.uuidForDevice
//    }
//}


