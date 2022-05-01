import Cocoa
import OpenDirectory

//class Contact: ObservableObject {
//    @Published var name: String
//    @Published var age: Int
//
//    init(name: String, age: Int) {
//        self.name = name
//        self.age = age
//    }
//
//    func haveBirthday() -> Int {
//        age += 1
//        return age
//    }
//}
//
//let john = Contact(name: "John Appleseed", age: 24)
//let cancellable = john.objectWillChange
//    .sink { _ in
//        print("\(john.age) will change")
//}
//
//print(john.haveBirthday())
//print(john.haveBirthday())
//cancellable.cancel()
//print(john.haveBirthday())


var m = [String]()
m.removeFirst()

var greeting = "Hello, playground"

let shortName = "bastard"
let localNode = try ODNode.init(session: ODSession.default(), type: ODNodeType(kODNodeTypeLocalNodes))
let query = try ODQuery.init(node: localNode,
                             forRecordTypes: kODRecordTypeUsers,
                             attribute: kODAttributeTypeRecordName,
                             matchType: ODMatchType(kODMatchEqualTo),
                             queryValues: shortName,
                             returnAttributes: kODAttributeTypeAllAttributes,
                             maximumResults: 0)

let kODAttributeADUser = "dsAttrTypeStandard:ADUser"

let records = try query.resultsAllowingPartial(false) as! [ODRecord]
if let record = records.first {
    print(record)
    print(try? record.values(forAttribute: kODAttributeTypeRecordName))
    print(try? record.values(forAttribute: kODAttributeTypePassword))
    print(try? record.values(forAttribute: kODAttributeTypeFullName))
    print(try? record.values(forAttribute: kODAttributeADUser))
    print(try? record.values(forAttribute: kODAttributeTypeNFSHomeDirectory))
    
}

//public func isLocalPasswordValid(userName: String, userPass: String) throws -> Bool {
//    do {
//        let userRecord = try getLocalRecord(userName)
//        try userRecord.verifyPassword(userPass)
//    } catch {
//        let castError = error as NSError
//        switch castError.code {
//        case Int(kODErrorCredentialsInvalid.rawValue):
//            os_log("Tested password for user account: %{public}@ is not valid.", type: .default, userName)
//            return false
//        default:
//            throw error
//        }
//    }
//    return true
//}

func getEFIUUID() ->String? {

    let chosen = IORegistryEntryFromPath(kIOMasterPortDefault, "IODeviceTree:/chosen")
    var properties : Unmanaged<CFMutableDictionary>?
    let err = IORegistryEntryCreateCFProperties(chosen, &properties, kCFAllocatorDefault, IOOptionBits.init(bitPattern: 0))

    if err != 0 {
        print(err)
        return nil
    }

    guard let props = properties!.takeRetainedValue() as? [ String : AnyHashable ] else { return nil }
    print(props)
    
    guard let uuid = props["apfs-preboot-uuid"] as? Data else { return nil }
    return String.init(data: uuid, encoding: String.Encoding.utf8)
    
}

print(getEFIUUID()!)

let ws = NSWorkspace.shared

var description: NSString?
var type: NSString?

let err = ws.getFileSystemInfo(forPath: "/", isRemovable: nil, isWritable: nil, isUnmountable: nil, description: &description, type: &type)

print(type)
print(description)
