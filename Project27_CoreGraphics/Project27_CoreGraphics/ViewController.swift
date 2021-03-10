//
//  ViewController.swift
//  Project27_CoreGraphics
//
//  Created by Blaine Dannheisser on 3/8/21.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var currentDrawType = 0

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        drawWord()
    }

    // MARK: Internal

    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1

        if currentDrawType > 7 {
            currentDrawType = 0
        }

        switch currentDrawType {
        case 0:
            drawRectangle()

        case 1:
            drawCircle()

        case 2:
            drawCheckerboard()

        case 3:
            drawRotatedSquares()

        case 4:
            drawLines()

        case 5:
            drawImagesAndText()

        case 6:
            drawNeutralFace()

        case 7:
            drawWord()

        default:
            break
        }
    }

    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)

            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            // adds the CGRect rectangele to the context's path to be drawn
            ctx.cgContext.addRect(rectangle)
            // draws the context's current path
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = img
    }

    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)

            ctx.cgContext.setFillColor(UIColor.blue.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)

            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        imageView.image = img
    }

    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.purple.cgColor)

            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        imageView.image = img
    }

    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            // move the transformation matrix half way into our image so that rotation point is the center
            ctx.cgContext.translateBy(x: 256, y: 256)

            let rotations = 16
            let amount = Double.pi / Double(rotations)

            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }

            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }

        imageView.image = img
    }

    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)

            var first = true
            var length: CGFloat = 256

            for _ in 0 ..< 256 {
                // .pi / 2 = 90 degrees
                ctx.cgContext.rotate(by: .pi / 2)

                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }

                length *= 0.99
            }

            ctx.cgContext.setStrokeColor(UIColor.blue.cgColor)
            ctx.cgContext.strokePath()
        }

        imageView.image = img
    }

    func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { _ in
            // define a paragraphy style that aligns text to the center
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            // create an attributes dictionary containing paragraph style and font
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]

            // wrap the attributes dict and string into an instance of NSAttributedString
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            // usesLineFragmentOrigin = line wrapping
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)

            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }

        imageView.image = img
    }

    func drawNeutralFace() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            // Face
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)

            // Left Eye
            let leftEye = CGRect(x: 140, y: 135, width: 60, height: 70)
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addEllipse(in: leftEye)
            ctx.cgContext.drawPath(using: .fillStroke)

            // Right Eye
            let rightEye = CGRect(x: 320, y: 135, width: 60, height: 70)
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            ctx.cgContext.addEllipse(in: rightEye)
            ctx.cgContext.drawPath(using: .fillStroke)

            // Mouth
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineWidth(20)
            ctx.cgContext.move(to: CGPoint(x: 140, y: 360))
            ctx.cgContext.addLine(to: CGPoint(x: 380, y: 360))
            ctx.cgContext.strokePath()
        }
        imageView.image = img
    }

    func drawWord() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 20, y: 20)
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            // T
            ctx.cgContext.move(to: CGPoint(x: 0, y: 5))
            ctx.cgContext.addLine(to: CGPoint(x: 80, y: 5))
            ctx.cgContext.move(to: CGPoint(x: 40, y: 5))
            ctx.cgContext.addLine(to: CGPoint(x: 40, y: 105))
            // W
            ctx.cgContext.move(to: CGPoint(x: 100, y: 5))
            ctx.cgContext.addLine(to: CGPoint(x: 120, y: 105))
            ctx.cgContext.addLine(to: CGPoint(x: 160, y: 40))
            ctx.cgContext.addLine(to: CGPoint(x: 200, y: 105))
            ctx.cgContext.addLine(to: CGPoint(x: 220, y: 5))
            // I
            ctx.cgContext.move(to: CGPoint(x: 240, y: 5))
            ctx.cgContext.addLine(to: CGPoint(x: 260, y: 5))
            ctx.cgContext.move(to: CGPoint(x: 250, y: 5))
            ctx.cgContext.addLine(to: CGPoint(x: 250, y: 105))
            ctx.cgContext.move(to: CGPoint(x: 240, y: 105))
            ctx.cgContext.addLine(to: CGPoint(x: 260, y: 105))
            // N
            ctx.cgContext.move(to: CGPoint(x: 280, y: 105))
            ctx.cgContext.addLine(to: CGPoint(x: 280, y: 5))
            ctx.cgContext.move(to: CGPoint(x: 280, y: 5))
            ctx.cgContext.addLine(to: CGPoint(x: 340, y: 105))
            ctx.cgContext.move(to: CGPoint(x: 340, y: 5))
            ctx.cgContext.addLine(to: CGPoint(x: 340, y: 105))

            ctx.cgContext.strokePath()
        }
        imageView.image = img
    }
}
