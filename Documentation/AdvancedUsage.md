# Advanced Usage

- [MAEntitiy](#maentitiy)
- [ModelAssistant](#modelassistant)


## MAEntitiy

### Inheritance

You can create a protocol which inherits [MAEntity](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#preparing-model-object) to add further requirements on top of MAEntity requirements.

For example we create an Employee protocol this way:

```swift
prototcol Employee: MAEntity {
	var employeeId: Int
	var company: Company
}
```
Now any model object that you adopt Employee on it, must define a company and an employeeId, and all of these model objects are useable with ModelAssistant.

### Hashable
By adopting entities to [Hashable](https://developer.apple.com/documentation/swift/hashable) protocol, they must satisfy Hashable requirements. Since Hashable inherit [Equatable](https://developer.apple.com/documentation/swift/equatable) protocol, so we should satisfy two requirements. One for Hashabel and other for Equatable.

#### Equatable
Equatable requirement is a method, that checks which properties of two entities should be equal to result equality of entities. By default this method just checks [uniqueValue](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#uniquevalue).
But you can change it if you want to check some other properties of your model objects for equality.

```swift
struct Contact: MAEntity {
	var firstName: String
	var lastName: String
	var phoneNumber: String
	
	static func ==(left: Contact, right: Contact) -> Bool {
		return left.phoneNumber == right. phoneNumber && left.firstName == right.lastName && left.lastName == right.lastName
	}

}
```

Even you can change equality for your custom protocol.

```swift
extension Employee {
		static func ==(left: Self, right: Self) -> Bool {
		return left.uniqueValue == right.uniqueValue && left.employeeId == right.employeeId
	}

}
```

#### Hash Value
Before Swift 4.2 you must satisfy a [hashValue](https://developer.apple.com/documentation/swift/hashable/1540917-hashvalue) property to conform Hashable, which was complex. Swift 4.2 improves this situation by introducing a [hash(into:)](https://developer.apple.com/documentation/swift/hashable/2995575-hash) method (See [Swift 4.2 improves Hashable with a new Hasher struct](https://www.hackingwithswift.com/articles/115/swift-4-2-improves-hashable-with-a-new-hasher-struct) for more information). 

Any way, By default uniqueValue is used to calculate hashValue for all MAEntity conformed entities. But if you want to have your own hash calcuation:

If you are using a swift version lower than 4.2 use hashValue property:

```swift
	var hashValue: Int {
		// return a calculated hash
	}
```

If you are using swift 4.2 or higher, implement this method:

```swift
	func hash(into hasher: inout Hasher) {
		//...
	}
```

## ModelAssistant

### More Configurations

At the time you initialize ModelAssistant instance, you can set more configurations on it. Note that you should set these properties before calling `fetch(_:completion:)` method:

#### Sort Entities
You can configure model assistant to sort entities in a given order, by `setEntities` property:

```swift
assistant.setEntities = {  (entity1, entity2) -> Bool in
	// Some sort algorithm
}
```
> If you changed these property after calling `fetch(_:completion:)` method, you should call `reorderEntities(completion:)` method, to reorder entities with new sort.

#### Filter

You can configure model assistant to constraint given entities with a given condition, by `filter` property:

```swift
assistant.setEntities = {  (entity) -> Bool in
	// Some filter algorithm
}
```
Note that by setting this filter your model assistant just contains the entities that satisfied the filter closure conditions.

> **Warning**: Do not change this property after calling `fetch(_:completion:)` method


#### Sort Sections
You can configure model assistant to sort sections in a given order, by `setSections` property:

```swift
assistant.setEntities = {  (section1, section2) -> Bool in
	// Some sort algorithm
}
```
> - If you do not activate multiple sections on model assistant this property doesn't do anything.

> - If you changed these property after calling `fetch(_:completion:)` method, you should call `reorderSections(completion:)` method, to reorder sections with new sort.


### Export Entities

In some situations you may want to export all the model assistant entities to save them on an external data source. You can do this by using `getAllEntities(sortedBy:)`
method.

```swift
		let entities = self.assistant.getAllEntities(sortedBy: nil)

		JsonService.saveEntities(entities, toURL: url) 

```

### Using with Core Data and Realm
Using ModelAssistant with core data and Realm is very easy. There is a good [example](https://github.com/ssamadgh/ModelAssistant/tree/master/Examples/iOS_Example) about uising model assistant with core data in repository.
