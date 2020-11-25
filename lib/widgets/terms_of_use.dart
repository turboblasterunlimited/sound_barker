import 'package:flutter/material.dart';

class TermsOfUse extends StatelessWidget {

  final bold =
      TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 13);
  final reg = TextStyle(color: Colors.black, fontWeight: FontWeight.w200);
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            Text("TURBO BLASTER UNLIMITED, LLC\n", style: bold),
            Text("TERMS OF USE\n", style: bold),
            Text("Effective: November 19, 2020\n", style: bold),
            Text("Binding Legal Agreement.\n", style: bold),
            Text(
              "Turbo Blaster Unlimited, LLC, a Washington limited liability company (together with its affiliates, “TBU,” “we” or “us” “our”) provides the K-9 Karaoke and Kitty Karaoke mobile applications (collectively, our “App”) and our website at www.k-9karaoke.com and www.kittykaraoke.com including any subdomains thereof (our “Website”) (either or both the App and our Website referred to herein as our “Services”) to you subject to your acceptance and compliance with these Terms of Use, our Privacy Policy, and all other forms, terms, notices, and policies published by TBU on our App and/or Website or otherwise made available to you, which are hereby incorporated by this reference (collectively our “Policies”). For purposes of our Policies, the terms “user” and “you” refer to (a) you and, if you create an account on our App and/or the Website, anyone who uses your account. BY ACCESSING OR USING ANY OF OUR SERVICES, YOU ACCEPT AND AGREE TO BE BOUND BY ALL OUR POLICIES, ALL OF WHICH CONSTITUTE A BINDING LEGAL AGREEMENT BETWEEN YOU AND US AND GOVERN ALL USE OF OUR SERVICES. If you do not agree to our Policies, you are not permitted to access or otherwise use our Services.\n\n",
              style: reg,
            ),
            Text("Changes to our Policies.\n", style: bold),
            Text(
                "We may modify any of our Policies from time to time by posting such changes on our App and/or Website, with or without notice to you. Any changes will become effective when posted and will not be retroactively effective. If you do not agree to any of our Policies, your only recourse is to immediately discontinue use of our Services. By accessing our App or Website after we make any such changes to our Policies, you are deemed to have accepted such changes. Please review our Policies on a regular basis as it is your responsibility to comply with the latest versions of our Policies.\n\n"),
            Text("User Age.\n", style: bold),
            Text(
                "Our App and Website are intended only for use by persons age 16 and older.  Further, we do not knowingly collect personal information from any person under the age of 16, and if we become aware that such information has been collected, we will delete such user’s account.\n\n",
                style: reg),
            Text("Accounts.\n", style: bold),
            Text(
                "By using our Services, you hereby represent and warrant that you are at least 16 years of age. When you create an account, you are required to keep it secure. We will not be liable for any damages or losses caused by any use of your account or access you allow and, to the fullest extent permitted by law, you will be liable for all damages and losses incurred by us or others due to use of your account.\n\n",
                style: reg),
            Text("Access.\n", style: bold),
            Text(
                "We may terminate any user’s access to our Services at any time and for any or no reason. We may, in our sole discretion and with or without notice, remove and/or delete the account of or access by any user who violates, or we have reason to believe violates, any of our Policies, whether or not such user is a repeat violator.\n\n",
                style: reg),
            Text("System Requirements.\n", style: bold),
            Text(
                "Use of our Services requires one or more compatible devices, Internet access (fees may apply), and certain software (fees may apply), and may require obtaining updates or upgrades from time to time. Because use of our Services, including access to our App and Website content and features, requires that you have access to certain hardware, software, and the Internet, your ability to access and use our Services and all aspects thereof may be affected by the performance of your devices and your access to the Internet. You acknowledge and agree that all system requirements to use our Services, which may change from time to time, are your sole responsibility.\n\n",
                style: reg),
            Text("User’s Responsibilities and Representations.\n\n",
                style: bold),
            Text(
              "By accessing or using our Services, you represent and agree that:\n\n",
              style: reg,
            ),
            Text(
                "    • You are accessing and using our Services at your sole discretion and risk.\n\n",
                style: reg),
            Text(
              "    • You are solely responsible for your access to and use of our Services and any consequences related thereto, and for the accuracy, completeness, appropriateness, legality, and compliance with all laws, including those related to intellectual property rights, in connection with any information, pictures, or recordings or other content you provide, create, or transmit using our Services.\n\n",
              style: reg,
            ),
            Text(
              "    • You will not access or use our Services to provide, create, or transmit any information or content: (a) that is copyrighted or otherwise subject to third party proprietary rights, including privacy and publicity rights, unless you are the owner of such rights or are permitted to submit and use the information or content and you grant us the license rights as set forth in the Grant of License (below) in our Policies with respect thereto; (b) that is false or fraudulent or contains misinformation; (c) that is, in our discretion, obscene, defamatory, libelous, threatening, pornographic, harassing, hateful, offensive, discriminatory; (d) that encourages or gives rise to a criminal offense or any civil liability; (e) that violates any law (including export control laws or regulations); (f) that contains viruses, adware, spyware, worms, or other harmful or malicious code; (g) that otherwise violates any of the Prohibited Actions (defined below), or would be considered inappropriate by a reasonable person.\n\n",
              style: reg,
            ),
            Text(
              "    • We will not be liable in any way for your access to or use of our Services or any consequences thereof, or any loss or damage of any kind incurred as a result of your access to or use of our Services.\n\n",
              style: reg,
            ),
            Text("Your Grant of License.\n", style: bold),
            Text(
              "By accessing or using our Services, you grant to us and our contractors, vendors, and/or other representatives a perpetual, worldwide, royalty-free, unrestricted, irrevocable, nonexclusive, assignable, transferable, and sublicensable license and right to display, record, store, reproduce, publicly perform, distribute, transmit, upload, download, remix, excerpt, modify, adapt, transcode, translate, publish, and create derivative works from, or otherwise use the information and content you provide, create, or transmit using our Services, including you and your pet’s name, voice, and likeness, if applicable, for the purposes and in the manner contemplated by our Services, by any means, methods, or formats now known or later developed or discovered, and to the fullest extent and for the maximum duration permitted by law, and without paying any compensation to you.\n\nYou acknowledge and agree that this license permits us to make information and content you provide available to our Service Providers (defined below), for any reason, including to process payments associated with your purchases, and to third parties for such purposes as are permitted by our Services’ features and services for any reason, including to transmit the cards you create, access, and share, including via social media or email.\n\n",
              style: reg,
            ),
            Text("Intellectual Property.\n", style: bold),
            Text(
                "As between you and us, we own, solely and exclusively, all rights, title, and interests in and to our Services, all the content, other than that which you provide, create, or transmit to us, if any, to which you grant us the rights noted in our Policies. With regard to material we do not own that is contained in or accessible by using our Services, we have the right to display such material in the manner displayed through our Services. Your use of our Services does not grant you ownership of any kind of any content, code, data, or materials you may access on or through our Services. The trademarks, logos, service marks and trade names (collectively the “Trademarks”) displayed on, in, or made available through our Services are registered and unregistered Trademarks of ours and/or others. All Trademarks not owned by us that appear on, in, or are made available through our Services, if any, are the property of their respective owners. Nothing contained on our App and/or Website grants, by implication, estoppel, or otherwise, or should be construed as granting, by implication, estoppel, or otherwise, any license or right to use any Trademark displayed on or available without our written permission or that of the third party rights holder.\n\n",
                style: reg),
            Text("Limited Use.\n", style: bold),
            Text(
                "You may use our Services on your computer or other device for your personal, non-commercial use. You may not use our Services for any commercial purposes, in any way that does not comply with the law in your jurisdiction, or in any manner that we determine is harmful to us or any other person or entity. Other than as expressly permitted by us in advance in writing, you may not download, post, publish, change, alter, delete, reproduce, distribute, transmit, modify, transfer, or create derivative works from, sell or otherwise exploit any content, code, or data on or available through our Services. If you violate this license, you may be subject to liability for the unauthorized use including, without limitation, for violations of copyright and other laws by you or anyone obtaining such information from or through you.\n\n",
                style: reg),
            Text("Prohibited Actions.\n", style: bold),
            Text(
                "By accessing or using our Services, in addition to all other Policies, you agree to the following restrictions (collectively, the “Prohibited Actions”):\n\n",
                style: reg),
            Text(
                "    • You will not intentionally or unintentionally use any content (including that you provide, create, or transmit to us) features, or services of our Services in a manner contrary to or in violation of any applicable international, national, federal, state, or local law, or rule or regulation having the force of law.\n\n",
                style: reg),
            Text(
                "    • You will not use our Services in any manner that could harm, abuse, infect, take over, disable, overburden, or otherwise impair any of our computer hardware, software, or any systems, including, but not limited to, the servers, networks, and other components connected to or used for our Services.\n\n",
                style: reg),
            Text(
                "    • You will not use or launch any automated system, including without limitation, “robots,” “spiders,” “offline readers,” or similar tools that access our Services, including API, in a manner that sends more request messages to the servers we use in a given period of time than a human can reasonably produce in the same period by using a conventional on-line web browser.\n\n",
                style: reg),
            Text(
                "    • You will not interfere with any other user’s access to or use of our Services, or of any of their content.\n\n",
                style: reg),
            Text(
                "    • You will not provide, create, otherwise transmit any: (a) content you do not have a right to provide, create, or transmit; or (b) content that is false, fraudulent, offensive, or illegal, that contains misinformation, or that spreads or encourages offensive or illegal conduct.\n\n",
                style: reg),
            Text(
                "    • You will not upload or otherwise transmit any material that contains software viruses or any other computer code, files, or programs designed to interrupt, destroy, or limit the functionality of any software, hardware, telecommunications equipment, or device.\n\n",
                style: reg),
            Text(
                "    • You will not copy, modify, disassemble, decompile, prepare derivative works of, reverse engineer, or otherwise attempt to gain unauthorized access to any source code, service, computer system, or software related to our Services, nor attempt to gain unauthorized access to any network connected or related to any server used for our Services, including through password mining, hacking, or any other means. You will not circumvent, disable, or otherwise interfere with security or similar features of our Services or any storage or servers we use.\n\n",
                style: reg),
            Text(
                "    • You will not access or seek to gain access to any content, features, services, or software other than as expressly permitted and intentionally made available by us.\n\n",
                style: reg),
            Text(
                "    • You will not access or seek to gain access to any other user’s account, except as expressly authorized by such other user.\n\n",
                style: reg),
            Text(
                "    • Except as expressly permitted through the features and services offered through our Services, you will not reproduce, duplicate, copy, screen-shot, download content, independently record, sell, license, or otherwise exploit our Services, or any portion thereof, or use our Services for the development, production or marketing of a service or product substantially similar to our Services.\n\n",
                style: reg),
            Text(
                "    • You will not make any independent use of, copy, or distribute any of our information, content, features, services, trademarks, service marks, tradenames, logos, copyrights, patents, graphics, or other property, or use any meta tags or any other “hidden text” utilizing our trademarks, service marks, tradenames, logos, copyrights, patents, graphics, or other property without our express prior written consent.\n\n",
                style: reg),
            Text(
                "    • You will not use any network monitoring, discovery software, or other method to determine the architecture of our Services, or extract information about usage, individual identities, or users, and you will not collect or harvest any personally identifiable information, including account names or email addresses, from our Services, unless the person whose information you are collecting or harvesting has given you express permission to have such information.\n\n",
                style: reg),
            Text(
                "    • You will not engage in any commercial or promotional distribution, publishing, or exploitation of our Services, including any content, code, or data contained therein without our express prior written permission.\n\n",
                style: reg),
            Text("Right to Monitor and Restrict.\n", style: bold),
            Text(
                "We reserve the right, but do not have an obligation, to review all materials created by accessing, using, and/or posting to our Services by you and other users. We may also impose limits on certain features or restrict your access to part or all of our Services, without notice or liability, if we deem it necessary or believe you are or may be in breach of our Terms of Service, our other Policies, or applicable law.\n\n",
                style: reg),
            Text("Subscriptions and Other Purchases.\n", style: bold),
            Text(
                "You agree to pay in full the prices for any subscriptions, features, cards, or content you purchase by acceptable payment method concurrent with your online purchase, and in connection with any such purchase, you agree to pay all applicable taxes. If payment is not received from your credit or debit card issuer or its agents, you agree to pay all amounts due upon demand by us.\n\n",
                style: reg),
            Text("Advertisers.\n", style: bold),
            Text(
                "Our Services may contain advertisements provided by third parties. Our advertising partners, not us, are responsible for ensuring that advertising content is accurate and complies with applicable laws, regulations, and guidelines, as well as our Policies and any other applicable policies. We are not responsible, and expressly disclaim any liability, for the illegality of, or any information, error, or inaccuracy in, any advertiser or sponsor materials, or for the acts or omissions of any such advertisers or sponsors.\n\n",
                style: reg),
            Text("Third Party Websites and Links to Our Website.\n\n",
                style: bold),
            Text(
                "You may be able to link from our Services to a third party’s website. You hereby acknowledge and agree that we have no responsibility or liability for or control of the information, content, practices, or policies of such third-party websites, and that when you visit such third-party websites you do so completely at your own risk. Links to third party websites, if any, are provided solely for your convenience, and we reserve the right to disable links from third-party sites to our Website at any time and without notice. It is up to you to take precautions to ensure that whatever website or device you select for your use is accurate and free of viruses, worms, trojan horses and other such items of a destructive nature. It is also your responsibility to understand whether and how such third-party sites collect and use personal information about you and what third-party policies control that information. Our links to third-party websites do not amount to an endorsement or sponsorship by us of such websites or the content, products, services, or advertising found there and must not be construed as such.\n\nFurther, you agree that if you include a link to our Website or Services, such link shall link to the full version of an HTML formatted page thereof. You are not permitted to link directly to any image hosted on our Services, such that an image on our Services is displayed on another website. You agree not to link from any other website to our Services in such a way that any page of our Services is “framed” by any third-party content or branding. We reserve all rights under the law to insist that any link to our Services be discontinued, that the link open in a new browser window, and/or to revoke your right to link to our Services from any other website or service at any time upon written notice to you.",
                style: reg),
            Text("Our Service Providers.\n", style: bold),
            Text(
                "We provide some of our content, features, services, and software through contractual arrangements we make with third-party service providers, such as cloud storage and media processing vendors, payment processors, and customer support managers (each a “Service Provider”). We may disclose personal information and non-personal information or aggregated information to our Service Providers or they may collect it from you directly. We and our Service Providers may need to use your personal information in order to perform tasks between our respective sites, or to deliver content, features, services, or software to you. For example, payment information is collected by one of our Service Providers, and, if you pay by credit card, they may release your credit card information to the card-issuing bank to confirm payment for products and services purchased through our Services. Although our treatment of your personal information is explained by our Privacy Policy, our Service Providers’ treatment of your personal information will be governed by their respective privacy policies.\n\n",
                style: reg),
            Text("DISCLAIMER OF WARRANTIES.\n", style: bold),
            Text(
                "TBU PROVIDES OUR SERVICES “AS IS,” WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. YOU AGREE THAT YOUR USE OF OUR SERVICES, INCLUDING ANY OF ITS CONTENT, FEATURES OR FUNCTIONS, WILL BE AT YOUR SOLE RISK. TO THE FULLEST EXTENT PERMITTED BY LAW, TBU AND ITS OWNERS, DIRECTORS, OFFICERS, EMPLOYEES, REPRESENTATIVES, AND AGENTS DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH ACCESS TO OUR SERVICES AND USE BY YOU OR ANYONE ACCESSING OR USING OUR SERVICES THROUGH YOUR USER ACCOUNT (INCLUDING YOUR AUTHORIZED USERS AND INVITEES), INCLUDING, WITHOUT LIMITATION, WARRANTIES: (A) OF SPECIFIC PERFORMANCE, MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUALITY, NON-INFRINGEMENT, ACCURACY, OMISSIONS, COMPLETENESS, CURRENTNESS, AND DELAYS; (B) GUARANTEEING ANY PARTICULAR PERFORMANCE; (C) THAT ACCESS TO ANY CONTENT, FEATURE, FUNCTION, SERVICE, SOFTWARE, DEVICE WILL BE UNINTERRUPTED, SECURE, COMPLETE, OR VIRUS OR ERROR FREE; (D) AS TO THE ACCURACY OR LIFE OF ANY URL OR THIRD-PARTY WEB SERVICE; (E) REGARDING THE EFFECTS OF, OR RESULTS THAT MAY BE OBTAINED FROM, USE OF OUR SERVICES; AND (F) WITH REGARD TO ANY CONTENT, FEATURES, FUNCTIONS, OR SOFTWARE THAT HAS BEEN PROVIDED BY OR MODIFIED IN ANY WAY BY ANYONE OTHER THAN TBU, AND WITHOUT THE EXPRESS APPROVAL OF TBU.\n\nFURTHER, TBU DOES NOT WARRANT, ENDORSE, GUARANTEE, ASSUME, OR HAVE ANY RESPONSIBILITY OR LIABILITY FOR ANY CONTENT, FEATURE, FUNCTION, SOFTWARE, OR PRODUCT ADVERTISED OR OFFERED BY ANY THIRD-PARTY ON OR THROUGH OUR SERVICES. TBU IS NOT A PARTY TO OR IN ANY WAY RESPONSIBLE OR LIABLE FOR MONITORING ANY TRANSACTION BETWEEN ANY USERS OR ANY USER AND THIRD-PARTY PROVIDER OF ANY CONTENT, FEATURES, SERVICE, SOFTWARE, OR PRODUCT.\n\nAS WITH THE PURCHASE OF ANY CONTENT, SERVICE, SOFTWARE, OR PRODUCT THROUGH ANY MEDIUM OR IN ANY ENVIRONMENT, YOU SHOULD USE YOUR BEST JUDGMENT AND EXERCISE CAUTION WHEN TRANSACTING FOR ANY CONTENT, FEATURE, FUNCTION, SERVICE, SOFTWARE, OR PRODUCT OR WHEN COMMUNICATING WITH ANY OTHER USER OR THIRD PARTY.\n\n",
                style: reg),
            Text("LIMITATION OF LIABILITY.\n", style: bold),
            Text(
                "TBU HAS NO RESPONSIBILITY FOR, AND IN NO EVENT SHALL TBU, ITS OWNERS, DIRECTORS, OFFICERS, EMPLOYEES, REPRESENTATIVES, OR AGENTS, BE LIABLE TO YOU OR ANYONE ACCESSING OR USING OUR SERVICES (INCLUDING YOUR AUTHORIZED USERS OR INVITEES) OR RECEIVING ANY CONTENT YOU GENERATE AND/OR SHARE THROUGH OUR SERVICES, FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES WHATSOEVER, INCLUDING THOSE THAT RESULT FROM ANY: (A) ERRORS, OMISSIONS, MISTAKES, OR INACCURACIES, INCLUDING IN ANY SUBMITTED CONTENT; (B) REMOVAL OF CONTENT FROM OUR SERVICES; (C) PERSONAL INJURY OR PROPERTY DAMAGE OF ANY NATURE WHATSOEVER RESULTING FROM OR RELATED TO ACCESS TO OR USE OF OUR SERVICES; (D) UNAUTHORIZED ACCESS TO OR USE OF SERVERS OWNED OR USED BY TBU; (E) UNAUTHORIZED ACCESS TO ANY PERSONAL INFORMATION, FINANCIAL INFORMATION, OR OTHER DATA, AND/OR ANY USE THEREOF; (F) INTERRUPTION OR CESSATION OF TRANSMISSION TO OR FROM OUR SERVICES, INCLUDING ANY BUSINESS INTERRUPTION; (G) LOSS OR FAILURE TO RETAIN OR PROTECT ANY USER INFORMATION, PERSONAL INFORMATION, SUBMITTED CONTENT OR COMMUNICATIONS; (H) USER INABILITY OR FAILURE TO PERFORM OR CONDUCT ANY ACTION, OR TO PERFORM ANY ACTION PROPERLY OR COMPLETELY, EVEN IF ASSISTED BY TBU; (I) DECISION MADE OR ACTION TAKEN IN RELIANCE UPON THE ACCESS TO, OR AVAILABILITY OR USE OF OUR SERVICES; (J) BUGS, VIRUSES, TROJAN HORSES, OR THE LIKE WHICH MAY BE TRANSMITTED TO, THROUGH, OR AS A RESULT OF USE OF OUR SERVICES; (K) LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF ACCESS TO OR THE USE OF ANY INFORMATION OR CONTENT POSTED, EMAILED, TRANSMITTED, DOWNLOADED, UPLOADED, OR OTHERWISE MADE AVAILABLE THROUGH OR AS A RESULT OF USE OF OUR SERVICES, INCLUDING INFORMATION OR CONTENT PROVIDED, CREATED OR TRANSMITTED BY OR ON BEHALF OF A USER; (L) ANY VIOLATION OF APPLICABLE LAWS OR REGULATIONS, INCLUDING EXPORT CONTROL LAWS OR REGULATIONS; (M) INACCURATE OR INCOMPLETE INFORMATION RESULTING IN THE FAILURE TO OBTAIN PRIOR VERIFIED PARENTAL CONSENT FOR A CHILD’S USE OF OUR SERVICES; (N) ANY VIOLATION OF OUR POLICIES, INCLUDING BUT NOT LIMITED TO UNAUTHORIZED ACCESS TO OR USE OF A USER’S ACCOUNT; OR (O) FAILURE BY A SERVICE PROVIDER TO DELETE USER INFORMATION AS REQUESTED. THIS LIMITATION OF LIABILITY SHALL APPLY WHETHER BASED ON WARRANTY, CONTRACT, TORT (INCLUDING NEGLIGENCE), OR ANY OTHER LEGAL THEORY, AND WHETHER OR NOT TBU IS ADVISED OR AWARE OF THE POSSIBILITY OF SUCH DAMAGES OR LOSS. THE FOREGOING LIMITATION OF LIABILITY SHALL APPLY TO THE MAXIMUM EXTENT PERMITTED BY LAW.\n\nFURTHER, NOTWITHSTANDING THE FOREGOING, OUR MAXIMUM CUMULATIVE LIABILITY AND THE EXCLUSIVE REMEDY FOR ANY USER OR ACCOUNT HOLDER (INCLUDING ANY PERSON USING OUR WEBSITE AS A RESULT OF ACCESS GIVEN BY A USER) FOR ANY AND ALL CLAIMS ARISING OUT OF OR RELATED TO ACCESS TO OR USE OF OUR SERVICES, INCLUDING ANY OF THE FOREGOING WILL BE LIMITED TO AN AMOUNT EQUAL TO THE FEES WE ACTUALLY RECEIVE FROM SUCH USER OR ACCOUNT HOLDER (EXCLUSIVE OF ANY PAYMENTS RELATED THEREOF WHICH WE TRANSMIT TO OTHER USERS), IN THE SIX MONTHS PRECEDING THE EVENT OR CIRCUMSTANCE GIVING RISE TO SUCH CLAIM. FOR THE AVOIDANCE OF DOUBT, YOU SPECIFICALLY ACKNOWLEDGE THAT NONE OF TBU, ITS OWNERS, DIRECTORS, OFFICERS, EMPLOYEES, REPRESENTATIVES, OR AGENTS WILL BE LIABLE FOR ANY USER-SUBMITTED INFORMATION OR CONTENT OR ANY DEFAMATORY, MISLEADING, INFRINGING, OR OTHERWISE OFFENSIVE OR ILLEGAL STATEMENT OR CONDUCT OF ANY USER OR THIRD PARTY, AND THAT BY ACCESSING OR USING OUR SERVICES, THE RISK OF HARM OR DAMAGE FROM THE FOREGOING RESTS ENTIRELY WITH YOU.\n\n",
                style: reg),
            Text("Indemnification by You.\n", style: bold),
            Text(
                "You agree to defend, indemnify, and hold us and our owners, directors, officers, employees, representatives, and agents harmless from any and all claims, liabilities, losses, damages, penalties, costs and expenses, including attorneys' fees, arising in any way from: (a) your (and any user using through your account or authorized by you) (i) access to or use of our Services; (ii) transmission of any message, recording, communication, or sharing of any card through our Services to us or others; (iii) breach or threatened breach of our Policies; or (iv) your violation of any law or regulation.\n\n",
                style: reg),
            Text("Governing Law and Jurisdiction.\n", style: bold),
            Text(
                "Our Policies are governed exclusively by the internal laws of the State of Washington, without regard to conflict of law principles. By accessing and using our Services, you hereby irrevocably consent and submit to the exclusive jurisdiction of the state and federal courts located in Seattle, Washington, to adjudicate any dispute or claim arising out of or relating to your access or use of our Services, including our Policies, and you consent and submit to the personal jurisdiction of such courts for the purpose of litigating any such matters. You further hereby waive, to the extent not prohibited by applicable law, and agree not to assert by way of motion, as a defense or otherwise, in any such dispute any claim that you are not subject personally to the jurisdiction of the above-named courts, that your property is exempt or immune from attachment or execution, that any such proceeding brought in the above-named courts is improper, or that such disputes or claims cannot be enforced in or by such courts.\n\n",
                style: reg),
            Text("Location.\n", style: bold),
            Text(
                "You agree that: (a) our Services are deemed to be based solely in the State of Washington, USA; and (b) our Services are considered passive and do not give rise to personal jurisdiction over Turbo Blaster Unlimited, LLC, either specific or general, in any jurisdiction other than the State of Washington, USA. You further acknowledge that we do not claim, and we cannot guarantee, that our Services are or will be appropriate or available for any other location or jurisdiction, nor do we have any liability with respect thereto.\n\n",
                style: reg),
            Text("Construction.\n", style: bold),
            Text(
                "Headings used in our Policies are for convenience of reference only and will not affect in any way the meaning or interpretation of any provision contained therein. As used in our Policies, the plural includes the singular, the singular includes the plural, any reference to an entity or person means both, as applicable, any reference to the gender of any person shall be deemed adjusted to connote the gender of the person intended to be designated by such reference, and the words “includes” or “including” shall mean including without limitation.\n\n",
                style: reg),
            Text("Entire Agreement.\n", style: bold),
            Text(
                "Our Policies constitute the complete, exclusive, and fully integrated statement of the agreement between you and us with respect to their subject matter and supersede and preempt any other understandings, agreements, or representations, whether written or oral, related thereto.\n\n",
                style: reg),
            Text("Severability.\n", style: bold),
            Text(
                "If any term or provision of our Policies is deemed unlawful, void, or unenforceable by an arbitrator or court of competent jurisdiction, then that term or provision will be revised, limited, or eliminated from our Policies to the minimum extent necessary and will not affect the validity and enforceability of any remaining terms or provisions.\n\n",
                style: reg),
            Text("Successors and Assigns.\n", style: bold),
            Text(
                "Your agreement to be bound by our Policies shall bind and inure to the benefit of your and our successors and assigns; provided, however, that neither your agreement to be bound by our Policies nor any of your rights hereunder may be assigned by you without our prior written consent, which we may grant or withhold in our sole discretion.\n\n",
                style: reg),
            Text("Merger or Sale.\n", style: bold),
            Text(
                "If we are involved in a merger, acquisition, reorganization, consolidation, sale of assets, bankruptcy, or similar transaction or proceeding, some or all of our Services, including content and user data, may be sold or transferred as part of that transaction, and you hereby agree to the sale or transfer of your user data in connection therewith.\n\n",
                style: reg),
            Text("Injunctive Relief.\n", style: bold),
            Text(
                "You acknowledge that any use of our Services contrary to our Policies, or any transfer, sublicense, copying, or disclosure of technical information, content, or materials on or related thereto may cause irreparable injury to us and any other person or entity authorized by us to resell, distribute or promote our Services (a “Promoter”), and under such circumstances, we and our Promoters, in addition to remedies at law, will be entitled to equitable relief without posting bond or other security, including preliminary and/or permanent injunctive relief.\n\n",
                style: reg),
            Text("Waiver.\n", style: bold),
            Text(
                "Our failure (or delay) to exercise or enforce any right or provision of our Policies, will not constitute a waiver of such right or provision. Any waiver of any provision of our Policies will be effective only if in writing and signed by an authorized representative of TBU. \n\n",
                style: reg),
            Text("Language.\n", style: bold),
            Text(
                "All communications between you and us must be in English.\n\n",
                style: reg),
            Text("Communications.\n", style: bold),
            Text(
                "When you access or use our Services or send an email, message, recording, or other communications to us electronically, you consent to receive communication from us electronically or by any means, including email, text messages, mobile push notices, telephone, or video calls, and/or notices or messages through our App and/or our Website. If we send email or text messages to you at an email address or phone number you provided to us, you are deemed to have received such email or text message whether or not you actually did receive or read it. You are advised to retain copies of all written communications for your records. You agree that all electronic communications we provide to you satisfy any requirement that a communication or notice be in writing pursuant to our Policies or otherwise. Further, you agree that we may contact you using autodialed or prerecorded calls at any telephone number you have provided to us. You agree that we may contact you by any form of communication to: (a) contact you regarding your relationship with us or use of our Services; (b) facilitate marketing efforts; (c) resolve a dispute; (d) respond to inquiries; (e) troubleshoot or as we determine is otherwise required; (f) enforce our Policies or any other agreement we may have with you; or (g) as requested by any law enforcement, governmental, or similar agency. You understand and agree that we may, in our sole discretion, use a third-party service or by doing so ourselves, monitor and/or record any communications between you and our employees, contractors, representatives, or agents for purposes of quality control and for our own protection. If you do not consent to the recording of telephone or video calls by us, your only remedy is to not engage with us by such means. We may use automated systems to scan, analyze, and/or store the contents of some or all communications, including messages sent to us or other users through our Services, to detect and prevent fraudulent activity, violations of our Policies, or otherwise. This scanning and analysis may occur before, during, or after the communication is sent or while in storage, and may result in your communication being delayed or withheld.\n\n",
                style: reg),
            Text("Force Majeure.\n", style: bold),
            Text(
                "We and our affiliates and subsidiaries, and our and their respective owners, directors, officers, employees, representatives, and agents will not be liable for any delay or failure to perform any obligation under our Policies where the delay or failure is related to any cause beyond our control, including acts of God, epidemics, labor disputes or other industrial disturbances, electrical or power outages, utilities or other telecommunications failures, earthquake, storms or other elements of nature, blockages, embargoes, riots, acts or orders of government, acts of terrorism, war, or third-party failures.\n\n",
                style: reg),
            Text("Contact Us.\n", style: bold),
            Text(
                "If you have questions about our Policies, please contact us at 8240 14th Ave NE Seattle, WA 98115 or support@turboblasterunlimited.com.\n\n",
                style: reg),
          ],
        ),
      ),
    );
  }
}
