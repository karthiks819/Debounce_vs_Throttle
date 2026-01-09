# 🎯 Debounce vs Throttle in Swift Combine

A comprehensive guide to understanding the difference between **Debounce** and **Throttle** operators in Swift Combine framework with practical coding examples and real-world use cases.

## 📚 Overview

Both `debounce` and `throttle` are essential operators for handling high-frequency events (like user input, scroll events, network requests). However, they work differently:

### ⏱️ **DEBOUNCE**
- **Definition:** Waits for silence - ignores all events until a specified time passes without any new events
- **Behavior:** Emits only the **latest value** after a period of inactivity
- **Use Case:** Search bars, autocomplete, form validation, user input handling

```swift
let searchText = $searchQuery
    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    .removeDuplicates()
    .flatMap { query in
        fetchSearchResults(for: query)
    }
    .sink { results in
        self.searchResults = results
    }
```

**Example:** User types "swift" (5 characters) - waits 500ms without typing - emits "swift"

---

### 🚀 **THROTTLE**
- **Definition:** Emits periodically - emits the latest event at regular time intervals
- **Behavior:** Ensures a **maximum emission rate**, even if events keep firing
- **Use Case:** Scroll events, window resizing, button clicks (prevent double-tap), API rate limiting

```swift
let scrollEvents = scrollSubject
    .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
    .sink { offset in
        updateScrollPosition(offset)
    }
```

**Example:** User scrolls rapidly - emits latest offset every 1 second

---

## 🔍 Visual Comparison

```
EVENTS:      |------|------|------|------|------|
             0    250ms  500ms  750ms  1000ms

DEBOUNCE     (500ms interval)
             ________________________|----> Emit (waits for silence)

THROTTLE     (500ms interval)  
             |----> Emit   |----> Emit   |----> Emit
```

## 💡 Quick Decision Guide

| Scenario | Use | Reason |
|----------|-----|--------|
| Search Input | Debounce | Wait until user stops typing |
| Scroll Events | Throttle | Emit consistently at intervals |
| Button Clicks | Throttle | Prevent rapid/double-clicks |
| Form Validation | Debounce | Validate after user finishes input |
| Window Resize | Throttle | Process at fixed intervals |
| Network Requests | Debounce | Send request once, not on every keystroke |

---

## 🎯 Key Differences at a Glance

```
Situation: User generates 5 events rapidly

Debounce: [Events] → [Wait] → [Emit 1 event]
Throttle: [Emit 1] → [Wait] → [Emit 1] → [Wait] → [Emit 1]
```

---

## 🛠️ Complete Real-World Example

### Search with Debounce
```swift
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .flatMap { query in
                self.performSearch(query)
            }
            .assign(to: &$searchResults)
    }
    
    private func performSearch(_ query: String) -> AnyPublisher<[String], Never> {
        // Simulate API call
        Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                promise(.success(["Result for \(query)"]))
            }
        }
        .eraseToAnyPublisher()
    }
}
```

### Scroll with Throttle
```swift
import Combine

class ScrollViewModel: ObservableObject {
    @Published var scrollOffset: CGPoint = .zero
    @Published var lastScrollUpdate: Date = Date()
    
    private var scrollSubject = PassthroughSubject<CGPoint, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        scrollSubject
            .throttle(for: .milliseconds(100), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] offset in
                self?.scrollOffset = offset
                self?.lastScrollUpdate = Date()
            }
            .store(in: &cancellables)
    }
    
    func scrollDidChange(to offset: CGPoint) {
        scrollSubject.send(offset)
    }
}
```

---

## 📹 Video Example

Check out the attached video demonstrating the visual difference between debounce and throttle in action with real-world scenarios.

---

## 🎓 When to Use What

✅ **Use Debounce for:**
- User input (search, filters)
- Form validation
- Text field changes
- Any action that should happen AFTER user stops interacting

✅ **Use Throttle for:**
- Scroll/drag events
- Resize events
- Repeated button clicks
- Any action that should happen at REGULAR intervals

---

## 📖 Additional Resources

- [Apple Combine Documentation](https://developer.apple.com/documentation/combine)
- [Debounce Operator](https://developer.apple.com/documentation/combine/publisher/debounce(for:scheduler:options:))
- [Throttle Operator](https://developer.apple.com/documentation/combine/publisher/throttle(for:scheduler:latest:))

---

## 📝 License

MIT License - Feel free to use this for learning!

---

**Happy Coding! 🚀**
