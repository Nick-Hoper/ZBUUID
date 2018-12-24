# ZBUUID

>苹果唯一的标识码

- 获取一个由苹果分配给应用开发者对每个设备唯一的IDFV作为UUID

 顾名思义，是给Vendor标识用户用的，每个设备在所属同一个Vender的应用里，都有相同的值。其中的Vender是指应用提供商，但准确点说，是通过BundleID的反转的前两部分进行匹配，如果相同就是同一个Vender，例如对于com.taobao.app1, com.taobao.app2 这两个BundleID来说，就属于同一个Vender，共享同一个idfv的值。和idfa不同的是，idfv的值是一定能取到的，所以非常适合于作为内部用户行为分析的主id，来标识用户，替代OpenUDID。

注意：如果用户将属于此Vender的所有App卸载，则idfv的值会被重置，即再重装此Vender的App，idfv的值和之前不同。
为了解决这个问题，我引入了keychian保存生成的UUID，如果用户卸载重新安装，那么UUID必定和keychian保存的不一致，则需要
更新keychian的UUID，并且将用户信息以及对应最新的UUID上传服务器，这样可以保证每个用户的UUID的唯一性

## Features

- 完美支持Swift4.2编译
- 使用IDFV作为UUID，可靠性强


## Requirements

- iOS 9+
- Xcode 8+
- Swift 4.0+
- iPhone

## Example

        //1、获取系统的idfv
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
        
   
        ///2、 获取keychain或userDefaults上的值，没有的话，创建uuid值
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

        //3、保存键值到本地沙盒和keychain
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
        

更详细集成方法，根据实际的例子请查看源代码中的demo
注意：因为使用了Keychian，所以需要开启keychian ： targets -- Capabilities -- keychian sharing 打开



