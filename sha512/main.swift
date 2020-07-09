//
//  main.swift
//  sha512
//
//  Created by Brandon Plank on 7/8/20.
//  Copyright © 2020 Brandon Plank. All rights reserved.
//

import Foundation
import CommonCrypto
import MachO

let args = CommandLine.arguments
let numberOfArgs = args.count

func help(){
    print("Usage: \(args[0]) <FilePath>")
}

if numberOfArgs == 1 || numberOfArgs >= 3 {
    help()
    exit(0)
}

struct Sha512 {
    let context = UnsafeMutablePointer<CC_SHA512_CTX>.allocate(capacity:1)

    init() {
        CC_SHA512_Init(context)
    }

    func update(data: Data) {
        data.withUnsafeBytes { (bytes: UnsafePointer<Int8>) -> Void in
            let end = bytes.advanced(by: data.count)
            for f in sequence(first: bytes, next: { $0.advanced(by: Int(CC_LONG.max)) }).prefix(while: { (current) -> Bool in current < end})  {
                _ = CC_SHA512_Update(context, f, CC_LONG(Swift.min(f.distance(to: end), Int(CC_LONG.max))))
            }
        }
    }

    func final() -> Data {
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA512_DIGEST_LENGTH))
        CC_SHA512_Final(&digest, context)

        return Data(bytes: digest)
    }
}

extension Data {
    func sha512() -> Data {
        let s = Sha512()
        s.update(data: self)
        return s.final()
    }
}

extension String {
    func sha512() -> Data {
        return self.data(using: .utf8)!.sha512()
    }
}

func HashFile(_ file: String) -> String{
    let path = "\(file)"
    let url = URL(fileURLWithPath: path)
    let data = try! Data(contentsOf: url)
    let sum = "\(data.sha512().map { String(format: "%02hhx", $0) }.joined())"
    return sum
}
print("Sha512: \(HashFile(args[1]))")

