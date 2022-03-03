//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import UIKit

// TODO: move from here
public let supportedEmojis: [String: EmojiSource] = [
    "baldspin": .imageAsset("baldspin"),
    "baldyappp": .imageAsset("baldyappp"),
    "baldyikes": .imageAsset("baldyikes"),
    "baners": .imageAsset("baners"),
    "catjam": .imageAsset("catjam"),
    "checkers": .imageAsset("checkers"),
    "click": .imageAsset("click"),
    "coomtime": .imageAsset("coomtime"),
    "crawlers": .imageAsset("crawlers"),
    "deadlole": .imageAsset("deadlole"),
    "deskchan": .imageAsset("deskchan"),
    "eato": .imageAsset("eato"),
    "eddiebaldmansmash": .imageAsset("eddiebaldmansmash"),
    "eddieknead": .imageAsset("eddieknead"),
    "eekum": .imageAsset("eekum"),
    "fubaldi": .imageAsset("fubaldi"),
    "gamba": .imageAsset("gamba"),
    "gawkgawk": .imageAsset("gawkgawk"),
    "guitartime": .imageAsset("guitartime"),
    "humpers": .imageAsset("humpers"),
    "hypernodders": .imageAsset("hypernodders"),
    "hypernopers": .imageAsset("hypernopers"),
    "hyperpeepod": .imageAsset("hyperpeepod"),
    "johnsouls": .imageAsset("johnsouls"),
    "kissabrother": .imageAsset("kissabrother"),
    "kissapregomie": .imageAsset("kissapregomie"),
    "komodochomp": .imageAsset("komodochomp"),
    "lgiggle": .imageAsset("lgiggle"),
    "mariorun": .imageAsset("mariorun"),
    "moon2bass": .imageAsset("moon2bass"),
    "noted": .imageAsset("noted"),
    "peepeegachat": .imageAsset("peepeegachat"),
    "peepees": .imageAsset("peepees"),
    "peepersd": .imageAsset("peepersd"),
    "peepocheering": .imageAsset("peepocheering"),
    "peepogolfclap": .imageAsset("peepogolfclap"),
    "peeponarusprint": .imageAsset("peeponarusprint"),
    "peeposhy": .imageAsset("peeposhy"),
    "peeposteer": .imageAsset("peeposteer"),
    "pepelepsy": .imageAsset("pepelepsy"),
    "pepemetal": .imageAsset("pepemetal"),
    "petthebaldie": .imageAsset("petthebaldie"),
    "pettheeddie": .imageAsset("pettheeddie"),
    "pettheqynoa": .imageAsset("pettheqynoa"),
    "parrot": .imageAsset("parrot"),
    "pukers": .imageAsset("pukers"),
    "raremoon": .imageAsset("raremoon"),
    "refracting": .imageAsset("refracting"),
    "robpls": .imageAsset("robpls"),
    "shruggers": .imageAsset("shruggers"),
    "shushers": .imageAsset("shushers"),
    "slap": .imageAsset("slap"),
    "solarflare": .imageAsset("solarflare"),
    "soulshroom": .imageAsset("soulshroom"),
    "speeders": .imageAsset("speeders"),
    "tanties": .imageAsset("tanties"),
    "teatime": .imageAsset("teatime"),
    "teatime2": .imageAsset("teatime2"),
    "tinyteeth": .imageAsset("tinyteeth"),
    "twerkers": .imageAsset("twerkers"),
    "vanish": .imageAsset("vanish"),
    "vibers": .imageAsset("vibers"),
    "wowers": .imageAsset("wowers"),
    "yappp": .imageAsset("yappp"),
    "bropls": .imageAsset("bropls"),
    "feelsbadman": .imageAsset("feelsbadman.png")
]

class InputTextView: UITextView {
    @Injected(\.colors) private var colors
    
    /// Label used as placeholder for textView when it's empty.
    open private(set) lazy var placeholderLabel: UILabel = UILabel()
        .withoutAutoresizingMaskConstraints
        
    /// The minimum height of the text view.
    /// When there is no content in the text view OR the height of the content is less than this value,
    /// the text view will be of this height
    open var minimumHeight: CGFloat {
        34.0
    }
    
    override open var attributedText: NSAttributedString! {
        didSet {
            textDidChangeProgrammatically()
        }
    }
    
    /// The constraint responsible for setting the height of the text view.
    open var heightConstraint: NSLayoutConstraint?
    
    /// The maximum height of the text view.
    /// When the content in the text view is greater than this height, scrolling will be enabled and the text view's height will be restricted to this value
    open var maximumHeight: CGFloat {
        76.0
    }
        
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        
        setUp()
        setUpLayout()
        setUpAppearance()
    }
        
    open func setUp() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        
        configureEmojis(supportedEmojis, rendering: .lowQuality)
    }
    
    open func setUpAppearance() {
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 8
        font = UIFont.preferredFont(forTextStyle: .body)
        textColor = colors.text
        textAlignment = .natural
        
        placeholderLabel.font = font
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = colors.subtitleText
    }
    
    open func setUpLayout() {
        embed(
            placeholderLabel,
            insets: .init(
                top: .zero,
                leading: directionalLayoutMargins.leading,
                bottom: .zero,
                trailing: .zero
            )
        )
        placeholderLabel.pin(anchors: [.centerY], to: self)
        
        heightConstraint = heightAnchor.constraint(equalToConstant: minimumHeight)
        heightConstraint?.isActive = true
        isScrollEnabled = false
    }

    open func textDidChangeProgrammatically() {
        delegate?.textViewDidChange?(self)
        handleTextChange()
    }
        
    @objc open func handleTextChange() {
        placeholderLabel.isHidden = !text.isEmpty
        setTextViewHeight()
    }

    open func setTextViewHeight() {
        var heightToSet = minimumHeight

        if contentSize.height <= minimumHeight {
            heightToSet = minimumHeight
        } else if contentSize.height >= maximumHeight {
            heightToSet = maximumHeight
        } else {
            heightToSet = contentSize.height
        }

        heightConstraint?.constant = heightToSet
        isScrollEnabled = heightToSet > minimumHeight
        layoutIfNeeded()
    }
}
