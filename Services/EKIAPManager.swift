//
//  IAPManager.swift
//  Dating
//
//  Created by Eilon Krauthammer on 13/02/2020.
//  Copyright © 2020 Eilon Krauthammer. All rights reserved.
//

import Foundation
import StoreKit

protocol IAPDelegate: NSObjectProtocol {
    func didFetch(products: [Product])
    
    // Purchasing
    func purchaseSucceeded()
    func purchaseRestored()
    func purchaseFailed()
}

/// A simplified `SKProduct` object.
struct Product {
    let productId, title, price: String
}

final class IAPManager: NSObject {
    
    public weak var delegate: IAPDelegate?
    public var productIds = [String]()
    
    private var iapProducts = [SKProduct]()
    
    public convenience init(productIds: [String]) {
        self.init()
        self.productIds = productIds
    }
    
    public func startFetchingProducts() {
        guard productIds.count > 0 else { print("No products provided."); return }
        let productIdentifiers = Set(productIds)
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    public func purchaseProduct(_ product: Product) {
        guard let product = iapProducts.first(where: { $0.productIdentifier == product.productId }) else { print("Invalid product."); return }
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
        } else {
            print("Device cannot make payments.")
        }
    }
}

extension IAPManager : SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else { print("No products found."); return }
        var products = [Product]()
        
        iapProducts = response.products
        for product in response.products {
            // Get price
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = product.priceLocale
            guard let price = numberFormatter.string(from: product.price) else { continue }
            
            products.append(.init(productId: product.productIdentifier, title: product.localizedTitle, price: price))
        }
        
        delegate?.didFetch(products: products)
    }
}

extension IAPManager : SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            defer { SKPaymentQueue.default().finishTransaction(transaction) }
            switch transaction.transactionState {
                case .purchased:
                    delegate?.purchaseSucceeded()
                case .restored:
                    delegate?.purchaseRestored()
                case .failed:
                    delegate?.purchaseFailed()
                default: break
            }
        }
    }
}
