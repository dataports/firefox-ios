// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

@testable import Client
import XCTest
import MozillaAppServices

class HistoryHighlightsDataAdaptorTests: XCTestCase {

    var subject: HistoryHighlightsDataAdaptor!
    var historyManager: MockHistoryHighlightsManager!
    var notificationCenter: MockNotificationCenter!
    var delegate: MockHistoryHighlightsDelegate!

    override func setUp() {
        super.setUp()

        historyManager = MockHistoryHighlightsManager()
        notificationCenter = MockNotificationCenter()
        delegate = MockHistoryHighlightsDelegate()

        let subject = HistoryHighlightsDataAdaptorImplementation(
            historyManager: historyManager,
            profile: MockProfile(),
            tabManager: MockTabManager(),
            notificationCenter: notificationCenter)
        subject.delegate = delegate
        notificationCenter.notifiableListener = subject
        self.subject = subject
    }

    override func tearDown() {
        super.tearDown()
        subject = nil
        historyManager = nil
        notificationCenter = nil
        delegate = nil
    }

    // Loads history on first launch with data
    func testInitialLoadWithHistoryData() {
        let item: HighlightItem = HistoryHighlight(score: 0, placeId: 0, url: "", title: "", previewImageUrl: "")
        historyManager.callGetHighlightsDataCompletion(result: [item])

        let results = subject.getHistoryHightlights()

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(historyManager.getHighlightsDataCallCount, 1)
        XCTAssertEqual(delegate.didLoadNewDataCallCount, 1)
    }

    // Loads history on first launch without data
    func testInitialLoadWithNoHistoryData() {
        historyManager.callGetHighlightsDataCompletion(result: [])

        let results = subject.getHistoryHightlights()

        XCTAssert(results.isEmpty)
        XCTAssertEqual(historyManager.getHighlightsDataCallCount, 1)
        XCTAssertEqual(delegate.didLoadNewDataCallCount, 1)
    }

    // Reloads for notification
    func testReloadDataOnNotification() {
        historyManager.callGetHighlightsDataCompletion(result: [])

        notificationCenter.post(name: .HistoryUpdated)

        let item1: HighlightItem = HistoryHighlight(score: 0, placeId: 0, url: "", title: "", previewImageUrl: "")
        let item2: HighlightItem = HistoryHighlight(score: 0, placeId: 0, url: "", title: "", previewImageUrl: "")
        historyManager.callGetHighlightsDataCompletion(result: [item1, item2])

        let results = subject.getHistoryHightlights()

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(historyManager.getHighlightsDataCallCount, 2)
        XCTAssertEqual(delegate.didLoadNewDataCallCount, 2)
    }
}