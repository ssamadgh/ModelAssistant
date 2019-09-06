# Usage

- [Preparation](#preparation)
- [Interaction](#interaction)

## Preparation

The preparation of **ModelAssistant** has three steps:

1. [Preparing Model Object](#preparing-model-object)
2. [Preparing View](#preparing-view)
3. [Preparing Delegate](#preparing-delegate)

### Preparing Model Object

For compatibility of your model objects with ModelAssistant you must adopt them to **MAEntity** and **Hashable** protocols. Suppose you have a model struct named Contact. Your Contact struct should be like this:

```swift
struct Contact: MAEntity & Hashable {
    //...
}
```

Now Contact struct must satisfy MAEntity protocol requirements.

```swift
struct  Contacte: MAEntity & Hashable {

    typealias UniqueValue = <#type#>
    
    var uniqueValue: UniqueValue

    subscript(key: String) -> String? {

    }

    mutating func update(with newFetechedEntity: MAEntity) {

    }

}
```

#### uniqueValue

uniqueValue returns a Generic `Hashable` value that is unique for each of entities in ModelAssistant.
It could be a `String`, `Int`, `UUID`, etc. For here if Contact struct be like this:

```swift
struct  Contacte: MAEntity & Hashable {
    
    let firstName: String
    let lastName: String
    let phoneNumber: String

    //...
}
```

The uniqueValue can be set this way:

```swift
var uniqueValue: String {
    return self.phoneNumber
}
```



#### subscript(key: String) -> String?

This subscript is used to divide entities into multiple sections by ModelAssistant. So into this subscript braces, you should return the string value you expect, for the section key you gave to ModelAssistant instance.
For example, suppose we want to grouping the contacts by the last names. So we instantiate ModelAssistant:

```swift
let assistant = ModelAssistant<Contact>(sectionKey: "lastName")
```

Then in subscript we return lastName property of Contact this way:

```swift
    subscript(key: String) -> String? {

        if key == "lastName" {
            return self.lastName
        }

        return nil
    }
```

Or for a wider range of entities to have in each section, we can configure return value like this:

```swift
    subscript(key: String) -> String? {

        if key == "lastName" {
            return String(Array(self.lastName)[0]).uppercased()
        }

        return nil
    }
```

This subscript returns uppercased first letter of last name for each contact, so ModelAssistant groups contacts with the uppercased first letter of last names.

Reutrn nil in this subscript if you do not want to use multiple sections.

#### func update(with newFetechedEntity: MAEntity)

This method is used with ModelAssistant to update an existent entity with the new fetched entity that is equal to this existing entity. With this method you decide wich of the entity properties to be update with new fetched entity. This method is useful when you want to update the existent entities with the new fetched ones, instead of reload them. For example for Contact entities we want to update just firstName and lastName:

```swift
    func update(with newFetechedEntity: MAEntity) {
        let entity = newFetechedEntity as! Contact
        self.firstName = entity.firstName
        self.lastName = entity.lastName
    }
```

leave this method blank, if you do not want to use this feature to update existent entities.

### Preparing View

#### Creating a Model Assistant

Before preparing view you should create an instance of ModelAssistant as an instance variable of your view and configure it. ModelAssistant is a generic class, so you should typecast its generic parameter. This parameter tells to ModelAssistant, for which entity type you use it. For example, for Contact type we create a ModelAssistant instance like this:

```swift
var assistant = ModelAssistant<Contact>!
```

Then we initialize ModelAssistant. This initialization can take place in the [viewDidLoad](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) or [viewWillAppear:](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621510-viewwillappear) methods, or at another logical point in the life cycle of the view controller.

```swift
assistant = ModelAssistant(sectionKey: nil)
assistant.delegate = self
```

The `sectionKey` property is optional, so by setting it to `nil` ModelAssistant gathers all the entities in one section. After the ModelAssistant is initialized, we assign it a delegate. The delegate notifies the view when any changes have occurred to the ModelAssistants entities. Here we set the view as delegate of ModelAssistant. 

Now its time to fetch entities to ModelAssistant. These entities can be from a webservice or a persistent store. In any way all we need is an array of entities and we call `fetch(_:completion:)` method on assistant to retrieve initial entities to ModelAssistant. This method does not notify delegate for the changes of ModelAssistant, so we should update view manually in the completion of this method. In the example below we asked tableView to reload its data:

```swift
        self.assistant.fetch(contacts) {
            self.tableView.reloadData()
        }
```

> At the time we initialize ModelAssistant, the view may not have received the initial information of the model yet. So calling delegate methods may lead to crash. Therefore, at this time we use `fetch(_:completion:)` method wich doesn't notify delegate and update the view manually to notify it get the model initial informations.

#### Integrating the Model Assistant with the View Data Source

After you  initialized model assistant and have data ready to be displayed in the view, you integrate the model assistant with the view data source.
Model Assistant is fully compatible with both of UITableView and UICollectionView. Due to the similarity of these two views, we only show here the tableView integration to model assistant:

```swift
#pragma mark - UITableViewDataSource

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) else {
        fatalError("Wrong cell type dequeued")
    }
    // Set up the cell
    guard let entity = self.assistant[indexPath] else {
        fatalError("Attempt to configure cell without an entity")
    }

    //Populate the cell from the object
    return cell
}

override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.assistant.numberOfSections
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.assistant.numberOfEntites(at: section)
}
```

As shown in each `UITableViewDataSource` method above, the integration with the model assistant is reduced to a single method call that is specifically designed to integrate with the table view data source.

#### Adding Sections

So far you have been working with a table view that has only one section, which represents all of the data that needs to be displayed in the table view. If you are working with a large number of Employee objects, it can be advantageous to divide the table view into multiple sections. Grouping the contacts by first letter of their last names makes the list of contacts more manageable. Without Model Assistant, a table view with multiple sections would involve an array of arrays, or perhaps an even more complicated data structure. With Model Assistant, you make a simple change to the construction of it.

```swift
assistant = ModelAssistant(sectionKey: "lastName")
```

Here we added a section key to ModelAssistant. The ModelAssistant uses this key to break apart the data into multiple sections. On the other hand you should define in the typecasted entity, that what to returns in the result of section key ( See [Preparing model object](#preparing-model-object) ).

For example if we define uppercased first letter of lastname as the reurning value of section key in the Contact, this change causes the ModelAssistant to break the returning Contact instances into multiple sections based on the first letter of the lastname that each Contact instance has. 

### Preparing Delegate

#### Communicating Data Changes to the Table View

In addition to making it significantly easier to integrate your model with the table view data source, ModelAssistant handles the communication with the UITableViewController instance when data changes. To enable this, implement the **ModelAssistantDelegate** protocol:

```swift
#pragma mark - NSFetchedResultsControllerDelegate

func modelAssistantWillChangeContent() {
        self.tableView.beginUpdates()
    }

    func modelAssistantDidChangeContent() {
        self.tableView.endUpdates()
    }

    func modelAssistant<Entity>(didChange entities: [Entity], at indexPaths: [IndexPath]?, for type: ModelAssistantChangeType, newIndexPaths: [IndexPath]?) where Entity : MAEntity, Entity : Hashable {
        switch type {
        case .insert:
            self.tableView.insertRows(at: newIndexPaths!, with: .bottom)

        case .delete:
            self.tableView.deleteRows(at: indexPaths!, with: .top)

        case .move:
            for i in 0..<indexPaths!.count {
                self.tableView.moveRow(at: indexPaths![i], to: newIndexPaths![i])
            }
        case .update:
            let indexPath = indexPaths!.first!
            if let cell = self.tableView.cellForRow(at: indexPath) {
                self.configure(cell, at: indexPath)
            }

        }
    }

    func modelAssistant<Entity>(didChange sectionInfo: SectionInfo<Entity>, atSectionIndex sectionIndex: Int?, for type: ModelAssistantChangeType, newSectionIndex: Int?) where Entity : MAEntity, Entity : Hashable {

        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: newSectionIndex!), with: .bottom)

        case .delete:
            self.tableView.deleteSections(IndexSet(integer: newSectionIndex!), with: .bottom)

        case .move:
            self.tableView.moveSection(sectionIndex!, toSection: newSectionIndex!)

        case .update:
            break
        }
    }
```

Implementing the four protocol methods shown above provides automatic updates to the associated UITableView whenever the underlying data changes.

#### Communicating Data Changes to the Collection View

In the table view with the help of two [beginUpdate()](https://developer.apple.com/documentation/uikit/uitableview/1614908-beginupdates) and [endUpdate()](https://developer.apple.com/documentation/uikit/uitableview/1614890-endupdates) methods, we could implement ModelAssistantDelegate methods to it easily. But there aren't such fancy methods in collection view, instead view updates handled with a new version of those two methods called [performBatchUpdates(_:, completion:)](https://developer.apple.com/documentation/uikit/uicollectionview/1618045-performbatchupdates).
This method uses the advantage of blocks to make multiple changes to the collection view in one single animated operation, as opposed to in several separate animations. This method has been added from the iOS 11 to the tableView and along with that, added a new line to those old methods documentations, wich tells:

> Use the [performBatchUpdates(_:completion:)](https://developer.apple.com/documentation/uikit/uitableview/2887515-performbatchupdates) method instead of this one whenever possible.

So it isn't far away that apple decide to deprecate the old [beginUpdate()](https://developer.apple.com/documentation/uikit/uitableview/1614908-beginupdates) and [endUpdate()](https://developer.apple.com/documentation/uikit/uitableview/1614890-endupdates) methods.
So it would be good if we implement ModelAssistantDelegate methods with this new version of view update method for both of tableView and collectionView. But I do not want to discuss it here. There is a class in sample code of this repository named [ModelAssistantDelegateManager](https://github.com/ssamadgh/ModelAssistant/blob/master/Examples/iOS_Example/iOS_Example/Controller/ModelAssistantDelegateManager.swift), which shows you how to use **performBatchUpdates(_:completion:)** for implementing ModelAssistantDelegate methods. You can use this class for both of collectionView and tableView in your projects.

## Interaction

### Documentation

There is a rich [documentation](https://ssamadgh.github.io/ModelAssistant/) for methods and properties you can use for intercting with model assistant. 

### Examples

In addition there is some really good [examples](https://github.com/ssamadgh/ModelAssistant/tree/master/Examples/iOS_Example) that simply shows you how to use model assistant in your project.
