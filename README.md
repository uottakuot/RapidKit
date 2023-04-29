# RapidKit

RapidKit is designed to make iOS app development and support faster and  easier.

- It includes several frameworks
  - **Foundation** provides some useful extensions of *Apple Foundation* types
  - **Data** helps to create ORM model based on underlying *Apple Core Data* database
  - **Network** combines requests and response parsers in one
  - **Security** wraps keychain
  - **Touch** extends UIKit classes with one-method-without-delegate table presentation, skin support, activity HUD, and some other additions

- Use folowing commands to import frameworks

    ```swift
    import RapidFoundation
    import RapidNetwork
    import RapidSecurity
    import RapidTouch
    ```

## Foundation

- Obj-C runtime wrappers help to extend existing Obj-C classes and add new functionality to instances at runtime

    ```swift
    enum Properties {
        static var newProperty = "newProperty"
    }
    
    let nsObject = ...
    
    nsObject.setValue("some_value", associatedWithKey: &Properties.newProperty)
    
    let value = nsObject.value(associatedWithKey: &Properties.newProperty)
    ```

    ```swift
    @objc
    var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            super.isSelected = newValue
            
            print("Button's selected state has been changed")
        }
    }
    
    let button = UIButton()
    button.setClass(withPrefix: "MyPrefix", suffix: "UIKitAdditions") { subclass in
        subclass.replaceInstanceMethodImplementation(for: #selector(setter: isSelected), with: #selector(setter: isSelected))
    }
    ```

- Obj-C style synchronization locks

    ```swift
    synchronize(self) {
        // ...
    }
    ```

- Catching Obj-C exceptions

    ```swift
    try tryObjC {
        // ...
    }
    ```

- `NSObject` wrapper

    ```swift
    let wrapper = NSObjectWrapper(someObject)
    ```

- Error type with multiple error codes

    ```swift
    extension CodeError.Code {
        static let myError1 = Self(1001)
        
        static let myError2 = Self(1002)
    }
    
    let error = CodeError(codes: [.myError1, .myError2])
    ```

- Useful methods for arrays and JSON dictionaries
    ```swift
    let element = someArray.element(before: someObject, inCycle: true)
    ```
    
    ```swift
    let dict: JSONDictionary = [
        "stringVal": "value1",
        "floatVal": 10.5,
        "numberInStringVal": "10"
    ]
    
    let stringValue = dict.string(forKey: "stringVal")
    
    let floatValue = dict.float(forKey: "floatVal")
    
    let intValue = dict.integer(forKey: "numberInStringVal")
    ```

- `Copyable` protocol

    ```swift
    class MyClass: Copyable {
        static func copy(_ source: MyClass, to destination: MyClass) {
            // ...
        }
        
        required init() {
            //
        }
        
        func copy() -> Self {
            let copy = Self.init()
            Self.copy(self, to: copy)
            return copy
        }
    }
    ```

- `Codable` protocol support in `UserDefaults`

    ```swift
    struct User: Codable {
        ...
    }
    
    let userToSave: User = ...
    UserDefaults.standard.setCodable(user, forKey: "user")
    
    let savedUser = UserDefaults.standard.codable(forKey: "user", type: User.self)
    ```

- MIME-type enumeration

## Data

- Objective-C framework
- Maps your DOM entities to Core Data objects automatically (you just need to initialize `DIEntityStorage` with `DIEntityStorageTypeCoreData` and inherit your classes from `DIEntity`)
- To add object to the database, call `[aStorage registerObject:anObject]`
- Everything else, including creating, configuring and updating database whenever your model is changed, is done automatically
- Search requests `[DIEntityStorage objectsWithPredicate:class:]` return instances of your own model types

    ```objc
    @interface Entity : RKEntity
    
    @property (nonatomic, strong) UID* name;
    @property (nonatomic, strong) NSString* name;
    @property (nonatomic, strong) NSString* comment;
    @property (nonatomic, strong) NSDate* creationDate;
    
    @end
    
    @interface Journal : Entity
    
    @property (nonatomic, strong, readonly) NSArray* notes;
    
    - (void)addNote:(Note*)note;
    - (void)removeNote:(Note*)note;
    
    @end
    
    @interface Note : Entity
    
    @property (nonatomic) NSInteger orderIndex;
    @property (nonatomic, weak, readonly) Journal* journal;
    
    @end
    ```

    ```objc
    [RKEntity registerRelationshipForClass:[Journal class] propertyName:@"notes" withClass:[Note class] propertyName:@"journal" firstDeleteRule:RKEntityDeleteRuleNullify secondDeleteRule:RKEntityDeleteRuleCascade modifier:RKEntityModifierOneToMany];
    
    RKEntityStorageOptions* options = [[RKEntityStorageOptions alloc] init];
    [options setEntityClasses:@[[Journal class], [Note class]]];
    [options setIndexedPropertyNames:@[@"UID", @"name"] forClass:[Journal class]];
    [options setIndexedPropertyNames:@[@"UID", @"name"] forClass:[Note class]];
    [options setEntityName:@"Journal" forClass:[Journal class]];
    [options setEntityName:@"Note" forClass:[Note class]];
    
    NSURL* fileURL = ...;
    RKEntityStorage* storage = [[RKEntityStorage alloc] initWithURL:fileURL type:RKEntityStorageTypeCoreData options:options];
    [storage setDelegate:self];
    [storage setPropertyNamesForNotifications:@[@"UID"]];
    [storage save];
    ```
    
    >This framework has been tested only in Obj-C-based apps.

## Security

- Keychain wrapper

    ```swift
    Keychain.shared.set(someData, forKey: "data")
    
    let data = Keychain.shared.data(forKey: "data")
    ```

## Network

- Network class with built-in reachability, request methods, logging

    ```swift
    var configuration = Network.Configuration(baseURL: "https://server_path")
    configuration.httpMaximumConnectionsPerHost = 6
    
    network = Network(configuration: configuration)
    network.logging = .verbose
    network.delegate = self
    
    Network.startMonitoringReachability();
    ```

- Request structure used in combination with response parser
- Base parser implementations including JSON parser

    ```swift
    extension Network {
        class UserResponseParser: JSONDictionaryResponseParser {
            private(set) var user: User?
            
            override func parse(_ data: JSONDictionary) throws {
                // parse data to a new User instance
            }
        }
        
        func user() -> Request<UserResponseParser> {
            return Request(url: configuration.serverURL, path: "user/me", method: .get, responseParser: UserResponseParser())
        }
    }
    ```

    ```swift
    let request = network.user()
    
    network.execute(request) { parser, error in
        if let error = error {
            print(error)
        } else if let user = parser.user {
            print(user)
        }
    }
    ```

## Touch

- Base view controller with "no data" labels and some useful methods for further overriding

    ```swift
    class MyViewController: BaseViewController {
        override var noDataInfo: String? {
            return "No data here"
        }
        
        override func reloadData(completion: (() -> Void)? = nil) {
            // load data for this controller
            
            setNeedsRefreshView()
            
            completion?()
        }
    }
    ```

- Base table view controller that lets you create a table presentation in one method instead of several delegate's methods

    ```swift
    override func refreshView(animated: Bool = false) {
        removeAllCellSources()
        
        var source: TableViewCellSource
        
        addCellSource(emptyCellSource(withRowHeight: 40))
        
        source = TableViewCellSource(contentView: statusImageView)
        source.usesContentViewHeight = true
        source.cellSkin = .cell
        addCellSource(source)
        
        addCellSource(emptyCellSource(withRowHeight: 40))
        
        let description = ...
        source = cellSource(text: description, textSkin: .textBig1Semibold)
        source.didCreateCell = { info in
            info.cell?.textLabel?.textAlignment = .center
        }
        addCellSource(source)
        
        addCellSource(emptyCellSource())
        
        addCellSource(flexibleEmptyCellSource())
        
        addCellSource(cellSource(withButton: actionButton))
        
        addCellSource(emptyCellSource(withRowHeight: 30))
        
        reloadTable(animated: animated)
    }
    
    func emptyCellSource(withRowHeight rowHeight: CGFloat = 20, cellSkin: Skin = .cell) -> TableViewCellSource {
        let source = TableViewCellSource()
        source.rowHeight = rowHeight
        source.cellSkin = cellSkin
        
        return source
    }
    
    func flexibleEmptyCellSource(cellSkin: Skin = .cell) -> TableViewCellSource {
        let source = TableViewCellSource()
        source.willCalculateHeight = dynamicHeightCalculation()
        source.cellSkin = cellSkin
        
        return source
    }
    
    func cellSource(withButton button: UIButton, cellSkin: Skin = .cell) -> TableViewCellSource {
        let source = TableViewCellSource(contentView: button)
        source.contentViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        source.rowHeight = 50
        source.cellSkin = cellSkin
        
        return source
    }
    
    func cellSource(text: String?, textSkin: TextSkin = .text) -> TableViewCellSource {
        let source = TableViewCellSource()
        source.text = text
        source.cellSkin = .cellTransparent
        source.textSkin = textSkin
        source.willCalculateHeight = { info in
            let constraints = CGSize(width: info.controller.tableView!.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
            if let textHeight = info.cellSource.text?.boundingRect(with: constraints, skin: info.cellSource.textSkin).size.height {
                info.cellSource.rowHeight = textHeight
            }
        }
        
        return source
    }
    ```

- Flexible approach to adjust appearance of UIKit controls

    ```swift
    extension Skin {
        static let navigationBar: NavigationBarSkin = {
            let skin = NavigationBarSkin()
            
            skin.backgroundColors[.normal] = .white
            skin.contentTintColor = .blue
            skin.backIndicatorImage = UIImage(named: "back_indicator")
            skin.backIndicatorTransitionMaskImage = skin.backIndicatorImage
            skin.isTranslucent = false
            skin.borderWidth = 0.5
            skin.hidesSystemBottomLine = true
            skin.prefersLargeTitle = true
            skin.titleSkin = textSkin(withSize: 18, weight: .semibold)
            
            if #available(iOS 13.0, *) {
                skin.statusBarStyle = .darkContent
            } else {
                skin.statusBarStyle = .default
            }
            
            return skin
        }()
        
        static let defaultButton: ButtonSkin = {
            let skin = ButtonSkin()
            skin.backgroundColors[.normal] = .clear
            skin.backgroundColors[.highlighted] = .darkGray
            skin.borderColors[.normal] = .darkGray
            skin.borderWidth = 2
            skin.cornerRadius = .greatestFiniteMagnitude
            skin.titleSkin = textSkin(withSize: 16, weight: .medium, highlightedColor: .white)
            return skin
        }()
        
        /*
            Other skins:
            - Skin for any UIView
            - TextSkin for UILabel or UITextField
            - TableSkin for UITableView
            - SwitchSkin for UISwitch
        */
        
        class func textSkin(withSize size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = .darkGray, highlightedColor: UIColor? = nil, selectedColor: UIColor? = nil) -> TextSkin {
            let skin = TextSkin()
            skin.font = .systemFont(ofSize: size, weight: weight)
            skin.textColors[.normal] = color
            skin.textColors[.highlighted] = highlightedColor
            skin.textColors[.selected] = selectedColor
            return skin
        }
    }
    ```

    ```swift
    let navBar = ...
    navBar.skin = .navigationBar
    
    let button = ...
    button.skin = .defaultButton
    ```

- Activity HUD

    ```swift
    let viewController: UIViewController = ...
    viewController.showActivity("Loading...")
    ...
    viewController.hideActivity()
    ```

- NIB loader

    ```swift
    let view = NibLoader.loadViewWithNib(named: "SomeView")
    ```

- Creating `UIColor` from integer

    ```swift
    let color = UIColor(value: 0xFF00FF, alpha: 0.5)
    ```

- Various extensions for system controls

    ```swift
    let textField: UITextField = ...
    textField.textInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    let button: UIButton = ...
    button.setBorderColor(.black, for: .highlighted)
    button.setBackgroundColor(.white, for: .highlighted)
    ```

### How do I get set up?

- Clone sources
- Build frameworks you need or add RapidKit project into your project
- Change [Framework Sources]/Configurations/*.xcconfig if necessary

### License

RapidKit is published under MIT license.
