import Foundation

private func escape(string: String) -> String {
    return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue) as String
}

private func unescape(string: String) -> String {
    return CFURLCreateStringByReplacingPercentEscapes(nil, string, nil) as String
}

public class URLEncodedSerialization {
    public enum Error: ErrorType {
        case CannotGetStringFromData
        case CannotGetDataFromString
        case CannotCastObjectToDictionary
        case InvalidFormatString
    }

    public class func objectFromData(data: NSData, encoding: NSStringEncoding) throws -> [String: String] {
        guard let string = NSString(data: data, encoding: encoding) as? String else {
            throw Error.CannotGetStringFromData
        }

        var dictionary = [String: String]()
        for pair in string.componentsSeparatedByString("&") {
            let contents = pair.componentsSeparatedByString("=")

            guard contents.count == 2 else {
                throw Error.InvalidFormatString
            }

            dictionary[contents[0]] = unescape(contents[1])
        }

        return dictionary
    }
    
    public class func dataFromObject(object: AnyObject, encoding: NSStringEncoding) throws -> NSData {
        let string = try stringFromObject(object, encoding: encoding)
        guard let data = string.dataUsingEncoding(encoding, allowLossyConversion: false) else {
            throw Error.CannotGetDataFromString
        }

        return data
    }
    
    public class func stringFromObject(object: AnyObject, encoding: NSStringEncoding) throws -> String {
        guard let dictionary = object as? [String: AnyObject] else {
            throw Error.CannotCastObjectToDictionary
        }

        var pairs = [String]()
        for (key, value) in dictionary {
            let valueAsString = (value as? String) ?? "\(value)"
            let pair = "\(key)=\(escape(valueAsString))"
            pairs.append(pair)
        }

        return "&".join(pairs)
    }
}
