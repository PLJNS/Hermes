iOS Program Design 
==================

Coding guidelines
-----------------

### Values

1. No data loss
2. No crashes
3. No other bugs
4. Fast performance
5. Developer productivity

### Problem solving

-   Solve the problem. Not less than the problem, but not more than the problem — 
    don’t over-generalize.
-   Always work at the highest level possible, but not higher and certainly 
    not lower.

### Language

-   Swift code should be pure Swift as much as possible: avoid `@objc` except 
    when needed for working with AppKit and other APIs.
    -   Prefer Swift native types over Objective-C types when possible. Because 
        Swift types bridge to Objective-C, you should avoid types like `NSString` 
        and `NSNumber` in favor of `Int` or `String`.

-   Functions should tend to be small. Avoid one-liners that are only used once,
    but one-liners can be okay if the name expresses the intent more clearly
    than the one line *and* the function is used at least twice.

-   Use assertions and preconditions.
    -   Assertions will crash a debug build, preconditions will crash a release build. 
    -   Force-unwrapping of optionals is allowed as a shorthand for a precondition 
        failure, though these should be used sparingly.
    -   `fatalError()` is acceptable as shorthand for a failure that is a developer
        error that should result in crashing a production build, but should be used
        sparingly.

-   Extensions, including private extensions, are preferred, on Cocoa and custom
    types.

-   Use the principle of least privelege for all access control, but also consider
    that code you write should be usable in a seperate target.

### Composition

#### No subclasses

-   Subclassing is inevitable — there’s no way out of subclassing things like 
    `UIView` and `UIViewController`, because that’s how UIKit works.

-   Consider this a hard rule: all classes are `final` unless otherwise specified.

#### Protocols and delegates

-   Protocols, delegates, and extensions (which are also protocol-conforming) 
    are preferred.
    -   Default implementations in protocols are allowed but ever-so-slightly 
        discouraged. 

#### Small objects

-   Giant objects with thousands of lines of code are to be avoided, 
    prefer multiple small objects. 
    -   It’s easier to focus on a small problem, and small objects are easier 
        to maintain and compose with other objects.

-   Don’t break up a larger object arbitrarily just because it’s large. It may be 
    the honest answer (and it may not be). There should be a logic and reason 
    to the smaller objects.

#### Code repetition

-   This policy of no-subclasses can lead to some code repetition, or 
    almost-repetition. In small doses, that’s fine, and is better than the 
    alternatives — which tend to be complexifying.

-   In larger doses some redesign is needed. It is often the case that 
    breaking up the problem into smaller objects (see above) can solve the 
    repetition problem.

### Model objects

-   Model objects are structs until they need to be classes and they are `Codable`.
-   Immutable Swift structs are strongly preferred. 
-   If you are using CoreData, suffix the class name with `ManagedObject`.

### Code organization

-   You should not define multiple public/internal types (ie class, struct, enum) 
    in the same file; each type should have its own file.
-   The following list should be the standard organization of all your Swift 
    files, in this specific order:
    1.  override properties
    2.  `let`
    2.  `var`
    3.  `static` and `class` variables
    4.  `static` and `class` functions
    5.  `init`
    6.  `override` functions
    7.  `instance` functions

-   After the core class, for each protocol you want to conform to, you should 
    create an extension of your class in the same file. The first extension should
    be your private functions.

-   Each section above should be organized by accessibility:
    1.  `open`
    2.  `public`
    3.  `internal`
    4.  `private`

-   All enums should live in their own file, except when they're `private`, and then
    they should be at the top of the file they're used in.
-   If you need to use `MARK` to break up the file, consider first breaking the
    file into multiple files. Avoid `TODO` and `FIXME` unless absolutely 
    necessary.

### Frameworks

-   To be avoided at all costs until absolutely necessary, with the exception of
    UIKit, Foundation, and local development pods.
    -   Dependencies between frameworks should be as minimal as possible.

### User interface

-   Stick to stock elements, since this tends to eliminate bugs and future churn. 
    This isn’t always possible, of course, but any custom work should be the minimum 
    possible. 

-   Your UI should be accessible, and is not done if it is not accessible.

-   Your UI should work on all screen sizes.

-   There are no Storyboards or XIB files – only source.

-   Stack views are not allowed in reusable cells, but are preferred otherwise.

### Notifications and Bindings

-   Key-Value Observing (KVO) is entirely forbidden. KVO is where the crashing 
    bugs live. (The only possible exception to this is when an Apple API requires KVO, 
    which is rare.)
    -   Instead, we use NotificationCenter notifications, and we use Swift’s `didSet` 
        method on accessors.
    -   All notifications must be posted on the main queue.

### Threading

-   Everything happens on the main thread, except those things that can be perfectly 
    isolated, such as parsing an RSS feed or fetching from the database. 
    We use DispatchQueue to run those in the background.
    -   Use `DispatchGroup` with extreme care.

-   Any time a background task with a callback is finished, it must call back on 
    the main queue (except for completely private cases, and then it must be noted 
    in the code).

### Cleanliness

No code that triggers compiler errors or even warnings may be checked in.

No code that writes to the console may be checked in — console spew is not allowed.

### Testing

Write unit tests, especially in the lower-level frameworks, and particularly when fixing a bug.

There is never enough test coverage. There should always be more tests.

### Version Control

Every commit message should begin with a present-tense verb.

### Last Thing

Don’t show off. If your code looks like kindergarten code, then good.

Points are granted for not trying to amass points.

### Really Last Thing

Tabs vs. spaces? Spaces. We had to pick, and we picked spaces.

API design guidelines
---------------------

### Fundamentals

> API
>
> In computer programming, an application programming interface (API) is a set 
> of subroutine definitions, communication protocols, and tools for building 
> software. In general terms, it is a set of clearly defined methods of 
> communication among various components. A good API makes it easier to develop 
> a computer program by providing all the building blocks, which are then put 
> together by the programmer.
>
> – [Wikipedia](https://en.wikipedia.org/wiki/Application_programming_interface)

1. **Clarity**: The API contains all the information a reader needs to 
   understand the program's underlying behavior.
2. **Brevity**: The API does not contain more than the information necessary to 
   understand the program's underlying behavior.
3. **Documentation**: The API has human-readable comments that summarize the 
   program's underlying behavior, which is also clear and brief.
   - Prefer summaries when the documentated code is straightforward to read
     on its own.
   - Perfer in-depth documentation with additional discussion, parameters,
     and symbols when the code is core, complicated, or a "necessary hack."

⛔️
```
extension List {
    public mutating func remove(_ position: Index) -> Element
}

// X variable
let x = /* ... */
employees.remove(x)
```

✅
```
extension List {
    /// Removes the employee at the position passed in and returns it
    public mutating func remove(at position: Index) -> Element
}

let deletedEmployeeIndex = /* ... *
employees.remove(at: deletedEmployeeIndex)
```

### Naming

- Include all the words needed to avoid ambiguity.
- Omit needless words. 

⛔️
```
public mutating func removeElement(_ member: Element) -> Element?
allViews.removeElement(cancel)
```

✅
```
public mutating func remove(_ member: Element) -> Element?
allViews.remove(cancelButton) 
```

- Name variables, parameters, and associated types according to their roles.
    - For all buttons, views, view controllers, etc, suffix their type name
      with their superclass, ex: `cancelButton: UIButton`.
    - For all functions, consider naming them like a grammatical English 
      sentence and according to how they should be interpreted at the call site, 
      ex: `buttonDidTouchUpInsider(_ sender: UIButton)`.

- Compensate for weak type information to clarify a parameter’s role.

### Strive for fluent usage

- Prefer method and function names that make use sites form grammatical English 
  phrases.

  ⛔️
  ```
  x.insert(y, position: z)
  x.subViews(color: y)
  x.nounCapitalize()
  ```

  ✅
  ```
  x.insert(y, at: z)
  x.subViews(havingColor: y) 
  x.capitalizingNouns()
  ```

- Name functions and methods according to their side-effects
    - Mutating: `x.sort`, `x.append(y)`
    - Non-mutating: `z = x.sorted()`, `z = x.appending(y)`

- Uses of Boolean methods and properties should read as assertions about the receiver when the use is nonmutating, e.g. x.isEmpty, line1.intersects(line2).
- Protocols that describe what something is should read as nouns (e.g. Collection).
- Protocols that describe a capability should be named using the suffixes able, ible, or ing (e.g. Equatable, ProgressReporting).
- The names of other types, properties, variables, and constants should read as nouns.

### Use Terminology Well

- Avoid obscure terms if a more common word conveys meaning just as well. Don’t say “epidermis” if “skin” will serve your purpose. Terms of art are an essential communication tool, but should only be used to capture crucial meaning that would otherwise be lost.
- Avoid abbreviations. Abbreviations, especially non-standard ones, are effectively terms-of-art, because understanding depends on correctly translating them into their non-abbreviated forms.
- Embrace precedent. Don’t optimize terms for the total beginner at the expense of conformance to existing culture.

### Conventions

- Prefer methods and properties to free functions. Free functions are used only in special cases:
- Follow case conventions. Names of types and protocols are UpperCamelCase. Everything else is lowerCamelCase.
- Methods can share a base name when they share the same basic meaning or when they operate in distinct domains.

### Parameters

-   Choose parameter names to serve documentation. Even though parameter names do not appear at a function or method’s point of use, they play an important explanatory role.
-   Take advantage of defaulted parameters when it simplifies common uses. Any parameter with a single commonly-used value is a candidate for a default.
-   Prefer to locate parameters with defaults toward the end of the parameter list. Parameters without defaults are usually more essential to the semantics of a method, and provide a stable initial pattern of use where methods are invoked.

### Argument Labels

- Omit all labels when arguments can’t be usefully distinguished, e.g. min(number1, number2), zip(sequence1, sequence2).
- When the first argument forms part of a prepositional phrase, give it an argument label. The argument label should normally begin at the preposition, e.g. x.removeBoxes(havingLength: 12).
- Otherwise, if the first argument forms part of a grammatical phrase, omit its label, appending any preceding words to the base name, e.g. x.addSubview(y)
- Label all other arguments.

Architecture
------------

MVVM, roughly, has the following constraints:

-   Models don't talk to anybody (same as MVC).
-   View models only talk to models.
-   View controllers can't talk to models directly; they only interact with view models and views.
-   Views only talk to the view controllers, notifying them of interaction events (same as MVC).

And that's pretty much it. It's not that different from MVC – the key differences are:

-   There's a new "view model" class.
-   The view controller no longer has access to the model.

-   Use `MVVM*`
    -   **Model**: 
        -   stores data
        -   Probably parsed from JSON or comes from a database or the web,
        -   Plain-old struct or class
        -   `Codable`
        -   "Dumb"
        - Ex:
        ```swift
        struct Cat: Codable {
            let id: String
            let url: String
        }
        ```
    -   **View Model**
        -   Get data from model
        -   Send data to model
        -   Inform view of model changes through delegation
        -   Provide interface for views ("in a way that makes sense to a view") and hides the model from the view.
        -   Business logic
        -   Hits the network
        -   Is initialized with its dependancies
        -   Ex:
        ```swift
        protocol CatViewModelDelegate: class {
            func catViewModelDidUpdate(_ viewModel: CatViewModel)
        }
        protocol CatViewModel: class {
            var delegate: CatViewModelDelegate?
            var count: Int { get }
            func cat(at index: Int) -> Cat
            func update()
        }
        ```
    -   **View**: 
        -   `UIView`
            -   Accepts user input and tells `UIViewController` through delegation.
            -   "Dumb"
        -   `UIViewController`
            -   Builds, owns, and maintains `UIViews`
            -   Has a reference to a `ViewModel` through a protocol.
            -   Is informed of updates in `ViewModel` through delegation or closures.
            -   Can see models, adapts them for `UIViews`
        ```swift
        class CatTableViewCell: UITableViewCell { /***/ }
        class CatTableViewController: UITableViewController {
          var viewModel: CatViewModel

          override func viewDidLoad() {
            super.viewDidLoad()
            viewModel.update()
          }

          /// cell for row, etc.
        }
        extension CatTableViewController: CatViewModelDelegate {
          func catViewModelDidUpdate(_ viewModel: CatViewModel) {
            tableView.reloadData()
          }
        }
        ```

Standards
---------

### Types

Write all type names with UpperCamelCase, function and variable names with lowerCamelCase.

```swift
class MyClass { }
protocol MyProtocol { }
func myFunction() { }
var myVariable: String
```

Avoid acronyms and abbreviations for clarity and readability. If you have to use an acronym, use upper case.

```swift
productURL = NSURL()
userID = "12345"
```

### Protocols

Protocol names describing something should be a noun: `Collection`, `Element`. Protocol names describing an ability should end with “ing” or “able”: `Evaluatable`, `Printable`, `Formatting`.

### Enums

Enum cases start with lowerCamelCase.

```
enum Color {
    case red
    case blue
    case green
    case lightBlue
}
```

### Functions

Name your function with words that describe its behavior. Here is an example with a function that removes an element at an index x.

**Preferred:**
```swift
func remove(at index: Index) -> Element
```

**Not Preferred:**
```swift
func remove(index: Index) -> Element
```

*Rationale*: It is better to specify that we are removing the element at the given index, and we are not trying to remove the given parameter itself, to make the behavior of the function very clear.

Avoid unnecessary words in the function name.

**Preferred:**
```swift
func remove(_ element: Element) -> Element?
```

**Not Preferred:**
```swift
func removeElement(_ element: Element) -> Element?
```

*Rationale*: It makes the code clearer and more concise. Adding extra unnecessary words will make the code harder to read and understand.

Name your functions based on their side effects and behaviors.

* With side effects: use **imperative verb** phrases:
  * `print(x)`, `x.sort()`, `x.append(y)`
* Without side effects: use **noun** phrases:
  * `x.formattedName()`, `x.successor()`

When the function can be described by a verb, use an imperative verb for the mutating function and apply “ed” or “ing” to the nonmutating function:
* Mutating function:
  * `x.sort()`
  * `x.append(y)`
* Nonmutating function:
  * `z = x.sorted()`
  * `z = x.appending(y)`

Name functions to be read as a sentence according to their side effects.

**Preferred:**
```swift
x.insert(y, at: z)          // x, insert y at z
x.subViews(havingColor: y)  // x's subviews having color y
x.capitalizingNouns()       // x, capitalizing nouns
```

**Not Preferred:**
```swift
x.insert(y, position: z)
x.subViews(color: y)
x.nounCapitalize()
```

### Empty Return Types

When specifying return type for functions, methods or closures that return no value, favor the type alias `Void` over empty tuple `()`.

**Preferred:**
```swift
func performTask(_ completion: @escaping (Bool) -> Void)
```

**Not Preferred:**
```swift
func performTask(_ completion: @escaping (Bool) -> ())
```

### Enum & Protocol

All enums should live in their own file, except in cases where the enum is declared as private. In cases where the enum is declared private, declare the enum at the top of the file, above the type declaration.

*Rationale*: With enum and protocol types Swift allows defining functions and extensions. Because of that these types can become complex which is why they should be defined in their own file.

### Type Declarations

When declaring types, the colon should be placed immediately after the identifier followed by one space and the type name.

```swift

var intValue: Int

// Do NOT do this
var intValue : Int

```

In all use-cases, the colon should be associated with the left-most item with no spaces preceding and one space afterwards:

```swift
let myDictionary: [String: AnyObject] = ["String": 0]
```

### typealias

Typealias declarations should precede any other type declaration.

```swift
// typealias ClosureType = (ParameterTypes) -> (ReturnType)
typealias AgeAndNameProcessor = (Int, String) -> Void

var intValue: Int

class Object {

  private var someString = ""

  func returnOne() -> Int {
    return 1
  }

}
```

If declaring a typealias for protocol conformance, it should be declared at the top of the type declaration, before anything else.


```swift
protocol Configurable {

    associatedtype InputData

    func configure(data: InputData) -> Void

}

class ExampleWillNeed {

    var x: String = ""
    var y: String = ""

}

class Example: Configurable {

    typealias InputData = ExampleWillNeed

    var a: String = ""
    var b: String = ""

    func configure(data: InputData)  {
        a = data.x
        b = data.y
    }

}
```

### Type Inference

Prefer letting the compiler infer the type instead of explicitly stating it, wherever possible:

```swift
var max = 0     // Int
var name = "John"   // String
var rect = CGRect() // CGRect

// Do not do:

var max: Int = 0
var name: String = "John"
var rect: CGRect = CGRect()

// Ok since the inferred type is not what we wanted:

var max: Hashable = 0 // Compiler would infer Int, but we only want it to be hashable
var name: String? = "John" // Compiler would infer this not to be optional, but we may need to nil it out later.
```

*Rationale* The compiler is pretty smart, and we should utilize it where necessary. It is generally obvious what the
type is going to be in the instances above, so unless we need to be more explicit (as in the last examples above), it is better to omit unneeded words.

### Statement Termination

Unlike Objective-C, omit the use of `;` to terminate statements. Instead, simply use new lines to indicate the end of a statement.

```swift
let myVar = 0
doSomething(myVar)

return
```

Avoid multiple statements on a single line.

```swift
guard let obj = myObj else { print("Something went wrong"); return; } // Wrong! Instead, place each item on its own line.
```

### Variable Declaration

For declaring variables, favor `let` instead of `var` unless you need a mutable object or container.

```swift
func formatDate(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter() // In this case, use `let` since the variable `dateFormatter` never changes once set
    dateFormatter.dateStyle = .ShortStyle
    return dateFormatter.stringFromDate(date)
}

func arrays() {
    let array = ["Hello", "Ciao", "Aloha"] // use let here since this is an immutable container

    var mutableArray = [String]() // Use var here since this container is mutable
    mutableArray.append("Farewell")
    mutableArray.append("Arrivederci")
}

```

### Self

Never use the `self` modifier except in cases where it is necessary for the compiler or to alleviate conflicts
with other variable declarations.

```swift

class Object {
  private var name = ""

  func useName() {
    // Let self be implied when it can be understood.
    otherObject.doSomethingWithName(name)
    setName("Will Smith")
  }

  func setName(name: String) {
    // Use self here to prevent conflicts with the `name` parameter being passed.
    self.name = name
  }

  func setNameAsync(newName: String) {
    // Use implicit self outside closures...
    otherObject.doSomethingWithName(name, then: {
      // .. but within, you must use self to ease the compiler.
      self.setName("Jason")
    })
  }
}

```

*Rationale*: The idea behind this is that implicit use of self makes the conditions where you _must_ use self
(for instance, within closures) much more apparent and will make you think more on the reasons why you are using it.
In closures, think about: should `self` be `weak` instead of `strong`? Apple has even rejected a request to enforce use of `self` for this reason, [among others](http://ericasadun.com/2016/01/06/the-swift-evolution-proposal-se-0009-rejection/).

### Bracket Syntax

For brackets, prefer the Xcode-default syntax of having the opening brace be on the same line as the statement opening it:

```swift
final class MyObject {
}

enum MyEnum {
}

func doSomething() {
}

if true == false {
}

let doSomething: () -> Void = {
}

```

For type declarations, include a single space between the type declaration and the first item implemented within
it:

```swift
final class MyObject {

  let value = 0
```

In addition, include a space before the type declaration's closing bracket:

```swift
final class MyObject {

  let value = 0

  func doSomething() {
    value += 1
  }

}
```

This also applies to extension declarations:

```swift
extension MyObject {

  func doAnotherThing() {
    ...
  }

}
```

Do not include this extra space in function declarations:

```swift
func doSomething() {
  let value = 0
}
```

*Rationale*: Simply put, this is the Xcode default and standard, and it's not worth fighting. This keeps things consistent
across the board and makes our lives as developers considerably easier.

### Error Handling

The emergence of `try / catch` in Swift 2 has added powerful ways to define and return errors when something fails. The emergence of `ErrorType`
as well for defining errors makes error definitions much more convenient over the cumbersome `NSError`. Because of this, for functions that can have multiple
points of failure, you should always define it as `throws` and return a well-defined `ErrorType`.

Consider the following contrived example:

```swift

func multiplyEvensLessThan10(evenNumber: Int) -> Int? {
  guard evenNumber % 2 == 0 && evenNumber < 10 else {
    return nil
  }

  return evenNumber * 2
}

```

The function above fails because it only expects evens less than 10 and returns an optional if that is violated. While this works and is simple, it
is more Objective-C than Swift in its composition. The caller may not know which parameter they violated. For Swift, instead consider refactoring it as follows:

```swift

enum NumberError: ErrorType {
  case notEven
  case tooLarge
}

func multiplyEvens(evenNumber: Int) throws -> Int {
  guard evenNumber % 2 == 0 else {
    throw NumberError.NotEven
  }

  guard evenNumber < 10 else {
    throw NumberError.TooLarge
  }

  return evenNumber * 2
}

```

The above, while slightly more cumbersome, this has well-defined benefits:

* The caller is able to explicitly determine why their call to the function failed and thus can take active steps to recover:

  ```swift
  let result: Int
  do {
      result = try multiplyEvens(3)
  } catch NumberError.NotEven {
      return 0
  } catch NumberError.TooLarge {
      print("The Number entered was too large! Try again.")
      return -1
  } catch {
      fatalError("Unhandled error occurred.")
  }

  return result
  ```

* Try/catch semantics allow the caller to still retain the old optional functionality if the error is not relevant and they only care about the outcome:

  ```swift
  let result: Int? = try? multiplyEvens(1)
  ```

* Or, if the caller knows that it will not violate any of the parameters for a valid input:

  ```swift
  let result: Int = try! multiplyEvens(2)
  ```

So, even though we've now modified our API to use swift exceptions, we can still retain the old Objective-C functionality giving the caller the choice
of how they wish to handle the result of this failable operation.

### NSError

In general, you should avoid `NSError` in Swift in favor of defining your own `ErrorType`. However, in the event you do need to use `NSError` (for interop with Objective-C, for instance):

* Define a proper domain for your `NSError`. This should be specific to your module and ideally would be reflective of your bundle identifier (e.g. `com.prolificinteractive.MyApp`).
* Define a list of the various error codes and what they translate to. These should be some sort of easily readable constant or enum value so that way the caller is able to determine what exactly failed.
* In the userInfo, include _at least_ a localized description (`NSLocalizedDescriptionKey`) that accurately and concisely describes the nature of the error.

### Structs and classes

In Swift, structs maintain value semantics which means their values are copied when assigned. Classes, on the other hand, act like pointers from C
and Objective-C; they are called reference types and the internal data is shared amongst instances of assigning.

When composing your types, consider carefully what they're going to be used for before choosing what they should end up being. In general,
consider structs for types that are:

* Immutable
* Stateless
* Have a definition for equality

Swift structs also have other, tangible benefits as well:

* Faster
* Safer due to copying rather than referencing
* Thread safe -- copies allow mutations to happen independently of other instances.

In general, you should favor structs and protocols over classes; even in cases where polymorphism would dictate the usage of a class, consider if you can
achieve a similar result via protocols and extensions. This allows you to achieve polymorphism via *composition* rather than *inheritance*.

### Nil Checking

Favor `if-let` checking over direct nil checking in all cases except when the result of this check is required:

```swift
guard let item = myItem else {
  return
}

doSomethingWith(item)
```

```swift
if let _ = error { // Prefer this over `if error != nil`
  fatalError()
}
```

```swift
func isError(error: Error?) -> Bool {
  return (error != nil) // In this case, we need the result of the bool, and this is much cleaner than the other options.
}
```

For style suggestions regarding nil checking visit our [best practices](https://github.com/prolificinteractive/swift-style-guide/blob/master/BestPractices.md) section.

### Implicit Getters

When overriding only the getter of a property, omit the use of `get`:

```swift
var myInt: Int {
  return 0
}

// Do not do this:
var myInt: Int {
  get {
    return 0
  }
}

```

For all other cases, specify the modifier as needed (`set`, `didSet`, etc.). This is compiler enforced.

*Rationale* The getter is implied enough to make sense without having to make it explicitly. It also cuts down on
unnecessary verbiage and spacing to make code clearer.

### Enums

For enum declarations, declare each enum case on a new line with its own `case` statement instead of a comma-separated list.

```swift
enum State {
  case open
  case closed
  case pending
  case faulted
}
```

Prefer singular case for enum names instead of plural: `State` vs. `States`:

```swift
var currentState = State.open
var previousState = States.closed // Reads less clearly than the previous option.
```

For enums with raw values, declare the raw value on the same line as its declaration:

```swift
enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
}
```

For any other functions or properties associated with the enum, place them after the last case item in the enum list:

```swift
enum State {
  case open
  case closed
  case pending
  case faulted

  func nextState() -> State {
    ...
  }
}
```

In cases where the enum's type name can be omitted, do so:

```swift
let state = State.open

if state == .closed { ... // Prefer .closed instead of State.closed
```


### Use of `final`

Classes should always be marked as `final` unless they are being used as a base class for another type. In instances where a class can be subclassed,
any function or variable that should not be overridden by a subclass should be diligently marked as `final`.

```swift
// Not built for inheritance.
final class Object {

}

// Purposefully utilizable as a base class
class BaseClass {

  func doSomething () {
  }

  // Properly marked as final so subclasses cannot override
  final func update() {
  }

}

final class SubClass: BaseClass {

  override func doSomething() {
    update()
  }

}

```

*Rationale* Subclassing in instances where the original class was not built to support subclasses can be a common source of bugs. Marking classes as `final`
indicates that it was developed under the assumption that it would act on its own without regard for subclasses.

### Operator Overloading

Operator overloading is not recommended. Overloads often lead to ambiguous semantics, unintuitive behaviours and obscurities that are difficult for everyone to understand except the person who wrote them. Instead opt for less succinct, yet more descriptive function definitions throughout your code.

### Custom Operators

Be wary of defining entirely new operators, unless your use case specifically requires it. In some situations borrowing an operator that is defined in the standard library of another language makes sense, such as operators specific to high level scientific or mathematical problem solving. The behaviour of your custom operator should be intuitive and obvious. Its semantics should not conflict with existing Swift operators. 

When defining a custom operator, be clear and use exhaustive documentation. Provide an example use of the operator within your documentation that others will easily understand. Define the new operator in the same file as the type definition that is making use of it.

Sources
-------

- The Apple Swift [API design guidelines](https://swift.org/documentation/api-design-guidelines/)
- NetNewsWire's [Coding Guidelines](https://github.com/brentsimmons/NetNewsWire/blob/1b0804e10cae4cb4b0ce6399e0f09179572ca73e/Technotes/CodingGuidelines.md)
- Prolific's [Swift Style Guide](https://github.com/prolificinteractive/swift-style-guide)
- https://www.youtube.com/watch?v=9VojuJpUuE8
- http://artsy.github.io/blog/2015/09/24/mvvm-in-swift/
- https://github.com/tattn/ios-architectures/tree/master/ios-architectures/MVVM

