//
//  ToolSelector.swift
//  Drawy
//
//  Created by Gal Orlanczyk on 10/01/2018.
//  Copyright © 2018 GO. All rights reserved.
//

import UIKit

@IBDesignable class ToolSelector: UIView {
    
    weak var view: UIView!
    
    @IBOutlet weak var toolTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var toolPreview: ToolView!
    @IBOutlet weak var presetColorsStackView: UIStackView!
    
    private var selectedTool: Tool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience init(frame: CGRect = CGRect.zero, tool: Tool) {
        self.init(frame: frame)
        self.setup(with: tool, animated: false)
    }
    
    func commonInit() {
        guard let view = Bundle.main.loadNibNamed("ToolSelector", owner: self, options: nil)?.first as? UIView else { return }
        self.view = view
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.pin(to: self)
        self.redSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        self.greenSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        self.blueSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        self.sizeSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .valueChanged)
        // setup segmented control
        self.toolTypeSegmentedControl.removeAllSegments()
        for pattern in Tool.Pattern.all {
            self.toolTypeSegmentedControl.insertSegment(withTitle: pattern.title, at: self.toolTypeSegmentedControl.numberOfSegments, animated: false)
        }
        
        presetColorsStackView.subviews.forEach {
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presetColorTapped(gesture:))))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view.layer.shadowPath = UIBezierPath(rect: view.frame).cgPath
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 0.7
        self.view.layer.shadowRadius = 5
        self.view.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

/************************************************************/
// MARK: - Actions
/************************************************************/

private extension ToolSelector {
    
    @objc func sliderValueChanged(slider: UISlider) {
        if slider == self.redSlider || slider == self.greenSlider || slider == self.blueSlider  {
            let color = UIColor(red: CGFloat(self.redSlider.value), green: CGFloat(self.greenSlider.value), blue: CGFloat(self.blueSlider.value), alpha: 1)
            self.toolPreview.strokeColor = color
        } else if slider == self.sizeSlider {
            self.toolPreview.lineWidth = CGFloat(self.sizeSlider.value)
        }
    }
    
    @objc func presetColorTapped(gesture: UITapGestureRecognizer) {
        guard let colorView = gesture.view as? ColorView else { return }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        colorView.fillColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        self.redSlider.setValue(Float(r), animated: true)
        self.greenSlider.setValue(Float(g), animated: true)
        self.blueSlider.setValue(Float(b), animated: true)
        // invoke slider value change action handler
        self.sliderValueChanged(slider: self.redSlider)
    }
}

/************************************************************/
// MARK: - Internal Implemenation
/************************************************************/

extension ToolSelector {
    
    func setup(with tool: Tool, animated: Bool) {
        self.selectedTool = tool
        // setup segmented control
        for (index, pattern) in Tool.Pattern.all.enumerated() {
            if tool.pattern == pattern {
                self.toolTypeSegmentedControl.selectedSegmentIndex = index
            }
        }
        // setup sliders
        self.redSlider.setValue(Float(tool.red), animated: animated)
        self.greenSlider.setValue(Float(tool.green), animated: animated)
        self.blueSlider.setValue(Float(tool.blue), animated: animated)
        self.sizeSlider.setValue(Float(tool.width), animated: animated)
        // setup tool view
        self.toolPreview.preview(tool: tool)
    }
    
    func getToolFromSelection() -> Tool {
        let selectedSegmentTitle = self.toolTypeSegmentedControl.titleForSegment(at: self.toolTypeSegmentedControl.selectedSegmentIndex)
        let pattern = Tool.Pattern(title: selectedSegmentTitle ?? Tool.Pattern.regular.title)
        let color = UIColor(red: CGFloat(self.redSlider.value), green: CGFloat(self.greenSlider.value), blue: CGFloat(self.blueSlider.value), alpha: 1)
        return Tool(pattern: pattern, width: CGFloat(self.sizeSlider.value), alpha: 1, color: color)
    }
}
