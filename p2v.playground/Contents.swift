//: Playground - noun: a place where people can play

struct Meal {
    let title: String
}

struct Favorite {
    let name: String
}

let meal1 = Meal(title: "Soup")
let meal2 = Meal(title: "Stew")
let meal3 = Meal(title: "Pizza")

let favorite1 = Favorite(name: "Stew")

let baseArray = [meal1, meal2, meal3]

let dict = [1:"one", 2:"two", 3:"three"]

//print(intArr.count)

for (key,val) in dict {
    print("\(key) -- \(val)")
}



enum DayOfTheWeek: Int{
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    case Sunday = 7
}

let tues = DayOfTheWeek.Tuesday
print(tues)


enum ASCIIControlCharacter: Character {
    case tab = "A"
    case lineFeed = "B"
    case carriageReturn = "C"
}
print(ASCIIControlCharacter.carriageReturn)
print(ASCIIControlCharacter.carriageReturn.rawValue)
