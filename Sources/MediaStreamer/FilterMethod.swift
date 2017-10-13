//
//  FilterMethod.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 9/6/17.
//
//

import CMediaStreamer2

public extension Filter {
    
    public enum Method {
        
        case getVideoSize((Filter) -> MSVideoSize)
        case setVideoSize((Filter, MSVideoSize) -> ())
    }
}

internal extension Filter.Method {
    
    var id: FilterMethodIdentifier {
        
        switch self {
        case .getVideoSize(_): return FilterMethodIdentifier() //.getVideoSize // TODO: FIXME
        case .setVideoSize(_): return FilterMethodIdentifier() //.setVideoSize
        }
    }
    
    var function: MSFilterMethodFunc {
        
        switch self {
        case .getVideoSize(_): return FilterGetVideoSize
        case .setVideoSize(_): return FilterSetVideoSize
        }
    }
}

// MARK: - Supporting Types

internal extension Filter.Description {
    
    final class Methods {
        
        typealias Element = Filter.Method
        
        typealias Buffer = UnsafeMutablePointer<MSFilterMethod>
        
        let buffer: Buffer?
        
        let size: Int
        
        let elements: [Filter.Method]
        
        deinit {
            
            if let buffer = self.buffer {
                
                buffer.deinitialize(count: size)
                buffer.deallocate(capacity: size)
            }
        }
        
        init(_ elements: [Filter.Method]) {
            
            self.elements = elements
            
            if elements.isEmpty {
                
                self.size = 0
                self.buffer = nil
                
            } else {
                
                // allocate array
                self.size = elements.count + 1 // null terminated array
                let buffer = Buffer.allocate(capacity: size)
                buffer.initialize(to: MSFilterMethod(), count: size)
                
                // set buffer contents
                for (index, method) in elements.enumerated() {
                    
                    buffer[index] = MSFilterMethod(id: method.id.rawValue, method: method.function)
                }
                
                self.buffer = buffer
            }
        }
    }
}

extension Filter.Description.Methods: ExpressibleByArrayLiteral {
    
    convenience init(arrayLiteral elements: Element...) {
        
        self.init(elements)
    }
}

// MARK: - Private Function

private extension Filter.Method {
    
    typealias Status = Int32
    
    typealias Argument = UnsafeMutableRawPointer
}

private func FilterGetVideoSize(_ rawPointer: Filter.RawPointer?, _ arg: Filter.Method.Argument?) -> Filter.Method.Status {
    
    guard let rawPointer = rawPointer,
        let filter = Filter.from(rawPointer: rawPointer),
        let description = filter.description,
        let arg = arg
        else { return .error }
    
    for method in description.methods {
        
        guard case let .getVideoSize(body) = method
            else { continue }
        
        let videoSize = arg.assumingMemoryBound(to: MSVideoSize.self)
        
        videoSize.pointee = body(filter)
        
        return .success
    }
    
    return .error
}

private func FilterSetVideoSize(_ rawPointer: Filter.RawPointer?, _ arg: Filter.Method.Argument?) -> Filter.Method.Status {
    
    guard let rawPointer = rawPointer,
        let filter = Filter.from(rawPointer: rawPointer),
        let description = filter.description,
        let arg = arg
        else { return .error }
    
    for method in description.methods {
        
        guard case let .setVideoSize(body) = method
            else { continue }
        
        let videoSize = arg.assumingMemoryBound(to: MSVideoSize.self).pointee
        
        body(filter, videoSize)
        
        return .success
    }
    
    return .error
}
