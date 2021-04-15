struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
enum AcceptableCurrencies : String {
    case USD, GBP, EUR, CAN
}

public struct Money {
    var amount : Int
    var currency: String
    
    func convert(_ other : String) -> Money {
        let toUSD : Int = self.convertToUSD()

        switch other {
        case "GBP":
            return Money(amount: Int(Double(toUSD) * 0.5), currency: other)
        case "EUR":
            return Money(amount: Int(Double(toUSD) * 1.5), currency: other)
        case "CAN":
            return Money(amount: Int(Double(toUSD) * 1.25), currency: other)
        default:
            return Money(amount: toUSD, currency: other)
        }
    }
    
    func add(_ other : Money) -> Money {
        let converted : Money = self.convert(other.currency)
        let newAmount = converted.amount + other.amount
        return Money(amount: newAmount, currency: other.currency)
    }
    
    func subtract(_ other : Money) -> Money {
        let converted : Money = self.convert(other.currency)
        let newAmount = converted.amount - other.amount
        return Money(amount: newAmount, currency: other.currency)
    }
    
    private func convertToUSD() -> Int {
        switch self.currency {
        case "GBP":
            return self.amount * 2
        case "EUR":
            return Int(Double(self.amount) / 1.5)
        case "CAN":
            return Int(Double(self.amount) / 1.25)
        default:
            return self.amount
        }
    }
}

////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    var title : String
    var type : JobType
    
    init(title : String, type : JobType) {
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ hour : Int) -> Int {
        switch self.type {
        case .Hourly(let amount):
            return Int(Double(hour) * amount)
        case .Salary(let amount):
            return Int(amount)
        }
    }
    
    func raise(byAmount: Int) {
        switch self.type {
        case .Hourly(let amount):
            self.type = JobType.Hourly(amount + Double(byAmount))
        case .Salary(let amount):
            self.type = JobType.Salary(amount + UInt(byAmount))
        }
    }
    
    func raise(byAmount: Float) {
        switch self.type {
        case .Hourly(let amount):
            self.type = JobType.Hourly(amount + Double(byAmount))
        case .Salary(let amount):
            self.type = JobType.Salary(amount + UInt(byAmount))
        }
    }
    
    func raise(byPercent: Float) {
        switch self.type {
        case .Hourly(let amount):
            self.type = JobType.Hourly(amount * Double(1.0 + byPercent))
        case .Salary(let amount):
            self.type = JobType.Salary(UInt(Float(amount) * (1.0 + byPercent)))
        }
    }
}

////////////////////////////////////
// Person
//
public class Person {
    var firstName : String?
    var lastName : String?
    var age : Int
    var innerJob : Job?
    var innerSpouse: Person?
    
    var job : Job? {
        get {return self.innerJob}
        set(value) {
            if self.age >= 18 {
                self.innerJob = value
            }
        }
    }
    
    var spouse : Person? {
        get {return self.innerSpouse}
        set(value) {
            if self.age >= 18 {
                self.innerSpouse = value
            }
        }
    }
    
    init(firstName fn : String, lastName ln : String, age ag : Int) {
        self.firstName = fn
        self.lastName = ln
        self.age = ag
        self.job = nil
        self.spouse = nil
    }
    
    init(firstName fn : String, age ag: Int) {
        self.firstName = fn
        self.lastName = nil
        self.age = ag
        self.job = nil
        self.spouse = nil
    }
    
    init(lastName ln : String, age ag : Int) {
        self.firstName = nil
        self.lastName = ln
        self.age = ag
        self.job = nil
        self.spouse = nil
    }
    
    func toString() -> String {
        return "[Person: firstName:\(String(describing: self.firstName ?? "nil")) lastName:\(String(describing: self.lastName ?? "nil")) age:\(self.age) job:\(String(describing: self.job?.type)) spouse:\(String(describing: self.spouse?.firstName))]"
    }
    
    func convert() {
        switch self.innerJob?.type {
        case .Hourly(let i):
            let ty : Job.JobType = Job.JobType.Salary(UInt(2000 * i / 1000 * 1000))
            self.innerJob = Job(title: self.innerJob?.title ?? "nil", type: ty)
        default:
            return
        }
    }
}

////////////////////////////////////
// Family
//
public class Family {
    var members : [Person]
    
    init(spouse1 : Person, spouse2: Person) {
        if spouse1.spouse != nil || spouse2.spouse != nil {
            self.members = []
            return
        }
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        self.members = [spouse1, spouse2]
    }
    
    func haveChild(_ child: Person) -> Bool {
        if (members[0].age <= 21 && members[1].age <= 21) {
            return false
        }
        members.append(child)
        return true
    }
    
    func householdIncome() -> Int {
        var total : Int = 0
        for p in members {
            total += p.job?.calculateIncome(2000) ?? 0
        }
        return total
    }
}
