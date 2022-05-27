//
//  FAQ_stuff.swift
//  ImproveTheNews
//
//  Created by Federico Lopez on 11/05/2022.
//  Copyright © 2022 Mindy Long. All rights reserved.
//

import Foundation
import UIKit

let FAQ_titles = [
    "What's this?",
    "Mission",
    "Why might I like ITN?",
    "Why should I read narratives I disagree with?",
    "Why don't you block all \"disinformation\"?",
    "What's establishment bias?",
    "Who’s behind this?",
    "Is ITN political?",
    "What are ITN’s values?",
    "How does it work?",
    "Is there an app for that?",
    "Won't this contribute to filter bubbles?",
    "How can I help?",
    "What’s your privacy policy?",
    "How can I contact you with feedback?"
]

let FAQ_contents = [
"""
This is a free news aggregator and news analysis site developed by a group of researchers at MIT and elsewhere to improve your access to trustworthy news.

""",

"""
Empower people to rise above controversies and understand the world in a nuanced way.

""",

"""
1. You’re busy: Most people lack the time to read a range of sources to get an unbiased understanding of what’s really going on. ITN does this for you, conveniently summarizing trustworthy facts – with source links that you can verify yourself.

2. Your voice is heard and respected: Facts aside, you’ll also find fairly presented competing narratives – including your own – regardless of where your home is on the political spectrum.

3. It’s useful to know what other people think: By understanding other people’s arguments, you understand why they do what they do – and have a better chance of persuading them.

4. You won’t get mind-hacked: Many website algorithms push you (for ad revenue) into a filter bubble by reinforcing the narratives you impulse-click on. Just as it's healthier to choose what you eat deliberately rather than impulsively, it's more empowering to choose your news diet deliberately with sliders, as explained in this video.

5. You’re bored: Many news outlets are so partisan that their coverage gets boringly narrow. Quality debates about important controversies can be quite interesting!

6. You don’t want to be part of the problem: If you spend your time consuming biased news that others profit from, you’re feeding the incentive structure that makes people in power manipulate you and others.

""",

"""
It's oft-argued that we should silence those we're convinced are wrong, to avoid giving them a platform. We strongly disagree. Even more important than their freedom to speak, is your freedom to hear. We believe that you're good at calling bs when you see it, and reject the patronizing premise that your mind is too frail to read poor arguments without falling for them. Moreover, to truly understand a political or military battle, we need to understand both sides' arguments. The better we understand poor arguments, the more successfully we can defeat them. Also, when someone blocks information, how can you be sure they’re trying to protect you rather than themselves?

""",

"""
Because figuring out the truth can be hard! If it were simple enough to be delegated to a corporate or governmental fact-checking committee, we would no longer need science, and MIT should fire me (Max). Top physicists spent centuries believing in the wrong theory of gravity, and truth-finding gets no easier when politics and vested interests enter; the Ministry of Truth in Orwell’s novel 1984 reminds us that one of the oldest propaganda tricks is to accuse the other side of spreading disinformation

""",

"""
When we used Machine Learning to objectively classify a million news articles by their bias here, the algorithm uncovered two main bias axes: the well-known left-right bias as well as establishment bias. The establishment view is what all big parties and powers agree on, which varies between countries and over time. For example, the old establishment view that women shouldn’t be allowed to vote was successfully challenged. ITN makes it easy for you to compare the perspectives of the pro-establishment mainstream media with those of smaller establishment-critical news outlets that you won’t find in most other news aggregators.

""",

"""
ITN began in 2020 as an MIT research project led by Prof. Max Tegmark on machine learning for news classification. Huge thanks to Khaled Shehada, Mindy Long and Arun Wongprommoon for creating the initial news aggregator website, iOS app and Android app and to Tim Woolley for design help. To enable scaling up, ITN was incorporated as a philanthropically funded 501c(3) non-profit organization. Our site and apps will always be free and without ads.

""",

"""
No. Although we respect that people across the political spectrum disagree on how the world ought to be, we believe that news should help everyone agree on how the world is. We therefore work to separate opinion (“ought”) from fact (“is”). We seek to build a team that’s well-balanced across the political spectrum, and encourage it to treat media bias from all sides in the same way.

""",

"""
• Trust: We believe that societies work best when their citizens know the truth, and that science is humanity's best truth-finding system. We’ve therefore built ITN around these scientific ideals: questioning authority, upholding free speech, earning trust by making correct predictions, substantiating claims with reliable and verifiable evidence, providing proper context for claims, and subjecting claims to critical peer review.

• Empowerment: We consider it patronizing and anti-democratic for governments and companies to decide for news-readers which facts they should see and which narratives are correct. In contrast, we trust our users to think for themselves, and we therefore empower them with tools for quickly and easily finding whatever facts and narratives they are interested in. This empowerment philosophy extends to the UX/UI of our products, where we let users chose between a wide range of layouts and design options.

""",

"""
The free information sources on our site are powered by machine-learning (ML) and crowdsourcing. We use ML to classify all articles by topics for the news aggregator topics; we’ve shared our code on GitHub; please let us know if you’d like to help us improve it! We also use ML to group together articles about the same story, so that you can compare and contrast their perspectives using our sliders. To produce a story page (example here), our editorial team then extracts both the key facts (that all articles agree on) and the key narratives (where the articles differ). We also do academic research on media bias – here is a paper on how media bias can be objectively measured from raw data without human input.

""",

"""
Yes: We have free apps for iOS here and Android here.

""",

"""
There's a rich scientific literature on how click-optimizing algorithms at Facebook, Google,etc. have polarized and divided society into groups that each get exposed only to ideas they already agree with. So won't giving people choices such as the left-right slider on this site exacerbate the problem? Recent work from David Rand's MIT group suggests the opposite: that people become less susceptible to fake news and bias when given easy access to a range of information, enabling what Kahneman calls \"system 2\" deliberation instead of \"system 1\" impulsive clicking and reacting. Their work also suggests that many people are interested in opinions disagreeing with their own, if expressed in a nuanced and respectful way, but are rarely exposed to this. So let’s not rush to blame consumers rather than providers of news.

""",

"""
• If you’d like to support us with a donation, we hope to launch a donation page soon.

• If you’d like to work for us, please email jobs@improvethenews.org. We’re currently looking for web developers, machine learning researchers and journalists.

• If you have ideas or suggestions for improving our site or apps, please fill out this feedback form.

Thanks in advance!


""",

"""
Our informal privacy policy is “don’t be creepy”. We’re not trying to profit from you, and we'll never share or sell your data. You’ll find our full privacy policy here.

""",

"""
This is work in progress, and as you can easily tell, there's lots of room for improvement! Please help us make it better by providing your feedback here.

"""

]

let FAQ_PARTS = [
    [],
    [],
    ["this video"],
    [],
    [],
    ["here"],
    ["Max Tegmark", "website", "iOS app", "Android app"],
    [],
    [],
    [" here", " here "],
    ["iOS here", "Android here"],
    ["Recent work"],
    ["jobs@improvethenews.org", "feedback form"],
    ["here"],
    [" here"]
]

let FAQ_feedbackForm = "https://docs.google.com/forms/d/e/1FAIpQLSfoGi4VkL99kV4nESvK71k4NgzcVuIo4o-JDrlmBqArLR_IYA/viewform"

let FAQ_LINKS = [
    [],
    [],
    ["https://www.youtube.com/watch?v=PRLF17Pb6vo"],
    [],
    [],
    ["https://arxiv.org/abs/2109.00024"],
    ["https://space.mit.edu/home/tegmark/home.html",
        "https://www.improvethenews.org/",
        "https://apps.apple.com/us/app/improve-the-news/id1554856339",
        "https://play.google.com/store/apps/details?id=com.improvethenews.projecta"],
    [],
    [],
    ["https://www.improvethenews.org/story/2022/scotus-blocks-revised-state-map-for-wisconsin",
        "https://arxiv.org/abs/2109.00024"],
    ["https://apps.apple.com/us/app/improve-the-news/id1554856339",
        "https://play.google.com/store/apps/details?id=com.improvethenews.projecta"],
    ["https://psyarxiv.com/29b4j"],
    ["mailto:jobs@improvethenews.org", FAQ_feedbackForm],
    ["https://www.improvethenews.org/privacy-policy"],
    [FAQ_feedbackForm]
]

let FAQ_PICS = [
    nil,
    nil,
    nil,
    nil,
    ["galileo.jpg", CGSize(width: 468, height: 175)],
    ["einstein.jpg", CGSize(width: 1280, height: 216)],
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil
]
