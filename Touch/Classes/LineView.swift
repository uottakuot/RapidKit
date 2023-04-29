// MIT License
//
// Copyright (c) Uottakuot Software
// https://github.com/uottakuot/RapidKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

public class LineView: UIView {
    public struct LineDash {
        public var phase: CGFloat
        
        public var lengths: [CGFloat]
        
        public init(phase: CGFloat, lengths: [CGFloat]) {
            self.phase = phase
            self.lengths = lengths
        }
    }
    
    public var lineColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var lineDash: LineDash? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    public init() {
        super.init(frame: .zero)
        
        commonInit()
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let isHorizontal = rect.size.width >= rect.size.height
        let start = CGPoint(x: isHorizontal ? rect.origin.x : rect.origin.x + rect.size.width / 2,
                            y: isHorizontal ? rect.origin.y + rect.size.height / 2 : rect.origin.y)
        let end = CGPoint(x: isHorizontal ? rect.origin.x + rect.size.width : rect.origin.x + rect.size.width / 2,
                          y: isHorizontal ? rect.origin.y + rect.size.height / 2 : rect.origin.y + rect.size.height)
        
        let lineWidth = isHorizontal ? rect.size.height : rect.size.width
        context.setLineWidth(lineWidth)
        
        if let lineDash = self.lineDash {
            context.setLineDash(phase: lineDash.phase, lengths: lineDash.lengths)
        }
        
        lineColor.setStroke()
        
        context.move(to: start)
        context.addLine(to: end)
        context.strokePath()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
    }
}
