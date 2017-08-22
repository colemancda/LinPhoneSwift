//
//  Log.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/22/17.
//
//

import CBelledonneRTP.logging

public class Log {
    
    
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
    }
}

public extension Log.Level {
    
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
            .reduce(0, { $0.0 | $0.1 })
    }
}
