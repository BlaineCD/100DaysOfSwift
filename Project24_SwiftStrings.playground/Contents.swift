import UIKit

// Pt. 1: Strings are not arrays
let name = "Blaine"

for letter in name {
    print("Give me a \(letter)")
}

let letter = name[name.index(name.startIndex, offsetBy: 3)]

// To find an empty string better to use isEmpty than count == 0.

// right:
name.isEmpty

// wrong:
name.isEmpty

// Pt. 2: Working with Strings in Swift
let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

// Add extension methds to extend how prefixing and suffixing works:
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

// capitalized property gives first letter of each word a capital letter:
let weather = "it's going to rain"
print(weather.capitalized)
// prints: It's Going To Rain

// add specialized extension that uppercases only the first letter of the strin.
extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

// contains() returns true if it contains another string.
let input = "Swift is like Objective-C without the C"
input.contains("Swift")
// returns true

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")
// returns true

extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        return false
    }
}

input.containsAny(of: languages)
// More elegant solution.
languages.contains(where: input.contains)

// Pt. 3: Formatting strings with NSAttributedString

let string = "This is a test string"
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]
let attributedString = NSAttributedString(string: string, attributes: attributes)

let anotherString = "This is a test string"
let anotherAttributedString = NSMutableAttributedString(string: anotherString)
anotherAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
anotherAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
anotherAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
anotherAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
anotherAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

// Challenge 1
extension String {
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) { return self }
        return prefix + self
    }
}

// test
print("boat".withPrefix("house"))
print("boat".withPrefix("bo"))

// Challenge 2
extension String {
    var isNumeric: Bool {
        self.contains("\(Int())") || self.contains("\(Double())") || self.contains("\(Float())") ? true : false
    }
}

// test
"Houseboat".isNumeric
"H0useboat".isNumeric
"H10.7SEBOAT".isNumeric

// Challenge 3
extension String {
    var lines: [String] {
        self.components(separatedBy: "\n")
    }
}

// test
"this\nis\na\ntest".lines

