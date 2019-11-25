//
//  UsageFunction.swift
//  UsageTest
//
//  Created by nakaguchi on 2019/10/30.
//  Copyright © 2019 sis. All rights reserved.
//

import Foundation
import UIKit

protocol UsageFunction {
}
extension UsageFunction {

    func getCPUUsage() -> Float {

        var threadList: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        var threadCount: UInt32 = UInt32(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
        var threadInfo: thread_basic_info = thread_basic_info()

        var result: Int32 = withUnsafeMutablePointer(to: &threadList) {
            $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &threadCount)
            }
        }
        if result != KERN_SUCCESS {
            return 0
        }

        return (0 ..< Int(threadCount)).compactMap { index -> Float? in
            var threadInfoCount: UInt32 = UInt32(THREAD_INFO_MAX)
            result = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threadList[index],
                                UInt32(THREAD_BASIC_INFO),
                                $0,
                                &threadInfoCount)
                }
            }
            if result != KERN_SUCCESS {
                return nil
            }

            let isIdle: Bool = threadInfo.flags == TH_FLAGS_IDLE
            return !isIdle ? (Float(threadInfo.cpu_usage) / Float(TH_USAGE_SCALE)) * 100 : nil
        }.reduce(0, +)
    }

    func getMemoryUsed() -> UInt64? {

        var info: mach_task_basic_info = mach_task_basic_info()
        var count: UInt32 = UInt32(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)

        let result: Int32 = withUnsafeMutablePointer(to: &info) {
            task_info(mach_task_self_,
                      task_flavor_t(MACH_TASK_BASIC_INFO),
                      $0.withMemoryRebound(to: Int32.self, capacity: 1) { pointer in
                        UnsafeMutablePointer<Int32>(pointer)
                      },
                      &count)
        }
        return result == KERN_SUCCESS ? info.resident_size : nil
        //return result == KERN_SUCCESS ? info.resident_size / 1024 / 1024 : nil
    }

    func getDiskSpace(_ type: DiskSpaceType) -> String {

        let byteUnitStringConverted: (Int64) -> String = { size in
            ByteCountFormatter.string(fromByteCount: size, countStyle: ByteCountFormatter.CountStyle.binary)
        }
        switch type {
        case .total:
            return byteUnitStringConverted(totalSpace)
        case .free:
            return byteUnitStringConverted(freeSpace)
        case .used:
            return byteUnitStringConverted(usedSpace)
        }
    }

    var totalSpace: Int64 {

        guard let attributes = systemAttributes,
            let size = (attributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
            else { return 0 }
        return size
    }

    var freeSpace: Int64 {

        guard let attributes = systemAttributes,
            let size = (attributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value
            else { return 0 }
        return size
    }

    var usedSpace: Int64 {

        return totalSpace - freeSpace
    }

    private var systemAttributes: [FileAttributeKey: Any]? {

        return try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
    }
}

enum DiskSpaceType {

    case total
    case free
    case used
}
