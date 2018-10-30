iOS Program Design 
==================

Coding guidelines
-----------------

### Values

In order,

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
-   Use assertions and preconditions
    -   Assertions will crash a debug build, preconditions will crash a release build. 
    -   Force-unwrapping of optionals is allowed as a shorthand for a precondition 
        failure, though these should be used sparingly.
    -   `fatalError()` is acceptable as shorthand for a failure that is a developer
        error that should result in crashing a production build, but should be used
        sparingly.
-   Extensions, including private extensions, are preferred, on Cocoa and custom
    types.
-   Things should be marked private as often as possible. APIs should be exactly 
    what’s needed and not more.

### Composition

#### No subclasses

-   Subclassing is inevitable — there’s no way out of subclassing things like 
    UIView and UIViewController, because that’s how UIKit works.
-   Consider this a hard rule: all Swift classes must be marked as final.

#### Protocols and delegates

-   Protocols and delegates (which are also protocol-conforming) are preferred.
    -   Default implementations in protocols are allowed but ever-so-slightly 
        discouraged. You’ll find several instances in the code, but this is done 
        carefully — we don’t want this to be just another form of inheritance, 
        where you find that you have to bounce back-and-forth between files to 
        figure out what’s going on.

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
-   But in larger doses some redesign is needed. It is often the case that 
    breaking up the problem into smaller objects (see above) can solve the 
    repetition problem.

### Model objects

-   Model objects are plain old objects. We don’t use Core Data or any other 
    system that requires subclassing.
-   Immutable Swift structs are strongly preferred. They’re worth a little 
    standing-on-your-head to get them — but only a little. Otherwise, 
    use a mutable struct or reference-type object, depending on needs.
-   If you are using CoreData, suffix the class name with `ManagedObject`

### Code organization

-   You should not define multiple public/internal types (ie class, struct, enum) 
    in the same file; each type should have its own file.
-   The following list should be the standard organization of all your Swift 
    files, in this specific order:
    1.  Overriden properties
    2.  Properties
    3.  Static and class variables
    4.  Static/Class functions
    5.  Initializers
    6.  Overriden functions
    7.  Instance functions

-   After the core class, for each protocol you want to conform to, you should 
    create an extension of your class in the same file. The first extension should
    be your private functions.

-   Each section above should be organized by accessibility:
    1.  Open
    2.  Public
    3.  Internal
    4.  Fileprivate
    5.  Private

-   All enums should live in their own file, except when they're private, and then
    they should be at the top of the file they're used in.
-   If you need to use `MARK` to break up the file, consider first breaking the
    file into multiple files. Avoid `TODO` and `FIXME` unless absolutely 
    necessary.

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

```
⛔️
extension List {
    public mutating func remove(_ position: Index) -> Element
}

// X variable
let x = /* ... */
employees.remove(x)
```

```
✅
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

```
⛔️
public mutating func removeElement(_ member: Element) -> Element?
allViews.removeElement(cancel)
```

```
✅
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

  ```
  ⛔️
  x.insert(y, position: z)
  x.subViews(color: y)
  x.nounCapitalize()
  ```

  ```
  ✅
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

Sources
-------

- The Apple Swift [API design guidelines](https://swift.org/documentation/api-design-guidelines/)
- NetNewsWire's [Coding Guidelines](https://github.com/brentsimmons/NetNewsWire/blob/1b0804e10cae4cb4b0ce6399e0f09179572ca73e/Technotes/CodingGuidelines.md)
- Prolific's [Swift Style Guide](https://github.com/prolificinteractive/swift-style-guide)

