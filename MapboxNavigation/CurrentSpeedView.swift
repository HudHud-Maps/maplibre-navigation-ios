import MapboxCoreNavigation
import MapboxDirections
import UIKit

@IBDesignable
@objc(MBCurrentSpeedView)
open class CurrentSpeedView: UIView {
    private(set) lazy var label: UILabel = .forAutoLayout()
    public var speed: Int? {
        didSet {
            if let speed {
                self.label.attributedText = self.attributedString(for: speed)
            } else {
                self.label.attributedText = nil
            }
        }
    }
	
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
	
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
	
    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
		
        if #available(iOS 13.0, *) {
            self.backgroundColor = .systemBackground
        } else {
            self.backgroundColor = .white
        }
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.masksToBounds = true
		
        self.label.numberOfLines = 2
        self.label.attributedText = self.attributedString(for: 80)
        self.addSubview(self.label)
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
	
    override public func layoutSubviews() {
        super.layoutSubviews()
		
        self.layer.cornerRadius = min(self.bounds.size.width, self.bounds.size.height) / 2.0
    }
}

// MARK: - Private

private extension CurrentSpeedView {
    func attributedString(for speed: Int) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.paragraphSpacing = -4
		
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: String(format: "%li", speed), attributes: [
            .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
            .paragraphStyle: paragraph
        ]))
        attributedString.append(NSAttributedString(string: "\n"))
        attributedString.append(NSAttributedString(string: "KM", attributes: [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .paragraphStyle: paragraph
        ]))
		
        return attributedString
    }
}
