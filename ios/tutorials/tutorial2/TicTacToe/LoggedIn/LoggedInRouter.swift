//
//  LoggedInRouter.swift
//  TicTacToe
//
//  Created by Chang gyun Park on 2020/06/19.
//  Copyright © 2020 Uber. All rights reserved.
//

import RIBs

protocol LoggedInInteractable: Interactable, OffGameListener, TicTacToeListener {
    var router: LoggedInRouting? { get set }
    var listener: LoggedInListener? { get set }
}

protocol LoggedInViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class LoggedInRouter: Router<LoggedInInteractable>, LoggedInRouting {
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: LoggedInInteractable, viewController: LoggedInViewControllable,
         offGameBuilder: OffGameBuildable,
         ticTacToeBuilder: TicTacToeBuildable) {
        self.viewController = viewController
        self.offGameBuilder = offGameBuilder
        self.ticTacToeBuilder = ticTacToeBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }
    
    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
        if let currentChild = currentChild {
            viewController.dismiss(viewController: currentChild.viewControllable)
        }
    }
    
    // MARK: - Private
    
    private let viewController: LoggedInViewControllable
    private let offGameBuilder: OffGameBuildable
    private let ticTacToeBuilder: TicTacToeBuildable
    private var currentChild: ViewableRouting?
    
    private var offGame: ViewableRouting?
    
    override func didLoad() {
        super.didLoad()
        attachOffGame()
    }
    
    private func attachOffGame() {
        let offGame = offGameBuilder.build(withListener: interactor)
        self.currentChild = offGame
        self.offGame = offGame
        attachChild(offGame)
        viewController.present(viewController: offGame.viewControllable)
    }
    
    func routeToTicTacToe() {
        if let offGame = self.offGame {
            detachChild(offGame)
            viewController.dismiss(viewController: offGame.viewControllable)
            self.offGame = nil
        }
        
        let ticTacToe = ticTacToeBuilder.build(withListener: interactor)
        self.currentChild = ticTacToe
        attachChild(ticTacToe)
        viewController.present(viewController: ticTacToe.viewControllable)
    }
    
    func routeToOffGame() {
        detachCurrentChild()
        attachOffGame()
    }
    
    private func detachCurrentChild() {
        if let currentChild = currentChild {
            detachChild(currentChild)
            viewController.dismiss(viewController: currentChild.viewControllable)
        }
    }
}
