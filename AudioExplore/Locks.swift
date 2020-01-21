//
//  Locks.swift
//
//  Created by Evan Xie on 2019/3/29.
//

import Foundation
import os.lock

// [Comparison between different locks.](https://www.vincents.cn/2017/03/14/ios-lock/)

public protocol Lockable {
    func lock()
    func unlock()
}

/**
 A `NSLock` wrapped lock. For more information, see [NSLock].
 
 [NSLock]:
 https://developer.apple.com/documentation/foundation/nslock
 
 - Warning: Lock and unlock should be called on the same thread.
 */
public final class Lock: Lockable {
    
    private let internalLock: NSLock
    
    public init() {
        internalLock = NSLock()
    }
    
    public func lock() {
        internalLock.lock()
    }
    
    public func unlock() {
        internalLock.unlock()
    }
}

/**
 A `pthread_mutex_t` wrapped lock. For more information, see [pthread_mutex_lock].
 
 [pthread_mutex_lock]:
 https://manpages.debian.org/stretch/glibc-doc/pthread_mutex_lock.3.en.html
 
 - Warning: Lock and unlock should be called on the same thread.
 */
public final class MutexLock: Lockable {
    
    private var internalLock: pthread_mutex_t
    
    deinit {
        pthread_mutex_destroy(&internalLock)
    }
    
    public init() {
        internalLock = pthread_mutex_t()
        pthread_mutex_init(&internalLock, nil)
    }
    
    public func lock() {
        pthread_mutex_lock(&internalLock)
    }
    
    public func unlock() {
        pthread_mutex_unlock(&internalLock)
    }
}

/**
 A `os_unfair_lock_lock` wrapped lock. For more information, see [os_unfair_lock_lock].
 
 [os_unfair_lock_lock]:
 https://developer.apple.com/documentation/os/1646466-os_unfair_lock_lock?language=objc
 
 - Warning: Lock and unlock should be called on the same thread.
 */
@available(iOS 10.0, *)
public final class UnfairLock: Lockable {
    
    private var internalLock: os_unfair_lock
    
    public init() {
        internalLock = os_unfair_lock()
    }
    
    public func lock() {
        os_unfair_lock_lock(&internalLock)
    }
    
    public func unlock() {
        os_unfair_lock_unlock(&internalLock)
    }
}

/**
 A 'DispatchSemaphore' wrapped locker. `SemaphoreLock` is not a real locker,
 but we can use it as a lock by specifying the value of semaphore as one.
 */
public final class SemaphoreLock: Lockable {
    
    private let internalLock: DispatchSemaphore
    
    public init() {
        internalLock = DispatchSemaphore(value: 1)
    }
    
    public func lock() {
        internalLock.wait()
    }
    
    public func unlock() {
        internalLock.signal()
    }
}

