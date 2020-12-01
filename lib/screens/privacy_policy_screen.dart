import 'package:K9_Karaoke/screens/terms_of_use_screen.dart';
import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const routeName = 'privacy-policy-screen';
  final italic =
      TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontSize: 13);
  final title =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 22);
  final bold =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 15);
  final reg =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 13);
  final link = TextStyle(
      decoration: TextDecoration.underline,
      color: Colors.blue,
      fontWeight: FontWeight.w400,
      fontSize: 13);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context, isMenu: true, pageTitle: "Privacy Policy"),
      // Background image
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgrounds/menu_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 75),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text("TURBO BLASTER UNLIMITED, LLC\n", style: bold),
                        Text("Privacy Policy\n", style: bold),
                        Text("Effective: November 19, 2020\n", style: bold),
                        Text("Binding Legal Agreement.\n", style: bold),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text:
                                    "This privacy policy (the “Privacy Policy”) applies to the K-9 Karaoke and Kitty Karaoke mobile applications (collectively, our “App”) and our website located at www.k-9karaoke.com and  www.kittykaraoke.com, including any subdomains thereof (our “Website”) (either or both the App and our Website referred to herein as our “Services”), owned and operated by Turbo Blaster Unlimited, LLC. We have created this Privacy Policy to tell you what information our App and Website collect, how we use that information, and who we share that information with, if at all. This Privacy Policy does not address the privacy practices of any third parties. Capitalized and defined terms not defined in this Privacy Policy will have the meaning set forth in our ",
                                style: reg),
                            TextSpan(
                                text: "Terms of Use\n\n",
                                style: reg,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, TermsOfUseScreen.routeName);
                                  })
                          ]),
                        ),
                        Text(
                          "BY ACCESSING OR USING ANY OF OUR SERVICES, YOU ACCEPT AND AGREE TO BE BOUND BY ALL OUR POLICIES, ALL OF WHICH CONSTITUTE A BINDING LEGAL AGREEMENT BETWEEN YOU AND US AND GOVERN ALL USE OF OUR SERVICES. If you do not agree to our Policies, you are not permitted to access or otherwise use our Services.\n\n",
                          style: reg,
                        ),
                        Text("Changes to our Policies.\n", style: bold),
                        Text(
                            "We may modify any of our Policies from time to time by posting such changes on our App and/or Website, with or without notice to you. Any changes will become effective when posted and will not be retroactively effective. If you do not agree to any of our Policies, your only recourse is to immediately discontinue use of our Services. By accessing our App or Website after we make any such changes to our Policies, you are deemed to have accepted such changes. Please review our Policies on a regular basis as it is your responsibility to comply with the latest version of our Policies.\n\n"),
                        Text("Types of Information We Collect or Receive.\n",
                            style: bold),
                        Text(
                            "When you use our App and Website, you authorize us to collect and/or receive the following types of information. \n\n",
                            style: reg),
                        Text("Personal Information.\n", style: bold),
                        Text(
                            "When you create an account on our App and/or Website or otherwise contact us, you voluntarily provide us with certain personally identifiable information about yourself and optionally may provide other information that identifies you, such as your IP address (collectively, the “Personal Information”). Personal Information may include your name, age, and e-mail address, pictures from your device’s camera and/or photo library, and voice recordings from your device’s microphone.\n\n",
                            style: reg),
                        Text("Third-party Log In.\n", style: bold),
                        Text(
                            "If you register or visit our Services using your Facebook or Google login credentials or through such social media websites, you are authorizing us to collect, store, and use, in accordance with this Privacy Policy, any and all information you agreed the social media website would provide to us through its Application Programming Interface (“API”). We do not receive or store your passwords for your Facebook or Google accounts.\n\n",
                            style: reg),
                        Text("Payment Information.\n", style: bold),
                        Text(
                            "If you choose to make a  purchase or subscribe to a feature of our Service that requires a fee, you will be required to provide your payment information, including, without limitation, bank account numbers, credit card or debit card numbers, account details, ACH information, and similar data (collectively, “Payment Information”) to our third-party payment processors, pursuant to the terms and conditions of their privacy policies and terms of use, so they can process your purchases or subscriptions. We do not obtain access to any Payment Information in connection with such purchases or subscriptions.\n\n",
                            style: reg),
                        Text("Third-Party Analytics.\n\n", style: bold),
                        Text(
                          "We may use third-party analytics services (e.g., Google Analytics) to evaluate your use of our App and/or Website, compile reports on activity, collect demographic data, analyze performance metrics, and collect and evaluate other information relating to our Services and your mobile and Internet usage. Such third party services may use cookies and other technologies to help analyze and provide us the data, and their collection and processing of any data they receive from you is subject to their respective privacy policies. \n\n",
                          style: reg,
                        ),
                        Text("Other Information We Collect and Receive.\n\n",
                            style: bold),
                        Text(
                          "We may automatically collect or receive additional information regarding you, your usage of our Services, your interactions with us, and information regarding the devices you use to access and use our Services  (collectively, the “Other Information”). Such Other Information may include:\n\n",
                          style: reg,
                        ),
                        Text(
                          "    • From You. Additional information about yourself you voluntarily provide, such as your gender and your product and service preferences.\n\n",
                          style: reg,
                        ),
                        Text(
                          "    • From Your Activity. We may collect or receive information regarding:\n\n",
                          style: reg,
                        ),
                        Text(
                            "        ○ IP address, which may consist of a static or dynamic IP address and will sometimes point to a specific identifiable computer or device;\n\n",
                            style: reg),
                        Text("        ○ browser type and language;\n\n",
                            style: reg),
                        Text(
                            "        ○ pages of our Apps and/or Website you visit, and the time and date of your visit;\n\n",
                            style: reg),
                        Text("        ○ referring and exit pages and URLs;\n\n",
                            style: reg),
                        Text(
                            "        ○ details regarding your activity on our App and/or Website, such as search queries and other performance and usage data;\n\n",
                            style: reg),
                        Text(
                            "        ○ type of device used to access or use our Services;\n\n",
                            style: reg),
                        Text(
                            "        ○ the operating system and version used to access or use our Services;\n\n",
                            style: reg),
                        Text("        ○ your network carrier; and\n\n",
                            style: reg),
                        Text("        ○ your network type.\n\n", style: reg),
                        Text(
                          "    • From Tracking Technologies and Cookies. Cookies and other tracking technologies are small text files an app or browser can use to, among other things, recognize a repeat visitor (collectively, “Cookies”). We may use cookies to, among other purposes, identify and authenticate you, remember your preferences, track your use of our Services, and enhance your experience with our Services. “First-party Cookies” are Cookies we place on your device. “Third-party Cookies” are Cookies another entity places on your device as a result of your use of our Services. We may use both session Cookies, which expire once you close our App or Website, and persistent Cookies, which stay on the device you use to access our Services until you delete them. We may contract with third parties to track and analyze our user’s statistical usage information. These third parties may use Cookies to help us improve user experience and analyze how users navigate and use our Services.\n\n",
                          style: reg,
                        ),
                        Text(
                          "    You may refuse to accept browser Cookies by setting your device and/or browser to reject and/or disable Cookies. However, if you do not accept Cookies, you may not be able to use some parts or features of our Services.\n\n",
                          style: reg,
                        ),
                        Text("We may use Cookies for the following purposes:\n",
                            style: reg),
                        Text(
                            "        ○ Necessary/Technical Cookies. These Cookies are essential in order to provide access to our App and Website and to enable the features of our Services. Without these Cookies, we cannot provide our Services to you.\n\n",
                            style: reg),
                        Text(
                            "        ○ Functionality Cookies. These Cookies allow us to remember choices you make when you use our Services, such as remembering your login details. The purpose of these Cookies is to provide you with a more personal experience and to prevent you from needing to re-enter your preferences every time you use our Services.\n\n",
                            style: reg),
                        Text(
                            "        ○ Analytical/Performance Cookies. These Cookies are used by us or by third parties to analyze how our Services are used and are performing. For example, these Cookies track what pages are most frequently visited and the location of our visitors. These Cookies may correlate to you and include, for example, Google Analytics cookies.\n\n",
                            style: reg),
                        Text("How to Opt Out of Analytics Tools.\n",
                            style: bold),
                        Text(
                            "You may opt-out of certain third-party analytics services we use, including certain Google Analytics, through your device settings, such as your device advertising settings and/or by following the instructions provided by Google in their privacy policy. You can opt-out of having your activity on our App and/or Website available to Google Analytics by installing the Google Analytics opt-out browser add-on. Please be advised that if you opt out, you may not be able to use the full functionality of our App or Website, and if you use multiple browsers and/or devices, you will need to opt out for each one.\n\n",
                            style: reg),
                        Text("How Information is Used.\n", style: bold),
                        Text(
                            "You authorize us to use, process, and store the Personal Information, Other Information, analytics, and log-in data we receive to:\n\n",
                            style: reg),
                        Text("    • provide and improve our Services;\n\n",
                            style: reg),
                        Text("    • provide and maintain our Services;\n\n",
                            style: reg),
                        Text(
                            "    • perform a contract to provide the products, items, or services you purchase from us;\n\n",
                            style: reg),
                        Text("    • manage your account and your requests;\n\n",
                            style: reg),
                        Text("    • administer our promotional programs;\n\n",
                            style: reg),
                        Text(
                            "    • solicit your feedback or contact you about our Services;\n\n",
                            style: reg),
                        Text("    • provide support to you; and\n\n",
                            style: reg),
                        Text(
                            "    • inform you about our products and services.\n\n",
                            style: reg),
                        Text("How Information is Shared.\n", style: bold),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Shared As You Direct. ", style: bold),
                            TextSpan(
                                text:
                                    "We share your Personal Information, as you direct, when you interact with other persons through our Services. For example, when you use our Services to send a song card to a friend or share it through a third-party social media service, the people you send it to or share it with may see your Personal Information, including your name, email, any pictures you provide, and/or your voice recording.",
                                style: reg),
                          ]),
                        ),
                        Text('\n'),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Shared With Our Service Providers. ",
                                style: bold),
                            TextSpan(
                                text:
                                    "We use Service Providers to perform functions on our behalf. These Services Providers will have access to your Personal Information and other non-personal information as necessary to perform their functions for us and only to the extent permitted by law. We do not engage with Service Providers who sell your Personal Information or use it for any purpose other than the business purpose for which we have contracted with them.\n",
                                style: reg),
                          ]),
                        ),
                        Text(
                            "Our Service Providers process payments for purchases you make through our Services by collecting and storing your Payment Information. Storage by the Service Provider of your Payment Information is subject to the privacy policies and practices of that Service Provider and is not subject to the terms of this Privacy Policy. By providing your Payment Information when you make purchases through our Services, you acknowledge and agree to the use of such information by the Service Provider for purposes of processing your payment to us, in accordance with their policies. We use the following Service Providers to process payments:\n\n",
                            style: reg),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "    • Apple Store In-App Payments. ",
                                style: italic),
                            TextSpan(
                                text: "Their Privacy Policy can be viewed at ",
                                style: reg),
                            TextSpan(
                                text:
                                    "https://www.apple.com/legal/privacy/en-ww/",
                                style: link,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launch(
                                        'https://www.apple.com/legal/privacy/en-ww/');
                                  })
                          ]),
                        ),
                        Text('\n'),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "    • Google Play In-App Payments. ",
                                style: italic),
                            TextSpan(
                                text: "Their Privacy Policy can be viewed at ",
                                style: reg),
                            TextSpan(
                                text:
                                    "https://payments.google.com/payments/apis-secure/u/0/get_legal_document?ldo=0&ldt=privacynotice&ldl=en",
                                style: link,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launch(
                                        'https://payments.google.com/payments/apis-secure/u/0/get_legal_document?ldo=0&ldt=privacynotice&ldl=en');
                                  })
                          ]),
                        ),
                        Text("\n\n"),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "Aggregate Data. ", style: bold),
                            TextSpan(
                                text:
                                    "In an ongoing effort to better understand our users, and how our App, our Website, and our products and services are used, we may analyze certain Information in anonymized and aggregate form to operate, maintain, manage, and improve our Services. This aggregate data does not identify you personally. We may share and/or license this aggregate data to our affiliates, agents, business, and promotional partners, and other third parties, including our Service Providers. We may also disclose aggregated user statistics to describe our Services to current and prospective business partners, potential and actual investors, and to other third parties for other lawful purposes.\n",
                                style: reg),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(text: "Affiliates. ", style: bold),
                            TextSpan(
                                text:
                                    "We may share some or all your Information with any of our parent companies, affiliates, subsidiaries, joint ventures, or other companies under common control with us.\n",
                                style: reg),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Business Transactions. ", style: bold),
                            TextSpan(
                                text:
                                    "As we develop our business, we might sell or buy other businesses or assets. In the event of a corporate sale, merger, reorganization, sale of assets, dissolution, or similar event, the information we collect, use, process, and store may be part of the transferred assets.\n",
                                style: reg),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Law Enforcement and Other Reasons. ",
                                style: bold),
                            TextSpan(
                                text:
                                    "To the extent permitted by law, we may also disclose the information we collect, use, process, and store to:\n",
                                style: reg),
                          ]),
                        ),
                        Text("    • comply with a legal obligation;\n\n",
                            style: reg),
                        Text(
                            "    • protect or defend our (or others’) rights, property, or safety;\n\n",
                            style: reg),
                        Text(
                            "    • prevent or investigate possible wrongdoing in connection with our business, including the access to or use of our Services; or\n\n",
                            style: reg),
                        Text("    • protect against legal liability.\n\n",
                            style: reg),
                        Text("How We Protect Your Information. \n",
                            style: bold),
                        Text(
                            "We take commercially reasonable steps to protect the information we receive and collect, use, process, and store from loss, misuse, and unauthorized access, disclosure, alteration, or destruction. Please understand, however, that no security system is impenetrable. We cannot therefore guarantee the security of our databases or the databases of the third parties with which we may share such Information, nor can we guarantee that the information you supply will not be intercepted while being transmitted over the Internet. In particular, electronic mail or text messages sent to us may not be secure, and you should therefore take special care in deciding what information you send to us via email or text.\n\n",
                            style: reg),
                        Text("Retention of your Personal Information.\n",
                            style: bold),
                        Text(
                            "We retain your Personal Information only for as long as is necessary for the purposes set out in this Privacy Policy and to comply with our legal obligations, resolve disputes, and enforce our agreements and policies. We reserve the right to delete any account which has been inactive for three (3) years.\n\n",
                            style: reg),
                        Text(
                            "Storage and Transfer of your Personal Information. \n",
                            style: bold),
                        Text(
                            "Our App and Website are operated in the United States and any related data may be transferred, processed, and used in the United States or throughout the world. Wherever you reside, please be aware that your Information, including your Personal Information, may be transferred to, and/or processed, maintained, and used on computers, servers, and/or systems located outside of your state, province, country, or other governmental jurisdiction where the privacy laws may not be as protective as those in your jurisdiction. You hereby irrevocably and unconditionally consent to the transfer, processing, and use of your Information in the United States and anywhere our Service Providers involved in such transfer, processing or use operate and/or are located throughout the world.\n\n",
                            style: reg),
                        Text("App Stores.\n", style: bold),
                        Text(
                            "Your app store, for example, Apple’s App Store or Google Play, may collect certain information in connection with your use of our App, such as personally identifying information, geolocation information, payment information and usage-based data. We have no control over, or liability related to, the collection of such information by a third-party app store, and any such collection or use will be subject to that third party’s applicable privacy policies.\n\n",
                            style: reg),
                        Text("External Websites.\n", style: bold),
                        Text(
                            "Our App and Website may contain links to third-party websites and/or services. We have no control over the privacy practices or the content of these websites or services. As such, we are not responsible, and have no liability, for the content or the privacy policies or practices of those third-party websites or services. You should check the applicable third-party privacy policy and terms of use when visiting any other websites and using other services.\n\n",
                            style: reg),
                        Text(
                            "Accessing and Modifying Information and Communication Preferences.\n",
                            style: bold),
                        Text(
                            "You may access, remove, review, and/or make changes to any Personal Information you provide to us by contacting us at support@turboblasterunlimited.com. In addition, you may manage your receipt of marketing and non-transactional communications by clicking on the “unsubscribe” link located on the bottom of any of our marketing emails or communications. While we will use commercially reasonable efforts to process such requests in a timely manner, you should be aware that it is not always possible to completely remove or modify such information in our subscription databases.\n\n",
                            style: reg),
                        Text("Governing Law and Jurisdiction.\n", style: bold),
                        Text(
                            "Our Policies are governed exclusively by the internal laws of the State of Washington, without regard to conflict of law principles. By accessing and using our Services, you hereby irrevocably consent and submit to the exclusive jurisdiction of the state and federal courts located in Seattle, Washington, to adjudicate any dispute or claim arising out of or relating to your access or use of our Services, including our Policies, and you consent and submit to the personal jurisdiction of such courts for the purpose of litigating any such matters. You further hereby waive, to the extent not prohibited by applicable law, and agree not to assert by way of motion, as a defense or otherwise, in any such dispute any claim that you are not subject personally to the jurisdiction of the above-named courts, that your property is exempt or immune from attachment or execution, that any such proceeding brought in the above-named courts is improper, or that such disputes or claims cannot be enforced in or by such courts.\n",
                            style: reg),
                        Text(
                            "You cannot opt out of receiving emails related to your transactions when using our Services, including support e-mails and any legally required communications.\n",
                            style: reg),
                        Text(
                            "We may also deliver notifications to your mobile device. You can disable these notifications by deleting the relevant service or by changing the settings on your mobile device.\n\n",
                            style: reg),
                        Text("Your Rights.\n", style: bold),
                        Text(
                            "You have the right to know about your Personal Information we collect, use, disclose, or transfer. As required, this Privacy Policy discloses the categories of Personal Information we collect, the categories of sources from which we collect Personal Information, the purposes for which it is used, and the types of third parties to whom we disclose or transfer Personal Information.  We do not sell Personal Information.\n\n",
                            style: reg),
                        Text(
                            "In addition, you also have the following rights:\n",
                            style: reg),
                        Text(
                          "    • You may request (up to twice per year) additional information regarding the specific pieces of Personal Information we collected about you in the preceding 12 months, the categories of sources of that information, the business reasons we collected, used, or processed that information, and the categories of third parties to whom we disclosed that information in the preceding 12 months. Upon verifying your request, we will provide an electronic copy to you of such Personal Information in a machine-readable format.\n",
                          style: reg,
                        ),
                        Text(
                          "    • You may request (up to twice per year) that we delete your Personal Information collected in the preceding 12 months, which we will do unless applicable law permits otherwise for specific purposes, including maintaining backups of our business information. Please be advised that we cannot delete your Personal Information without deleting your account and all of its contents and history.\n",
                          style: reg,
                        ),
                        Text(
                          "    • You may designate an authorized agent to exercise the above requests on your behalf.\n",
                          style: reg,
                        ),
                        Text(
                          "    • You have a right not be discriminated against for your exercise of these rights.\n",
                          style: reg,
                        ),
                        Text(
                            "We will respond to your requests within 45 days of receipt, which may be extended by an additional 45 days when reasonably necessary and with notice to you. If we cannot verify your identity or you do not cooperate with us, we may not comply with your request. If your request requires extraordinary cost or effort, we reserve the right to charge you a fee prior to fulfilling your requests.\n\n",
                            style: reg),
                        Text("Do Not Track.\n", style: bold),
                        Text(
                            "We do not monitor, recognize, or honor any opt-out or do not track mechanisms, including general web browser “Do Not Track” settings and/or signals.\n\n",
                            style: reg),
                        Text("How to Contact Us.\n", style: bold),
                        Text(
                          "If you have questions about this Privacy Policy or wish to exercise your rights by making a request, please email us at support@turboblasterunlimited.com with “Privacy Policy” in the subject line or mail us at the following address: 8240 14th Ave NE Seattle, WA 98115.\n",
                          style: reg,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
