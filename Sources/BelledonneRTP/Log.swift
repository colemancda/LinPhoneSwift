//
//  Log.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/22/17.
//
//

import CBelledonneRTP.logging
import CBelledonneRTP.port

public struct Log {
    
    // MARK: - Static Properties
    
    /// Tell oRTP the id of the thread used to output the logs.
    /// This is meant to output all the logs from the same thread to prevent deadlock problems at the application level.
    public static var threadIdentifier: UInt {
        
        @inline(__always)
        get { return __ortp_thread_self() }
        
        @inline(__always)
        set { ortp_set_log_thread_id(newValue) }
    }
    
    // MARK: - Static Methods
    
    /// Flushes the log output queue.
    /// 
    /// - Warning: Must be called from the thread that has been defined with `threadIdentifier`.
    @inline(__always)
    public static func flush() {
        
        ortp_logv_flush()
    }
}

// MARK: - Supporting Types

public extension Log {
    
    public enum Level {
        
        case debug
        
        case trace
        
        case message
        
        case warning
        
        case error
        
        case fatal
        
        public static let all: Set<Log.Level> = [.debug, .trace, .message, .warning, .error, .fatal]
    }
}

extension Log.Level: Equatable {
    
    @inline(__always)
    public static func == (lhs: Log.Level, rhs: Log.Level) -> Bool {
        
        return lhs.ortpLevel.rawValue == rhs.ortpLevel.rawValue
    }
}

extension Log.Level: Hashable {
    
    public var hashValue: Int {
        
        @inline(__always)
        get { return ortpLevel.rawValue.hashValue }
    }
}

public extension Log.Level {
    
    public init?(_ ortpLevel: OrtpLogLevel) {
        
        switch ortpLevel {
        case ORTP_DEBUG: self = .debug
        case ORTP_TRACE: self = .trace
        case ORTP_MESSAGE: self = .message
        case ORTP_WARNING: self = .warning
        case ORTP_ERROR: self = .error
        case ORTP_FATAL: self = .fatal
        default: return nil
        }
    }
    
    public var ortpLevel: OrtpLogLevel {
        
        switch self {
        case .debug: return ORTP_DEBUG
        case .trace: return ORTP_TRACE
        case .message: return ORTP_MESSAGE
        case .warning: return ORTP_WARNING
        case .error: return ORTP_ERROR
        case .fatal: return ORTP_FATAL
        }
    }
    
    public static func ortpLevelMask(from levels: Set<Log.Level>) -> OrtpLogLevel.RawValue {
        
        return levels
            .map({ $0.ortpLevel.rawValue })
            .reduce(0, { $0 | $1 })
    }
}
