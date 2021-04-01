//
//  Pages.swift
//  ImproveTheNews
//
//  Created by Mindy Long on 8/22/20.
//  Copyright © 2020 Mindy Long. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class FAQPage: UIViewController {
    
    let dismiss = UIButton(title: "Back", titleColor: .label, font: UIFont(name: "OpenSans-Bold", size: 17)!)
    let pagetitle = UILabel(text: "FAQ", font: UIFont(name: "PTSerif-Bold", size: 40), textColor: accentOrange, textAlignment: .left, numberOfLines: 1)
    
    let textView = UITextView()
    let text = """
What is this?

This is a news aggregator developed by a group of researchers at MIT and elsewhere to give you control of your news consumption, as explained in this video.

Just as it’s healthier to choose what you eat deliberately than impulsively, it’s more empowering to chose your news diet deliberately on this site than to randomly read what marketers and machine-learning algorithms elsewhere predict that you’ll impulsively click on. You can make these deliberate choices about topic, bias, style, etc. by adjusting sliders described under "How the sliders work".

How is this funded?

We have an ongoing research project led by Prof. Max Tegmark on machine learning for news classification.  Huge thanks to Mindy Long for creating this app that shares the results, to Kirti Shilwant and Federico López for further developing it, and to Tim Woolley for awesome design help.
Since the news aggregation and classification is fully automated, running it as an ad-free public service costs us nothing except our cloud computing bill, which at our current (April 2015) traffic levels comes to less than $10/month.

How does it work?

We’re planning to open-source our machine-learning algorithms on GitHub once they’re accepted for publication.

Won’t this contribute to filter bubbles?

There’s a rich scientific literature on how click-optimizing algorithms at Facebook, Google, etc. have polarized and divided society into groups that each get exposed only to ideas they already agree with. So won’t giving people choices such as the left-right slider on this site exacerbate the problem? Recent work from David Rand’s MIT group suggests the opposite: that people become less susceptible to fake news and bias when given easy access to a range of information, enabling what Kahneman calls “system 2” deliberation instead of “system 1” impulsive clicking and reacting. Their work also suggests that many people are interested in opinions disagreeing with their own, if expressed in a nuanced and respectful way, but are rarely exposed to this. So perhaps we should not rush to blame consumers rather than providers of news.

What is your privacy policy?

You’ll find our privacy policy under our "Privacy Policy" section.

How can I contact you with feedback?

This is work in progress, and as you can easily tell, there’s lots of room for improvement! Please help us make it better by providing your feedback in our "Feedback" section.
"""
    let bold = ["What is this?", "How is this funded?", "How does it work?", "Won’t this contribute to filter bubbles?", "What is your privacy policy?", "How can I contact you with feedback?"] as [NSString]
    let paths = ["https://www.youtube.com/watch?v=PRLF17Pb6vo","https://space.mit.edu/home/tegmark/home.html", "https://psyarxiv.com/29b4j"]
    let linked = ["this video", "Max Tegmark", "Recent work from David Rand’s MIT group"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        configureView()
    }
    
    func configureView() {
        
        view.addSubview(pagetitle)
        pagetitle.translatesAutoresizingMaskIntoConstraints = false
        //pagetitle.backgroundColor = .cyan
        NSLayoutConstraint.activate([
            pagetitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            pagetitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            pagetitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70)
        ])
        pagetitle.adjustsFontSizeToFitWidth = true
        
        dismiss.titleLabel?.textColor = accentOrange
        view.addSubview(dismiss)
        dismiss.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismiss.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 7),
            dismiss.leadingAnchor.constraint(equalTo: pagetitle.trailingAnchor),
            dismiss.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
        textView.attributedText = prettifyText(fullString: text as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths, linkedSubstrings: linked, accented: [])
        textView.textColor = articleHeadLineColor
        textView.backgroundColor = .black
        textView.isEditable = false
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            textView.topAnchor.constraint(equalTo: self.pagetitle.bottomAnchor, constant: 5),
        ])
        
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}


class SliderDoc2: UIViewController {
    
    let dismiss = UIButton(title: "Back", titleColor: .label, font: UIFont(name: "OpenSans-Bold", size: 17)!)
    
    let pagetitle = UILabel(text: "How the sliders work",
            font: UIFont(name: "PTSerif-Bold", size: 40),
            textColor: accentOrange, textAlignment: .left,
            numberOfLines: 1)
    
    // text 1
    let textView1 = UITextView()
    let text1 = """

    The sliders lets you choose your news diet the way you aim to choose your food: deliberately rather than impulsively (see this video demo).
    
    1. Topic sliders: What topic mix do you want?

    Each page shows a topic (say “Crime & Justice”) and subtopics (say “Crime”, “Civil Liberties”, etc.) with a slider for each. The green background shows what fraction of the total news flow out there is about each subtopic, and you can use the sliders to adjust whether you’d like more or less than that. This affects the ordering of the subtopics and also the news mix at the top and elsewhere on the site. Click the update button to see things change.
    
    2. Bias sliders: What spin do you want?

    Two sliders let you choose the bias of your news sources. The left-right slider uses a classification of media outlets based on political leaning, mainly from here. The pro-establishment slider classifies media outlets based on how close they are to power (see, e.g., Wikipedia’s lists of left, libertarian & right alternative media & this classification): does the news source normally accept or challenge claims by powerful entities such as the government and large corporations? Rather than leaving them alone, you’ll probably enjoy spicing things up by occasionally sliding them to see what those you disagree with cover various topics.
    """
    let paths1 = ["https://www.youtube.com/watch?v=PRLF17Pb6vo","https://www.allsides.com/media-bias/media-bias-ratings"]
    let linked1 = ["see this video demo"," here"]
    let accented1 = ["left-right slider", "pro-establishment slider"]
    
    
    
    
    
    
    
    let resetButton = UIButton(title: "Reset sliders to default", titleColor: accentOrange)
    
    let textView = UITextView()
    let text = """

The sliders lets you choose your news diet the way you aim to choose your food: deliberately rather than impulsively (see this video demo).

1. Topic sliders: What topic mix do you want?

Each page shows a topic (say “Crime & Justice”) and subtopics (say “Crime”, “Civil Liberties”, etc.) with a slider for each. The green background shows what fraction of the total news flow out there is about each subtopic, and you can use the sliders to adjust whether you’d like more or less than that. This affects the ordering of the subtopics and also the news mix at the top and elsewhere on the site. Click the update button to see things change.

2. Bias sliders: What spin do you want?

Two sliders let you choose the bias of your news sources. The left-right slider uses a classification of media outlets based on political leaning, mainly from here. The pro-establishment slider classifies media outlets based on how close they are to power (see, e.g., Wikipedia’s lists of left, libertarian & right alternative media & this classification): does the news source normally accept or challenge claims by powerful entities such as the government and large corporations? Rather than leaving them alone, you’ll probably enjoy spicing things up by occasionally sliding them to see what those you disagree with cover various topics.

3. Style sliders: What writing style do you want?

Irrespective of topic and spin, two sliders let you choose your preferred writing style. The nuance slider ranges from inflammatory writing with crass low-blows, ad-hominem attacks, and deliberately ugly photos of criticized people, to nuanced writing in a more respectful style. The depth slider ranges from short breezy pieces with unsubstantiated claims to in-depth coverage/analysis/expose providing good context, careful sourcing, and often detailed numbers/graphics and a more academic style.

4. Shelf-life slider: Do you want evergreen or fresh?

The shelf-life slider ranges from fast-expiring topics such as celebrity gossip and “so-and-so tweeted the following” to evergreen pieces (high-impact/novel analysis) that are likely to remain relevant for a long time to come. The recent slider lets you choose whether to focus on golden oldies or the very latest news. Note that your news gets ranked by combining the match to all the sliders, so we can give you the very latest news only at the cost of paying slightly less attention to the other sliders.
"""
    let bold = ["1. Topic sliders: What topic mix do you want?",  "2. Bias sliders: What spin do you want?", "3. Style sliders: What writing style do you want?", "4. Shelf-life slider: Do you want evergreen or fresh?", ] as [NSString]
    let paths = ["https://www.youtube.com/watch?v=PRLF17Pb6vo","https://www.allsides.com/media-bias/media-bias-ratings", "https://swprs.org/media-navigator/"]
    let linked = ["see this video demo"," here", "this"]
    let accented = ["left-right slider", "pro-establishment slider", "nuance slider", "depth slider", "shelf-life slider", "recent slider"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        configureView()
    }
    
    func configureView() {
        // How the sliders work (orange TITLE)
        view.addSubview(pagetitle)
        pagetitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagetitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            pagetitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            pagetitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70)
        ])
        pagetitle.adjustsFontSizeToFitWidth = true
        
        // BACK button
        dismiss.titleLabel?.textColor = accentOrange
        view.addSubview(dismiss)
        dismiss.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismiss.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 7),
            dismiss.leadingAnchor.constraint(equalTo: pagetitle.trailingAnchor),
            dismiss.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
        textView1.attributedText = prettifyText(fullString: text1 as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths1, linkedSubstrings: linked1, accented: accented1)
        textView1.textColor = articleHeadLineColor
        textView1.backgroundColor = .black
        textView1.isEditable = false
        view.addSubview(textView1)
        textView1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            textView1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            textView1.topAnchor.constraint(equalTo: self.pagetitle.bottomAnchor, constant: 5),
        ])
        
        // Sliders: Political Stance
        let sliders1 = sliderView(title: "Political Stance", leftLabel: "LEFT", rightLabel: "RIGHT")
        view.addSubview(sliders1)
        NSLayoutConstraint.activate([
            sliders1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            sliders1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            sliders1.topAnchor.constraint(equalTo: self.textView1.bottomAnchor, constant: 5),
        ])
        
        resetButton.layer.borderColor = accentOrange.cgColor
        resetButton.layer.borderWidth = 3
        resetButton.layer.cornerRadius = 10
        resetButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        view.addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            resetButton.topAnchor.constraint(equalTo: sliders1.bottomAnchor, constant: 10),
            resetButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    /*
    func configureView2() {
        
        // How the sliders work
        view.addSubview(pagetitle)
        pagetitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagetitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            pagetitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            pagetitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70)
        ])
        pagetitle.adjustsFontSizeToFitWidth = true
        
        // BACK button
        dismiss.titleLabel?.textColor = accentOrange
        view.addSubview(dismiss)
        dismiss.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismiss.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 7),
            dismiss.leadingAnchor.constraint(equalTo: pagetitle.trailingAnchor),
            dismiss.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
        textView.attributedText = prettifyText(fullString: text as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths, linkedSubstrings: linked, accented: accented)
        textView.textColor = articleHeadLineColor
        textView.backgroundColor = .black
        textView.isEditable = false
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            textView.topAnchor.constraint(equalTo: self.pagetitle.bottomAnchor, constant: 5),
        ])
        
        
        
        resetButton.layer.borderColor = accentOrange.cgColor
        resetButton.layer.borderWidth = 3
        resetButton.layer.cornerRadius = 10
        resetButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 20)
        resetButton.addTarget(self, action: #selector(reset), for: .touchUpInside)
        view.addSubview(resetButton)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            resetButton.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 10),
            resetButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    */
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func reset() {
        resetToDefaults()
    }
    
    func sliderView(title: String, leftLabel: String, rightLabel: String) -> UIView {
        let view = UIView(frame: .zero)
        let screenSize = UIScreen.main.bounds
        
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 70),
            view.widthAnchor.constraint(equalToConstant: screenSize.size.width)
        ])
        
        return view
    }
}



class PrivacyPolicy: UIViewController {
    
    let dismiss = UIButton(title: "Back", titleColor: .label, font: UIFont(name: "OpenSans-Bold", size: 17)!)
    let pagetitle = UILabel(text: "Privacy Policy", font: UIFont(name: "PTSerif-Bold", size: 40), textColor: accentOrange, textAlignment: .left, numberOfLines: 1)
    
    let textView = UITextView()
    let text = """
WHAT PERSONAL DATA WE COLLECT AND WHY WE COLLECT IT
This site is provided as a free public service with no commercial aspirations whatsoever, so we will never share personal data about you with anybody unless legally forced to. The hosting provider for the website (currently AWS) may store IP addresses for security reasons and to maintain the integrity of the hosting platform. These are deleted when they are no longer needed.

Cookies
We use cookies to store your slider settings for as long as possible, to save you the hassle of re-setting them every time you return to the site. The length of time with which the cookies remain in your browser is also determined by the user preferences set in your browser.

Analytics
To prevent server overload,  track site growth and research usage patterns, we keep a secure permanent log of site visits consisting of access times, pages visited, IP addresses and slider settings. These data will never be shared, but high-level analysis of user interests may be used for future research, for example to determine whether user interest in various news topics differs from the proportions in which these topics are written about in media.

Embedded and linked content from other websites
All articles you may read as a result of visiting our site are hosted on external news sites, so from a privacy perspective, reading them is equivalent to visiting those sites directly. These news sites may collect data about you, use cookies, embed additional third-party tracking, and monitor your interaction with that embedded content, including tracing your interaction with embedded content if you have an account and are logged in to that website.

WHO WE SHARE YOUR DATA WITH
We will not share your data unless legally forced to.

HOW LONG WE RETAIN YOUR DATA
If you fill out the feedback form, your feedback and its metadata are retained indefinitely, so we can keep track of any suggestions you may have and hopefully implement them. We also do not delete the above-mentioned analytics data, to keep open the possibility of future research.

WHAT RIGHTS YOU HAVE OVER YOUR DATA
If you have used this site, you can use our feedback form to request to receive an exported file of all data we hold about you. You can also request that we erase any personal data we hold about you. If you any privacy-specific concerns, please fill out our feedback form.

ADDITIONAL INFORMATION
How we protect your data
Any data you’ve provided us is stored on a secure server.

Data breach procedures we have in place
If a data breach occurs on one of our servers, we cannot email our users about it since we do not collect names or contact information.

Third parties we receive data from
We do not receive data from third parties.

Automated decision making and/or profiling we do with user data
We do not use user data for automated decision making or profiling.

Industry regulatory disclosure requirements
We are not part of a regulated industry.
"""
    let bold = ["WHAT PERSONAL DATA WE COLLECT AND WHY WE COLLECT IT","Embedded and linked content from other websites", "Cookies", "Analytics", "WHO WE SHARE YOUR DATA WITH", "HOW LONG WE RETAIN YOUR DATA", "WHAT RIGHTS YOU HAVE OVER YOUR DATA", "Data breach procedures we have in place", "ADDITIONAL INFORMATION", "Third parties we receive data from", "Automated decision making and/or profiling we do with user data", "Industry regulatory disclosure requirements"] as [NSString]
    let paths = ["https://www.allsides.com/media-bias/media-bias-ratings"]
    let linked = ["here"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        configureView()
    }
    
    func configureView() {
        
        view.addSubview(pagetitle)
        pagetitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pagetitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            pagetitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            pagetitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70)
        ])
        pagetitle.adjustsFontSizeToFitWidth = true
        
        dismiss.titleLabel?.textColor = accentOrange
        view.addSubview(dismiss)
        dismiss.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismiss.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 7),
            dismiss.leadingAnchor.constraint(equalTo: pagetitle.trailingAnchor),
            dismiss.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
        let bolded = prettifyText(fullString: text as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths, linkedSubstrings: linked, accented: [])
        
        textView.attributedText = bolded
        textView.textColor = articleHeadLineColor
        textView.backgroundColor = .black
        textView.isEditable = false
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            textView.topAnchor.constraint(equalTo: self.pagetitle.bottomAnchor, constant: 5),
        ])
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

// --------------
class ContactPage: UIViewController, UITextViewDelegate {
    
    let dismiss = UIButton(title: "Back", titleColor: .label, font: UIFont(name: "OpenSans-Bold", size: 17)!)
    let pagetitle = UILabel(text: "Contact", font: UIFont(name: "PTSerif-Bold", size: 40), textColor: accentOrange, textAlignment: .left, numberOfLines: 1)
    
    let buttonArea = UIButton(type: .custom)
    
    let textView = UITextView()
    let text = """
This Improve the News app is published by the non-profit Improve the News Foundation, which is lead by MIT professor Max Tegmark.
Contact: improvethenews@gmail.com

If you have feature requests, bug reports or any other feedback on this app, we recommend that you instead send it to us using our feedback form, which makes it easier for us to respond to it.
"""
    let bold = ["What is this?", "How is this funded?", "How does it work?", "Won’t this contribute to filter bubbles?", "What is your privacy policy?", "How can I contact you with feedback?"] as [NSString]
    
    let paths = ["mailto:improvethenews@gmail.com",
                "https://docs.google.com/forms/d/e/1FAIpQLSfoGi4VkL99kV4nESvK71k4NgzcVuIo4o-JDrlmBqArLR_IYA/viewform"]
                
    let linked = ["improvethenews@gmail.com",
                            "feedback form"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        configureView()
    }
    
    func configureView() {
        
        view.addSubview(pagetitle)
        pagetitle.translatesAutoresizingMaskIntoConstraints = false
        //pagetitle.backgroundColor = .cyan
        NSLayoutConstraint.activate([
            pagetitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
            pagetitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            pagetitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -70)
        ])
        pagetitle.adjustsFontSizeToFitWidth = true
        
        dismiss.titleLabel?.textColor = accentOrange
        view.addSubview(dismiss)
        dismiss.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismiss.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 7),
            dismiss.leadingAnchor.constraint(equalTo: pagetitle.trailingAnchor),
            dismiss.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5)
        ])
        
        textView.attributedText = prettifyText(fullString: text as NSString, boldPartsOfString: bold, font: UIFont(name: "Poppins-Regular", size: 14), boldFont: UIFont(name: "Poppins-Regular", size: 22), paths: paths, linkedSubstrings: linked, accented: [])
        textView.textColor = articleHeadLineColor
        textView.backgroundColor = .black
        textView.isEditable = false
        //textView.isSelectable = false
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            textView.topAnchor.constraint(equalTo: self.pagetitle.bottomAnchor, constant: 5),
        ])
        textView.delegate = self
        
        /*
        buttonArea.backgroundColor = .clear
        view.addSubview(buttonArea)
        buttonArea.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonArea.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            buttonArea.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            buttonArea.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            buttonArea.topAnchor.constraint(equalTo: self.pagetitle.bottomAnchor, constant: 5),
        ])
        */
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if(URL.absoluteString == paths[1]) {
            self.callContactForm()
            return false
        } else {
            return true
        }
    }
    
    private func callContactForm() {
        let url = URL(string: paths[1])!
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true

        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = .black
        vc.preferredControlTintColor = accentOrange
        present(vc, animated: true, completion: nil)
    }
}
