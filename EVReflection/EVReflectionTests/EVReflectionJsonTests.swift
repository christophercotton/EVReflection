//
//  EVReflectionJsonTests.swift
//
//  Created by Edwin Vermeer on 6/15/15.
//  Copyright (c) 2015 evict. All rights reserved.
//

import XCTest

class User: EVObject {
    var id: Int = 0
    var name: String = ""
    var email: String?
    var company: Company?
    var friends: [User]? = []
    var birthDate: NSDate?
}

class Company: EVObject {
    var name: String = ""
    var address: String?
}

/**
Testing EVReflection for Json
*/
class EVReflectionJsonTests: XCTestCase {
    
    /**
    For now nothing to setUp
    */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject)
    }
    
    /**
    For now nothing to tearDown
    */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    class Account: NSObject { // When using sub objects and/or arrays of sub objects, then change the base class to EVObject
        var id: Int64 = 0
        var name: String = ""
    }
    func testSimpleJson() {
        let json2:String = "{\"id\": 24, \"name\": \"Bob\"}"
        let user = Account(json: json2)
        print("Object from json string: \n\(user)\n\n")

        let json:String = "[{\"id\": 27, \"name\": \"Bob Jefferson\"}, {\"id\": 29, \"name\": \"Jen Jackson\"}]"
        let array = [Account](json: json)
        print("Object array from json string: \n\(array)\n\n")

    }
    
    func testJsonArray() {
        let json:String = "[{\"id\": 27, \"name\": \"Bob Jefferson\"}, {\"id\": 29, \"name\": \"Jen Jackson\"}]"
        //let array:[User] = EVReflection.arrayFromJson(User(), json: json)
        //let array:[User] = User.arrayFromJson(json)
        let array = [User](json: json)
        
        print("Object array from json string: \n\(array)\n\n")
        XCTAssertTrue(array.count == 2, "should have 2 Users")
        XCTAssertTrue(array[0].id == 27, "id should have been set to 27")
        XCTAssertTrue(array[0].name == "Bob Jefferson", "name should have been set to Bob Jefferson")
        XCTAssertTrue(array[1].id == 29, "id should have been set to 29")
        XCTAssertTrue(array[1].name == "Jen Jackson", "name should have been set to Jen Jackson")
        
        let na = [User](json: nil)
        XCTAssertEqual(na, [User](), "A nil json should return an empty array")
    }

    func testJsonUser() {
        let json:String = "{\"id\": 24, \"friends\": {}}"
        let user = User(json: json)
        XCTAssertTrue(user.id == 24, "id should have been set to 24")
        XCTAssertTrue(user.friends?.count == 1, "friends should have 1 user")
        
        let a = EVReflection.dictionaryFromJson(nil)
        XCTAssertEqual(a.count, 0, "Can't create a dictionairy from nil")

        let b = EVReflection.dictionaryFromJson("[{\"asdf\"}")
        XCTAssertEqual(b.count, 0, "Can't create a dictionairy from nonsence")
        
        let c = EVReflection.arrayFromJson(MyEnumFive.OK, json: "[{\"id\": 24}]")
        XCTAssertEqual(c.count, 0, "Can't create a dictionairy for a non NSObject type")

        let d = EVReflection.arrayFromJson(User(), json: "[{\"id\": 24}")
        XCTAssertEqual(d.count, 0, "Can't create a dictionairy for invalid json")

        let e = EVReflection.arrayFromJson(User(), json: "")
        XCTAssertEqual(e.count, 0, "Can't create a dictionairy for invalid json")
    }

    enum MyEnumFive: Int {
        case NotOK = 0
        case OK = 1
    }

    func testJsonObject(){
        let jsonDictOriginal = [
            "id": 24,
            "name": "John Appleseed",
            "email": "john@appleseed.com",
            "birthDate": NSDate(),
            "company": [
                "name": "Apple",
                "address": "1 Infinite Loop, Cupertino, CA"
            ],
            "friends": [
                ["id": 27, "name": "Bob Jefferson"],
                ["id": 29, "name": "Jen Jackson"]
            ]
        ]
        print("Initial dictionary:\n\(jsonDictOriginal)\n\n")
        
        let userOriginal = User(dictionary: jsonDictOriginal)
        validateUser(userOriginal)
        
        let jsonString = userOriginal.toJsonString()
        print("JSON string from dictionary: \n\(jsonString)\n\n")

        let userRegenerated = User(json:jsonString)
        validateUser(userRegenerated)
        
        XCTAssertEqual(userOriginal, userRegenerated, "original should have been the same as regenerated")
    }
    
    func validateUser(user:User) {
        print("Validate user: \n\(user)\n\n")
        XCTAssertTrue(user.id == 24, "id should have been set to 24")
        XCTAssertTrue(user.name == "John Appleseed", "name should have been set to John Appleseed")
        XCTAssertTrue(user.email == "john@appleseed.com", "email should have been set to john@appleseed.com")
        
        XCTAssertNotNil(user.company, "company should not be nil")
        print("company = \(user.company)\n")
        XCTAssertTrue(user.company?.name == "Apple", "company name should have been set to Apple")
        print("company name = \(user.company?.name)\n")
        XCTAssertTrue(user.company?.address == "1 Infinite Loop, Cupertino, CA", "company address should have been set to 1 Infinite Loop, Cupertino, CA")
        
        XCTAssertNotNil(user.friends, "friends should not be nil")
        XCTAssertTrue(user.friends!.count == 2, "friends should have 2 Users")
        
        if user.friends!.count == 2 {
            XCTAssertTrue(user.friends![0].id == 27, "friend 1 id should be 27")
            XCTAssertTrue(user.friends![0].name == "Bob Jefferson", "friend 1 name should be Bob Jefferson")
            XCTAssertTrue(user.friends![1].id == 29, "friend 2 id should be 29")
            XCTAssertTrue(user.friends![1].name == "Jen Jackson", "friend 2 name should be Jen Jackson")
        }
    }

    func testTypeJsonAllString() {
        let json:String = "{\"myString\":\"1\", \"myInt\":\"2\", \"myFloat\":\"2.1\", \"myBool\":\"1\"}"
        let a = TestObject4(json: json)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
        XCTAssertEqual(a.myFloat, 2.1, "myFloat should contain 2.1")
        XCTAssertEqual(a.myBool, true, "myBool should contain true")
    }
    
    func testTypeJson2AllNumeric() {
        let json:String = "{\"myString\":1, \"myInt\":2, \"myFloat\":2.1, \"myBool\":1, \"invalid*character\": \"value\"}"
        let a = TestObject4(json: json)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
        XCTAssertEqual(a.myFloat, 2.1, "myFloat should contain 2.1")
        XCTAssertEqual(a.myBool, true, "myBool should contain true")
        XCTAssertEqual(a.invalid_character, "value", "myBool should contain true")
    }

    func testTypeJsonInvalid() {
        let json:String = "{\"myString\":test, \"myInt\":test, \"myFloat\":test, \"myBool\":false}"
        let a = TestObject4(json: json)
        XCTAssertEqual(a.myString, "", "myString should contain 1")
        XCTAssertEqual(a.myInt, 0, "myInt should contain 0")
        XCTAssertEqual(a.myFloat, 0, "myFloat should contain 2.1")
        XCTAssertEqual(a.myBool, true, "myBool should contain true")
    }

    func testSubObjectMapping() {
        let json:String = "{\"test-objects\":[{\"objectValue\":\"test\"}]}"
        let a = TestObject7(json: json)
        XCTAssertEqual(a.test_objects.count, 1, "test_objects should contain 1")
        XCTAssertEqual(a.test_objects[0].objectValue, "test", "objectValue should have test")
    }
}


