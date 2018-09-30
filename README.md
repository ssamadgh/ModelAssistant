# ModelAssistant

### An assistant to manage the interactions between view and model

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ModelAssistant.svg)](https://img.shields.io/cocoapods/v/ModelAssistant.svg)
[![Platform](https://img.shields.io/cocoapods/p/ModelAssistant.svg?style=flat)](https://ssamadgh.github.io/ModelAssistant)
[![Twitter](https://img.shields.io/badge/twitter-@ssamadgh-blue.svg?style=flat)](https://twitter.com/ssamadgh)

ModelAssistant is a mediator between the view and model. This framework is tailored to work in conjunction with views that present collections of objects. 
These views typically expect their data source to present results as a list of sections made up of rows. ModelAssistant can efficiently analyze model objects and categorize them in sections. In addition it updates adopted view to its delegate, based on model objects changes.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md)
	- **Preparation -** [Preparing Model Object](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#preparing-model-object), [Preparing View](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#preparing-view), [Preparing Delegate](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#preparing-delegate)
	- **Interaction -** [Documentation](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#documentation), [Examples](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/Usage.md#examples)
- [Advanced Usage](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md)
	- **MAEntitiy** [Inheritance](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#inheritance), [Hashable](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#hashable)
	- **ModelAssistant** [More Configurations](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#more-configurations), [Export Entities](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#export-entities), [Using with Core Data and Realm](https://github.com/ssamadgh/ModelAssistant/blob/master/Documentation/AdvancedUsage.md#using-with-core-data-and-realm)


## Features
- [x] Inserting / Removing / Ordering / Updating model objects
- [x] Notifies changes to view
- [x] Full compatible with table view and collection view
- [x] Supports Sections
- [x] Supports index titles
- [x] Compatible with Server data source
- [x] Compatible with all kind of persistent stores
- [x] Compatible with all design patterns
- [x] **Easy to use**
- [x] **Thread safe**
- [x] [Complete Documentation](https://ssamadgh.github.io/ModelAssistant/)

## Requirements

- iOS 8.0+ 
- Xcode 8.3+
- Swift 3.1+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ModelAssistant into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'ModelAssistant'
end
```
### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate ModelAssistant into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add ModelAssistant as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/ssamadgh/ModelAssistant.git
  ```

- Open the new `ModelAssistant` folder, and drag the `ModelAssistant.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `ModelAssistant.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `ModelAssistant.xcodeproj` folders each with a `ModelAssistant.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from.

- Select the `ModelAssistant.framework`.


- And that's it!

  > The `ModelAssistant.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.
  

## FAQ

### What is the position of ModelAssistant in design patterns?
ModelAssistant is fully compatible with all kind of design patterns. It doesn't violate them, instead it finds its place and sit there!
As a guide the position of ModelAssistant in some of famous design patterns is as follows:

Design Pattern  | ModelAssistant Position
------------- | -------------
MVC | Controller
MVP  | Presenter
MVVM  | ViewModel
Viper  | Interactor


## Credits

ModelAssistant is owned and maintained by the [Seyed Samad Gholamzadeh](http://ssamadgh@gmail.com). You can follow me on Twitter at [@ssamadgh](https://twitter.com/ssamadgh) for project updates and releases.

## License

ModelAssistant is released under the MIT license. [See LICENSE](https://github.com/ssamadgh/ModelAssistant/blob/master/LICENSE) for details.
