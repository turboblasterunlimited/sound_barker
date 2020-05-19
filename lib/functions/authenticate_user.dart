import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

authenticate(String clientId, List<String> scopes) async {
  // create the client
  var issuer = await Issuer.discover(Issuer.google);
  var client = new Client(issuer, clientId);

  // create a function to open a browser with an url
  urlLauncher(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  // create an authenticator
  var authenticator = new Authenticator(client,
      scopes: scopes, port: 4000, urlLancher: urlLauncher);

  // starts the authentication
  var c = await authenticator.authorize();

  // close the webview when finished
  closeWebView();

  // return token for server
  return await c.getTokenResponse();
}