// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit

// 8
final class TabTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    static let duration: TimeInterval = 1.25

    private let type: PresentationType
    private let firstViewController: LegacyGridTabViewController
    private let secondViewController: BrowserViewController
    private var selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect

    // 10
    init?(type: PresentationType, firstViewController: LegacyGridTabViewController, secondViewController: BrowserViewController, selectedCellImageViewSnapshot: UIView) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot

        guard let window = firstViewController.view.window ?? secondViewController.view.window,
            let selectedCell = firstViewController.selectedCell
            else { return nil }

        // 11
        self.cellImageViewRect = selectedCell.screenshotView.convert(selectedCell.screenshotView.bounds, to: window)
    }

    // 12
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }

    // 13
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 18
        let containerView = transitionContext.containerView

        // 19
        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }

        containerView.addSubview(toView)

        let controllerImage: UIImageView = .build { [weak self] imageView in
            imageView.image = self?.secondViewController.tabManager.selectedTab?.screenshot
        }

        // 21
        guard
            let selectedCell = firstViewController.selectedCell,
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let cellImageSnapshot = selectedCell.screenshotView.snapshotView(afterScreenUpdates: true),
            let controllerImageSnapshot = controllerImage.snapshotView(afterScreenUpdates: true)// 47
//            let closeButtonSnapshot = secondViewController.closeButton.snapshotView(afterScreenUpdates: true) // 53
            else {
                transitionContext.completeTransition(true)
                return
        }

        // SOPHIE - Close button not used - REMOVED

        let isPresenting = type.isPresenting

        // 40
        let backgroundView: UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor

        // 33
        if isPresenting {
            selectedCellImageViewSnapshot = cellImageSnapshot

            // 41
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = firstViewController.view.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
        }

        // 23
        toView.alpha = 0

        // 34
        // 42
        // 48
        // 54
        [backgroundView, selectedCellImageViewSnapshot, controllerImageSnapshot].forEach { containerView.addSubview($0) }

        // 25
        let controllerImageViewRect = controllerImage.convert(controllerImage.bounds, to: window)

        // 55
//        let closeButtonRect = secondViewController.closeButton.convert(secondViewController.closeButton.bounds, to: window)

        // 35
        [selectedCellImageViewSnapshot, controllerImageSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect

            // 59
            $0.layer.cornerRadius = isPresenting ? 12 : 0
            $0.layer.masksToBounds = true
        }

        // 36
        controllerImageSnapshot.alpha = isPresenting ? 0 : 1

        // 37
        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0

        // 27
        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                // 38
                self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                controllerImageSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect

                // 43
                fadeView.alpha = isPresenting ? 1 : 0

                // 60
                [controllerImageSnapshot, self.selectedCellImageViewSnapshot].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : 12
                }
            }

            // 39
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
            }

            // 57
//            UIView.addKeyframe(withRelativeStartTime: isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
//                closeButtonSnapshot.alpha = isPresenting ? 1 : 0
//            }
        }, completion: { _ in
            // 29
            self.selectedCellImageViewSnapshot.removeFromSuperview()
            controllerImageSnapshot.removeFromSuperview()

            // 44
            backgroundView.removeFromSuperview()

            // 30
            toView.alpha = 1

            // 31
            transitionContext.completeTransition(true)
        })
    }
}

// 14
enum PresentationType {
    case present
    case dismiss

    var isPresenting: Bool {
        return self == .present
    }
}
