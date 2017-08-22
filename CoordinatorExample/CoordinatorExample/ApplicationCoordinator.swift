//
//  ApplicationCoordinator.swift
//  CoordinatorExample
//
//  Created by Aleksandar Vacić on 4.3.17..
//  Copyright © 2017. Radiant Tap. All rights reserved.
//

import UIKit
import Coordinator

final class AppCoordinator: NavigationCoordinator, NeedsDependency {
	var dependencies: AppDependency? {
		didSet { updateChildCoordinatorDependencies() }
	}



	//	AppCoordinator is root coordinator, top-level object in the UI hierarchy
	//	It keeps references to all the data source objects
	var dataManager: DataManager!
	var catalogManager: CatalogManager!


	//	Declaration of all possible Coordinators
	//	== sections inside the app

	enum Section {
		case catalog(CatalogCoordinator.Page?)
		case cart(CartCoordinator.Page?)
		case account(AccountCoordinator.Page?)
	}
	var section: Section = .catalog(.home)



	//	Coordinator lifecycle

	override func start(with completion: @escaping (Coordinator<UINavigationController>) -> Void = {_ in}) {
		//	prepare managers
		let apiManager = IvkoService.shared
		dataManager = DataManager(apiManager: apiManager)
		catalogManager = CatalogManager(dataManager: dataManager)

		dependencies = AppDependency(apiManager: apiManager,
		                             dataManager: dataManager,
		                             catalogManager: catalogManager)
		//	finally ready
		super.start(with: completion)

		//	now, here comes the logic which 
		//	content Coordinator to load
		setupActiveSection()
	}



	//	MARK:- CoordinatingResponder

	override func cartBuyNow(_ product: Product, sender: Any?) {
		//	re-route to CartManager and/or CartCoordinator

		let ac = UIAlertController(title: nil, message: "cart-BuyNow", preferredStyle: .alert)
		ac.addAction( UIAlertAction(title: "OK", style: .default) )
		rootViewController.present(ac, animated: true)
	}

	override func cartAdd(product: Product, color: ColorBox, sender: Any?, completion: (Bool) -> Void) {
		//	re-route to CartManager and/or CartCoordinator

		let ac = UIAlertController(title: nil, message: "cart-Add", preferredStyle: .alert)
		ac.addAction( UIAlertAction(title: "OK", style: .default) )
		rootViewController.present(ac, animated: true)
	}

	override func cartToggle(sender: Any?) {

		let ac = UIAlertController(title: nil, message: "cart-Toggle", preferredStyle: .alert)
		ac.addAction( UIAlertAction(title: "OK", style: .default) )
		rootViewController.present(ac, animated: true)
	}
}


fileprivate extension AppCoordinator {
	//	MARK:- Internal

	func setupActiveSection(_ enforcedSection: Section? = nil) {
		if let enforcedSection = enforcedSection {
			section = enforcedSection
		}
		switch section {
		case .catalog(let page):
			showCatalog(page)
		case .cart(let page):
			showCart(page)
		case .account(let page):
			showAccount(page)
		}
	}

	func showCatalog(_ page: CatalogCoordinator.Page?) {
		let identifier = String(describing: CatalogCoordinator.self)
		//	if Coordinator is already created...
		if let c = childCoordinators[identifier] as? CatalogCoordinator {
			c.dependencies = dependencies
			//	just display this page
			if let page = page {
				c.display(page: page)
			}
			return
		}

		//	otherwise, create the coordinator and start it
		let c = CatalogCoordinator(rootViewController: rootViewController)
		c.dependencies = dependencies
		if let page = page {
			c.page = page
		}
		startChild(coordinator: c)
	}

	func showCart(_ page: CartCoordinator.Page?) {

	}

	func showAccount(_ page: AccountCoordinator.Page?) {
	}
}
