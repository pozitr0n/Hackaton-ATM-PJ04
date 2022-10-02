import UIKit
import Foundation
import PlaygroundSupport

// User-protocol
protocol UserData {
    
    // User name
    var userName: String { get }
    
    // Card number
    var userCardID: String { get }
    
    // PIN
    var userCardPin: Int { get }
    
    // Phone number
    var userPhoneNumber: String { get }
    
    // Available cash of the user
    var userCashAvailable: Float { get set }
    
    // Available bank deposit of the user
    var userBankDeposit: Float { get set }
    
    // Available phone balance of the user
    var userPhoneBalance: Float { get set }
    
    // Available card balance of the user
    var userCardBalance: Float { get set }
    
}

// User-class
class User: UserData {
    
    var userName: String
    var userCardID: String
    var userCardPin: Int
    var userPhoneNumber: String
    var userCashAvailable: Float
    var userBankDeposit: Float
    var userPhoneBalance: Float
    var userCardBalance: Float
    
    init(userName: String,
         userCardID: String,
         userCardPin: Int,
         userPhoneNumber: String,
         userCashAvailable: Float,
         userBankDeposit: Float,
         userPhoneBalance: Float,
         userCardBalance: Float) {
        
        self.userName = userName
        self.userCardID = userCardID
        self.userCardPin = userCardPin
        self.userPhoneNumber = userPhoneNumber
        self.userCashAvailable = userCashAvailable
        self.userBankDeposit = userBankDeposit
        self.userPhoneBalance = userPhoneBalance
        self.userCardBalance = userCardBalance
        
    }
    
}

// User actions using ATM
enum UserActionsWithATM {
    
    // request balance from the card
    case requestBalanceFromCard
    
    // request balance from the deposit
    case requestBalanceFromDeposit

    // withdraw money from the bank deposit
    case withdrawMoneyFromDeposit(putOut: Float)
    
    // withdraw money from the card
    case withdrawMoneyFromCard(putOut: Float)
    
    // put the money on the bank deposit
    case putMoneyOnDeposit(putIn: Float)

    // put the money on the card
    case putMoneyOnCard(putIn: Float)
    
    // pay phone
    case payPhone(phoneNumber: String)
   
}

// Types of operations selected by the user (selection confirmation)
enum DescriptionTypesAvailableOperations: String {
 
    case selectedOperationRequestBalance = "The user has selected the \"Balance Request\" operation"
    case selectedOperationWithdrawalCash = "The user has selected the \"Withdrawal Cash\" operation"
    case selectedOperationPutingMoneyToDeposit = "The user has selected the \"Puting Money To The Deposit\" operation"
    case selectedOperationPutingMoneyToPhone = "The user has selected the \"Puting Money To The Phone\" operation"
    case selectedOperationPutingMoneyToCard = "The user has selected the \"Puting Money To The Card\" operation"
    
}

// Method of payment/replenishment in cash or via card
enum PaymentMethod {

    case byCash(cashSum: Float)
    case byCard(cardSum: Float)
    
}

// Text of the errors
enum TextErrors: String {
 
    case errorNotEnoughCash = "You have not enough cash"
    case errorNotEnoughMoneyOnDeposit = "You have not enough money on bank deposit"
    case errorNotEnoughMoneyOnCard = "You have not enough money on the card"
    case errorIncorrectPINOrCardNumber = "The entered PIN/card number is incorrect"
    case errorIncorrectPhone = "The entered phone number is incorrect"
    case errorIncorrectPayment = "Have troubles with payment"
    case errorEmptyBalanceOfCard = "Balance of the card is empty"
    case errorEmptyBalanceOfDeposit = "Balance of the bank deposit is empty"
    
}

// The protocol for working with the bank provides access to the data of the user registered with the bank
protocol BankAPI {
    
    // Balance request block
    func showUserCardBalance()
    func showUserDepositBalance()
    
    // Mobile phone top-up block
    func showUserToppedUpMobilePhoneCash(cash: Float)
    func showUserToppedUpMobilePhoneCard(card: Float)
    
    // Cash withdrawal block
    func showWithdrawalCard(cash: Float)
    func showWithdrawalDeposit(cash: Float)
    
    // Block replenishment of bank accounts with money
    func showTopUpCard(cash: Float)
    func showTopUpDeposit(cash: Float)
    
    // Error output block
    func showError(error: TextErrors, criticalError: Bool)
 
    // Error check block
    func checkUserPhone(phone: String) -> Bool
    func checkMaxUserCash(cash: Float) -> Bool
    func checkMaxUserCard(withdraw: Float) -> Bool
    func checkMaxUserDeposit(withdraw: Float) -> Bool
    
    func checkCardBalanceIsNotEmpty() -> Bool
    func checkDepositBalanceIsNotEmpty() -> Bool
    
    func checkCurrentUser(userCardID: String, userCardPin: Int) -> Bool
 
    // Main logic block
    mutating func topUpPhoneBalanceCash(pay: Float)
    mutating func topUpPhoneBalanceCard(pay: Float)
    
    mutating func getCashFromDeposit(cash: Float)
    mutating func getCashFromCard(cash: Float)
    
    mutating func putCashDeposit(topUp: Float)
    mutating func putCashCard(topUp: Float)
    
}

// The ATM we are working with has a public sendUserDataToBank interface
class ATM {
   
    private let userCardID: String
    private let userCardPin: Int
    private var someBank: BankAPI
    private let currentAction: UserActionsWithATM
    private let paymentMethod: PaymentMethod?
 
    init(userCardID: String, userCardPin: Int, someBank: BankAPI, currentAction: UserActionsWithATM, paymentMethod: PaymentMethod? = nil) {
        
        self.userCardID = userCardID
        self.userCardPin = userCardPin
        self.someBank = someBank
        self.currentAction = currentAction
        self.paymentMethod = paymentMethod
        
        sendUserDataToBank(userCardID: userCardID, userCardPin: userCardPin, actions: currentAction, payment: paymentMethod)
    }
    
    public final func sendUserDataToBank(userCardID: String, userCardPin: Int, actions: UserActionsWithATM, payment: PaymentMethod?) {
    
        if someBank.checkCurrentUser(userCardID: userCardID, userCardPin: userCardPin) {
           
            switch actions {
            
            case .requestBalanceFromCard:
                
                if someBank.checkCardBalanceIsNotEmpty() {
                    someBank.showUserCardBalance()
                } else {
                    someBank.showError(error: .errorEmptyBalanceOfCard, criticalError: false)
                }
                
            case .requestBalanceFromDeposit:
                
                if someBank.checkDepositBalanceIsNotEmpty() {
                    someBank.showUserDepositBalance()
                } else {
                    someBank.showError(error: .errorEmptyBalanceOfDeposit, criticalError: false)
                }
                
            case let .withdrawMoneyFromDeposit(putOut):
                
                if someBank.checkMaxUserDeposit(withdraw: putOut) {
                
                    someBank.getCashFromDeposit(cash: putOut)
                    someBank.showWithdrawalDeposit(cash: putOut)
                    
                } else {
                    someBank.showError(error: .errorNotEnoughMoneyOnDeposit, criticalError: true)
                }
                
            case let .withdrawMoneyFromCard(putOut):
                
                if someBank.checkMaxUserCard(withdraw: putOut) {
                
                    someBank.getCashFromCard(cash: putOut)
                    someBank.showWithdrawalCard(cash: putOut)
                    
                } else {
                    someBank.showError(error: .errorNotEnoughMoneyOnCard, criticalError: true)
                }
                
            case let .putMoneyOnDeposit(putIn):
               
                if someBank.checkMaxUserCash(cash: putIn) {
                    
                    someBank.putCashDeposit(topUp: putIn)
                    someBank.showTopUpDeposit(cash: putIn)
                    
                } else {
                    someBank.showError(error: .errorNotEnoughCash, criticalError: true)
                }
            
            case let .putMoneyOnCard(putIn):
                
                if someBank.checkMaxUserCash(cash: putIn) {
                    
                    someBank.putCashCard(topUp: putIn)
                    someBank.showTopUpCard(cash: putIn)
                    
                } else {
                    someBank.showError(error: .errorNotEnoughCash, criticalError: true)
                }
                
            case let .payPhone(phoneNumber):
                
                if someBank.checkUserPhone(phone: phoneNumber) {
                
                    if var payment = payment {
                        
                        switch payment {
                            
                        case let .byCard(cardSum):
                            
                            if someBank.checkMaxUserCard(withdraw: cardSum) {
                            
                                someBank.topUpPhoneBalanceCard(pay: cardSum)
                                someBank.showUserToppedUpMobilePhoneCard(card: cardSum)
                                
                            } else {
                                someBank.showError(error: .errorNotEnoughMoneyOnCard, criticalError: true)
                            }
                            
                        case let .byCash(cashSum):
                            
                            if someBank.checkMaxUserCash(cash: cashSum) {
                             
                                someBank.topUpPhoneBalanceCash(pay: cashSum)
                                someBank.showUserToppedUpMobilePhoneCash(cash: cashSum)
                                
                            } else {
                                someBank.showError(error: .errorNotEnoughCash, criticalError: true)
                            }
                            
                        }
                        
                    } else {
                        someBank.showError(error: .errorIncorrectPayment, criticalError: true)
                    }
                    
                } else {
                    someBank.showError(error: .errorIncorrectPhone, criticalError: true)
                }
                
            }
            
        } else {
            someBank.showError(error: .errorIncorrectPINOrCardNumber, criticalError: true)
        }
        
    }
    
}

// A class of a bank that provides API methods for working with it through an ATM
class Bank: BankAPI {
    
    private var user: UserData
    
    init(user: UserData) {
        self.user = user
    }
    
    public func showUserCardBalance() {
        
        var cardBalance: String = ""
        
        cardBalance = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationRequestBalance.rawValue), your card balance is \(user.userCardBalance) zł. Thank you."
        print(cardBalance)
        
    }
    
    public func showUserDepositBalance() {
    
        var depositBalance: String = ""
        
        depositBalance = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationRequestBalance.rawValue), your balance at your deposit is \(user.userBankDeposit) zł. Thank you."
        print(depositBalance)
        
    }
    
    public func showUserToppedUpMobilePhoneCash(cash: Float) {
    
        var toppedUpMobileByCash: String = ""
        
        toppedUpMobileByCash = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationPutingMoneyToPhone.rawValue), you've topped up your mobile in the amount \(cash) zł by cash. Thank you. Your cash balance is \(user.userCashAvailable) zł. Your mobile balance is \(user.userPhoneBalance) zł."
        print(toppedUpMobileByCash)
        
    }
    
    public func showUserToppedUpMobilePhoneCard(card: Float) {
    
        var toppedUpMobileByCard: String = ""
        
        toppedUpMobileByCard = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationPutingMoneyToPhone.rawValue), you've topped up your mobile in the amount \(card) zł by card. Thank you. Your card balance is \(user.userCardBalance) zł. Your mobile balance is \(user.userPhoneBalance) zł."
        print(toppedUpMobileByCard)
        
    }
    
    public func showWithdrawalCard(cash: Float) {
    
        var withdrawalCard: String = ""
        
        withdrawalCard = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationWithdrawalCash.rawValue), you've withdrawn the amount \(cash) zł from your card. Thank you. Your card balance is \(user.userCardBalance) zł. Your cash balance is \(user.userCashAvailable) zł."
        print(withdrawalCard)
        
    }
    
    public func showWithdrawalDeposit(cash: Float) {
        
        var withdrawalDeposit: String = ""
        
        withdrawalDeposit = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationWithdrawalCash.rawValue), you've withdrawn the amount \(cash) zł from your deposit. Thank you. Your deposit balance is \(user.userBankDeposit) zł. Your cash balance is \(user.userCashAvailable) zł."
        print(withdrawalDeposit)
        
    }
    
    public func showTopUpCard(cash: Float) {
    
        var topCard: String = ""
        
        topCard = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationPutingMoneyToCard.rawValue), you've topped up your card in the amount \(cash) zł. Thank you. Your card balance is \(user.userCardBalance) zł. Your cash balance is \(user.userCashAvailable) zł."
        print(topCard)
        
    }
    
    public func showTopUpDeposit(cash: Float) {
   
        var topDeposit: String = ""
        
        topDeposit = "Dear \(user.userName), \(DescriptionTypesAvailableOperations.selectedOperationPutingMoneyToDeposit.rawValue), you've topped up your deposit in the amount \(cash) zł. Thank you. Your deposit balance is \(user.userBankDeposit) zł. Your cash balance is \(user.userCashAvailable) zł."
        print(topDeposit)
        
    }
    
    public func showError(error: TextErrors, criticalError: Bool) {
    
        var textError: String = ""
        
        if criticalError {
            textError = "Dear \(user.userName). Error: \(error.rawValue)"
        } else {
            textError = "Dear \(user.userName). \(error.rawValue)"
        }
        
        print(textError)
        
    }
    
    public func checkCardBalanceIsNotEmpty() -> Bool {
    
        if user.userCardBalance != 0 {
            return true
        } else {
            return false
        }
        
    }
    
    public func checkDepositBalanceIsNotEmpty() -> Bool {
    
        if user.userBankDeposit != 0 {
            return true
        } else {
            return false
        }
        
    }
    
    public func checkUserPhone(phone: String) -> Bool {
        
        if phone == user.userPhoneNumber {
            return true
        } else {
            return false
        }
        
    }
    
    public func checkMaxUserCash(cash: Float) -> Bool {
        
        if user.userCashAvailable >= cash {
            return true
        } else {
            return false
        }
        
    }
    
    public func checkMaxUserCard(withdraw: Float) -> Bool {
        
        if user.userCardBalance >= withdraw {
            return true
        } else {
            return false
        }
        
    }
    
    public func checkMaxUserDeposit(withdraw: Float) -> Bool {
        
        if user.userBankDeposit >= withdraw {
            return true
        } else {
            return false
        }
        
    }
    
    public func checkCurrentUser(userCardID: String, userCardPin: Int) -> Bool {
    
        if checkCardIDOfUser(userCardID) && checkPINOfUser(userCardPin) {
            return true
        } else {
            return false
        }
        
    }
    
    private func checkPINOfUser(_ pinCode: Int) -> Bool {
    
        if pinCode == user.userCardPin {
            return true
        } else {
            return false
        }
        
    }
    
    private func checkCardIDOfUser(_ cardID: String) -> Bool {
    
        if cardID == user.userCardID {
            return true
        } else {
            return false
        }
        
    }
    
    public func topUpPhoneBalanceCash(pay: Float) {
    
        user.userPhoneBalance += pay
        user.userCashAvailable -= pay
        
    }
    
    public func topUpPhoneBalanceCard(pay: Float) {
    
        user.userPhoneBalance += pay
        user.userCardBalance -= pay
        
    }
    
    public func getCashFromDeposit(cash: Float) {
    
        user.userCashAvailable += cash
        user.userBankDeposit -= cash
        
    }
    
    public func getCashFromCard(cash: Float) {
    
        user.userCashAvailable += cash
        user.userCardBalance -= cash
        
    }
    
    public func putCashDeposit(topUp: Float) {
    
        user.userBankDeposit += topUp
        user.userCashAvailable -= topUp
        
    }
    
    public func putCashCard(topUp: Float) {
    
        user.userCardBalance += topUp
        user.userCashAvailable -= topUp
        
    }
    
}


// Test block
var RamanKozar: UserData = User(userName: "Raman Kozar",
                                userCardID: "4409 7788 9321 8700",
                                userCardPin: 5678,
                                userPhoneNumber: "+48567897464",
                                userCashAvailable: 500.00,
                                userBankDeposit: 1000.00,
                                userPhoneBalance: 13.25,
                                userCardBalance: 300.00)

var bankPKOPankPolski = Bank(user: RamanKozar)

var terminalATMofPKO = ATM(userCardID: "4409 7788 9321 8700",
                           userCardPin: 5678,
                           someBank: bankPKOPankPolski,
                           currentAction: .withdrawMoneyFromDeposit(putOut: 1000.00))

var terminalATMofPKO1 = ATM(userCardID: "4409 7788 9321 8700",
                           userCardPin: 5678,
                           someBank: bankPKOPankPolski,
                           currentAction: .requestBalanceFromDeposit)



