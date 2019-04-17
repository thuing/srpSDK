//
//  srpUtil.swift
//  srpSDKFramework
//
//  Created by 小福 on 2019/3/19.
//  Copyright © 2019 小福. All rights reserved.
//

import Foundation
import BigInt
import Cryptor

public class TTSRPUtil {
    
    // 服务器传值 N ，g ，s 盐值
    let N :BigInt = BigInt("9223372036854775817")
    let g :BigInt = BigInt("9223372036854775889")
    let k :BigInt = BigInt("3")
    
    // mod N
    func doneInNU(value:BigInt) -> BigInt {
        return value.modulus(BigInt(N))
    }
    
    // 随机生成一个64位的随机a值
    var a :BigInt = BigInt(BigUInt.randomInteger(withMaximumWidth: 64))
    
    func dy_getDeviceUUID() -> String? {
        let uuid = CFUUIDCreate(nil)
        let uuidStr = CFUUIDCreateString(nil, uuid)
        return (uuidStr)! as String
    }
    
    func stringToArray(input:String) -> Array<Any> {
        return  input.map { String($0) }
    }
    
    let TABLE:Array<Any> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", ".", "/"]
    
    public func stringToArrayStr(input:String) -> Array<String> {
        return  input.map { String($0) }
    }
    
    func convertToASCII(str:String) -> UInt32{
        var number:UInt32 = 0
        for code in str.unicodeScalars {
            number = code.value
        }
        return number
    }
    
    
    /**
     * 两个字符串的异或
     * @Param str1
     * @Param str2
     * @return String(xorstr)
     */
    
    public func twoStringXor(str1:String,str2:String) -> String{
        let b1 = stringToArrayStr(input: str1)
        let b2 = stringToArrayStr(input: str2)
        var longbytes:[String] = []
        var shortbytes:[String] = []
        
        if(b1.count >= b2.count){
            longbytes = b1
            shortbytes = b2
        }else{
            longbytes = b2
            shortbytes = b1
        }
        
        var xorstr = [Character](repeating: "0", count: longbytes.count)
        
        var i = 0
        for _ in 0..<shortbytes.count{
            let shortNumber = convertToASCII(str: shortbytes[i])
            let longNumber = convertToASCII(str: longbytes[i])
            xorstr[i] = Character(UnicodeScalar(shortNumber^longNumber)!)
            i = i + 1
            
        }
        for _ in i..<longbytes.count{
            xorstr[i] = Character(UnicodeScalar(convertToASCII(str: longbytes[i]))!)
        }
        
        let newStr = String(xorstr)
        return newStr
    }
    
    // 无符号右移 >>>
    func relizeRight(value:Int, bit: Int) -> Int {
        //将十进制转为二进制
        var caculate = String.init(value, radix:2)
        
        if caculate.first == "-" {
            let index = caculate.index(caculate.startIndex, offsetBy:1)
            caculate = String(caculate[index...])
            // caculate = caculate.substring(from: index)
        }
        
        for _ in 0..<8-caculate.count {
            caculate = "0" + caculate
        }
        
        //如果是负数位移那么要对二进制数取反然后+1
        if value < 0 {
            let becomeTwo = caculate.replacingOccurrences(of:"1", with: "2")
            let becomeOne = becomeTwo.replacingOccurrences(of:"0", with: "1")
            caculate = becomeOne.replacingOccurrences(of:"2", with: "0")
            if caculate.last == "0" {
                let index = caculate.index(caculate.startIndex, offsetBy: caculate.count - 1)
                caculate = String(caculate[..<index]) + "1"
            }else{
                let index = caculate.index(caculate.startIndex, offsetBy: caculate.count - 2)
                caculate = String(caculate[..<index]) + "10"
            }
            
        }
        for _ in 0..<bit {
            caculate = "0" + caculate
            
        }
        let index = caculate.index(caculate.startIndex, offsetBy:8)
        caculate = String(caculate[..<index])
        let myResult = Int32.init(caculate, radix:2)
        return Int(myResult ?? 0)
    }
    
    func fromb64(var0:String) throws -> [Int8] {
        let var0Array = stringToArray(input: var0)
        let var1 = var0.count
        var var2 = [Int8](repeating: 0, count: var1 + 1)
        var var4:Int = 0
        var var5:Int = 0
        if (var1 == 0) {
            fatalError("The String is Nil")
        } else {
            for var4 in var4..<var1 {
                let var3 :String = var0Array[var4] as! String
                
                while var3 != TABLE[var5] as! String {
                    var5 = var5 + 1
                }
                var2[var4] = Int8(var5)
                var5 = 0
            }
            
            var4 = var1 - 1
            var5 = var1
            
            repeat {
                var2[var5] = var2[var4]
                var4 = var4 - 1
                if (var4 < 0) {
                    break
                }
                
                var2[var5] = Int8((var2[var5]  | (var2[var4] & 3) << 6))
                var5 = var5 - 1
                var2[var5] = Int8(relizeRight(value: (Int)(var2[var4] & 60), bit: 2))
                var4 = var4 - 1
                if (var4 < 0) {
                    break;
                }
                
                var2[var5] = Int8(var2[var5] | (var2[var4] & 15) << 4)
                var5 = var5 - 1
                var2[var5] = Int8(relizeRight(value: (Int(var2[var4] & 48)), bit: 4))
                var4 = var4 - 1
                if (var4 < 0) {
                    break;
                }
                
                var2[var5] = Int8(var2[var5] | var2[var4] << 2)
                var2[var5 - 1] = 0;
                var5 = var5 - 1
                var4 = var4 - 1
            } while(var4 >= 0)
            
            while var2[var5] == 0 {
                var5 = var5 + 1
            }
            
            var var6 = [Int8](repeating: 0, count: var1 - var5 + 1)
            let i = 0
            for i in i..<var1 - var5 + 1{
                var6[i] = var2[var5 + i]
            }
            return var6
        }
    }
    
    // string转bigint
    func stringToBigInt(str:String) -> BigInt {
        let array  = try! fromb64(var0: str)
        let data = NSData(bytes: array, length: array.count)
        let sBigInt = doneInNU(value: BigInt.init(data as Data))
        return sBigInt
    }
    
    // string转data
    func stringToData(str:String) -> Data {
        let array  = try! fromb64(var0: str)
        let data = NSData(bytes: array, length: array.count)
        return data as Data
    }
    
    // 计算校验的 H
    func calculate_H(algorithm: Digest.Algorithm,A: Data, M: Data, K: Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        return BigInt(H(A + M + K))
    }
    
    //M1 = H(H(N) XOR H(g) | H(I) | s | A | B | K)
    func calculate_M(algorithm: Digest.Algorithm, username: Data, salt: Data, A: Data, B: Data, K: Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        let Ndata = H(N.serialize())
        let gData = H(g.serialize())
        let HI = H(username)
        let nxorg = xor(var0: Ndata, var1: gData, var2: 20)
        let hashM = Digest.hasher(algorithm)
        return BigInt(hashM(nxorg + HI + salt + A + B + K))
    }
    
    func xor(var0:Data,var1:Data,var2:Int) -> Data {
        var var3 = [UInt8](repeating: 0, count: var2)
        let var4 = 0
        for var4 in var4..<var2{
            var3[var4] = UInt8(var0[var4] ^ var1[var4])
        }
        
        let data = NSData(bytes: var3, length: var3.count)
        return data as Data
    }
    
    // 计算x x = hash(salt + p)
    func calculate_x(algorithm: Digest.Algorithm,salt:Data,password:Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        return BigInt(H(salt+password))
    }
    
    // 计算u u = hash(a+b)
    func calculate_u(algorithm: Digest.Algorithm,A:Data,B:Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        return BigInt(H(A+B))
    }
    
    // 计算v v = g^x % n
    func calculate_v(x: BigInt) -> BigInt {
        return g.power(x, modulus: N)
    }
    
    /**
     *   base64编码
     */
    func base64Encoding(str:String)->String{
        let strData = str.data(using: String.Encoding.utf8)
        let base64String = strData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String ?? ""
    }
    
    /**
     *   base64解码
     */
    func base64Decoding(encodedStr:String)->String{
        let decodedData = NSData(base64Encoded: encodedStr, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
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


extension BigInt {
    
    public func serialize() -> Data {
        var array = Array(BigUInt.init(self.magnitude).serialize())
        
        if array.count > 0 {
            if self.sign == BigInt.Sign.plus {
                if array[0] >= 128 {
                    array.insert(0, at: 0)
                }
            } else if self.sign == BigInt.Sign.minus {
                if array[0] <= 127 {
                    array.insert(255, at: 0)
                }
            }
        }
        
        return Data.init(bytes: array)
    }
    
    public init(_ data: Data) {
        var dataArray = Array(data)
        var sign: BigInt.Sign = BigInt.Sign.plus
        var magnitude :BigUInt = 0
        
        if dataArray.count > 0 {
            if dataArray[0] >= 128 {
                sign = BigInt.Sign.minus
                magnitude = BigUInt.init(Data.init(bytes: dataArray))
                let flag :BigUInt = BigUInt(BigUInt(2) << BigUInt((data.count * 8) - 1))
                magnitude = flag - magnitude
                if dataArray.count > 1 {
                    if dataArray[0] == 255, dataArray.count > 1 {
                        dataArray.remove(at: 0)
                    }
                }
            }else{
                magnitude = BigUInt.init(Data.init(bytes: dataArray))
            }
        }
        self .init(sign: sign, magnitude: magnitude)
    }
}

extension Digest {
    static func hasher(_ algorithm: Algorithm) -> (Data) -> Data {
        return { data in
            let digest = Digest(using: algorithm)
            _ = digest.update(data: data)
            return Data(bytes: digest.final())
        }
    }
}

// 常量
// UserDefault
let uIsLogin = "isLogin"
let utoken = "TTAItoken"
let uSDKSRP = "TTAISdkSrpS"
let uStableParam = "TTAIStableParam"
let uChangeParam = "TTAIChangeParam"
