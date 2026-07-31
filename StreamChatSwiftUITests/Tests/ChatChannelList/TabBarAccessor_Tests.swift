//
// Copyright © 2026 Stream.io Inc. All rights reserved.
//

@testable import StreamChatSwiftUI
import XCTest

@MainActor final class TabBarAccessor_Tests: XCTestCase {
    private var tabBarController: UITabBarController!
    private var sut: TabBarAccessor.ViewController!

    private var tabBar: UITabBar { tabBarController.tabBar }

    override func setUp() {
        super.setUp()
        sut = TabBarAccessor.ViewController()
        let screen = UIViewController()
        screen.addChild(sut)
        sut.didMove(toParent: screen)
        tabBarController = UITabBarController()
        tabBarController.viewControllers = [screen]
    }

    override func tearDown() {
        sut = nil
        tabBarController = nil
        super.tearDown()
    }

    func test_tabBarAccessor_whenTabBarIsHidden_hidesTabBar() {
        // Given
        sut.viewDidAppear(false)

        // When
        sut.isTabBarHidden = true

        // Then
        XCTAssertTrue(tabBar.isHidden)
    }

    func test_tabBarAccessor_whenScreenIsVisible_showsTabBar() {
        // Given
        sut.viewDidAppear(false)
        sut.isTabBarHidden = true

        // When
        sut.isTabBarHidden = false

        // Then
        XCTAssertFalse(tabBar.isHidden)
    }

    func test_tabBarAccessor_whenScreenIsNotVisible_keepsTabBarHidden() {
        // Given
        sut.viewDidAppear(false)
        sut.isTabBarHidden = true
        sut.viewWillDisappear(false)

        // When
        sut.isTabBarHidden = false

        // Then
        XCTAssertTrue(tabBar.isHidden)
    }

    func test_tabBarAccessor_whenScreenBecomesVisibleAgain_showsTabBar() {
        // Given
        sut.viewDidAppear(false)
        sut.isTabBarHidden = true
        sut.viewWillDisappear(false)
        sut.isTabBarHidden = false

        // When
        sut.viewDidAppear(false)

        // Then
        XCTAssertFalse(tabBar.isHidden)
    }

    func test_tabBarAccessor_whenScreenStaysHidden_keepsTabBarHidden() {
        // Given
        sut.viewDidAppear(false)
        sut.isTabBarHidden = true
        sut.viewWillDisappear(false)
        sut.isTabBarHidden = false

        // When
        sut.isTabBarHidden = false

        // Then
        XCTAssertTrue(tabBar.isHidden)
    }

    func test_tabBarAccessor_whenVisibilityIsNotManaged_doesNotUpdateTabBar() {
        // Given
        tabBar.isHidden = true

        // When
        sut.viewDidAppear(false)

        // Then
        XCTAssertTrue(tabBar.isHidden)
    }

    func test_tabBarAccessor_whenTabBarIsFound_callsCallback() {
        // Given
        var foundTabBar: UITabBar?
        sut.callback = { foundTabBar = $0 }

        // When
        sut.viewWillAppear(false)

        // Then
        XCTAssertTrue(foundTabBar === tabBar)
    }

    func test_tabBarAccessor_whenTabBarIsNotAvailable_doesNotCallCallback() {
        // Given
        let detachedSut = TabBarAccessor.ViewController()
        var callbackCalled = false
        detachedSut.callback = { _ in callbackCalled = true }

        // When
        detachedSut.viewWillAppear(false)

        // Then
        XCTAssertFalse(callbackCalled)
    }
}
