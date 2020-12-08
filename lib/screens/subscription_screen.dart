import 'dart:async';
import 'dart:io';

import 'package:K9_Karaoke/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

final String itemId = "68c73107cd4643458af014b47b8e3fa2";

class SubscriptionScreen extends StatefulWidget {
  static const routeName = 'subscription-screen';
  SubscriptionScreen();

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  InAppPurchaseConnection _iap = InAppPurchaseConnection.instance;
  bool available = true;

  List<ProductDetails> _products = [];

  List<PurchaseDetails> _purchases = [];

  StreamSubscription _subscription;

  bool hasSubscription = false;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _initialize() async {
    available = await _iap.isAvailable();

    if (available) {
      List<Future> futures = [_getProducts(), _getPastPurchases()];
      await Future.wait(futures);

      _subscription = _iap.purchaseUpdatedStream.listen((data) => setState(() {
            print("New Purchase");
            _purchases.addAll(data);
          }));
    }
  }

  bool hasPurchase() {
    return _purchases.isNotEmpty;
  }

  void makePurchase() {}

  Future<void> _getProducts() async {
    Set<String> ids = Set.from([itemId]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    print("product details response: $response");
    setState(() => _products = response.productDetails);
  }

  Future<void> _getPastPurchases() async {
    QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        _iap.completePurchase(purchase);
      }
    }

    setState(() => _purchases = response.pastPurchases);
  }

  PurchaseDetails _hasPurchased(String productId) {
    return _purchases.firstWhere((purchase) => purchase.productID == productId,
        orElse: () => null);
  }

  void _verifyPurchase() {
    PurchaseDetails purchase = _hasPurchased(itemId);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      setState(() => hasSubscription = true);
    }
  }

  void _buyProduct(ProductDetails details) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: details);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context, isMenu: true, pageTitle: "Terms of Use"),
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
            Padding(padding: EdgeInsets.only(top: 75)),
            Center(
                child: Text(hasPurchase() ? "Subscribed" : "Not Subscribed")),
            Center(
              child: RawMaterialButton(
                child: Text("Buy Subscription"),
                onPressed: makePurchase,
              ),
            )
          ],
        ),
      ),
    );
  }
}
