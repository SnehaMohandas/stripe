import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe/home.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51Nnb2dSFMbpC7C9eMP7XweQhobGrVVhJhGTt3oWbhsKMp8e50pS9UB2UqCIAX4bdyL9dFK4cS0QkCIVM9DsSm9e300kIgrIo9a';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Tutorial'),
      ),
      body: Center(
        child: InkWell(
          onTap: () async {
            // final paymentMethod = await Stripe.instance.createPaymentMethod(
            //     params: const PaymentMethodParams.card(
            //         paymentMethodData: PaymentMethodData()));
            await makePayment();
          },
          child: Container(
            height: 50,
            width: 200,
            color: Colors.green,
            child: const Center(
              child: Text(
                'Pay',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData =
          await createPaymentIntent('20', 'USD'); //json.decode(response.body);
      // print('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  setupIntentClientSecret:
                      'pk_test_51Nnb2dSFMbpC7C9eMP7XweQhobGrVVhJhGTt3oWbhsKMp8e50pS9UB2UqCIAX4bdyL9dFK4cS0QkCIVM9DsSm9e300kIgrIo9a',
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  //applePay: PaymentSheetApplePay.,
                  //googlePay: true,
                  //testEnv: true,
                  customFlow: true,
                  style: ThemeMode.dark,
                  // merchantCountryCode: 'US',
                  merchantDisplayName: 'Kashif'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('Payment exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              //       parameters: PresentPaymentSheetParameters(
              // clientSecret: paymentIntentData!['client_secret'],
              // confirmPayment: true,
              // )
              )
          //print("done");
          .then((newValue) {
        print('payment intent' + paymentIntentData!['id'].toString());
        print(
            'payment intent' + paymentIntentData!['client_secret'].toString());
        print('payment intent' + paymentIntentData!['amount'].toString());
        print('payment intent' + paymentIntentData.toString());
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
        // print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      print("failed");
      // print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount('20'),
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      print(body);
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
                "Bearer sk_test_51Nnb2dSFMbpC7C9e4eyAgdsBO0QUPgc2ow8uzrF9uSCitJZgi2KP4pn7XmnRyVJ9RwD11loubN6d8qx935Mqrtlb00eRW5X9wB",
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print('Create Intent reponse ===> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
}

// class StripePaymentScreen extends StatefulWidget {
//   const StripePaymentScreen({Key? key}) : super(key: key);

//   @override
//   State<StripePaymentScreen> createState() => _StripePaymentScreenState();
// }

// class _StripePaymentScreenState extends State<StripePaymentScreen> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initPaymentSheet();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Stripe In Flutter"),
//       ),
//       body: Center(
//         child: Card(
//           child: ElevatedButton(
//               onPressed: _displayPaymentSheet,
//               child: const Text("Open Payment Sheet")),
//         ),
//       ),
//     );
//   }

//   Future<void> initPaymentSheet() async {
//     try {
//       await stripe.Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: const stripe.SetupPaymentSheetParameters(
//           customFlow: true,
//           merchantDisplayName: 'Flutter Stripe Demo',
//           paymentIntentClientSecret: "",
//           customerEphemeralKeySecret: "",
//           customerId: "",
//           setupIntentClientSecret: "",
//           style: ThemeMode.light,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//       rethrow;
//     }
//   }

//   Future<void> _displayPaymentSheet() async {
//     try {
//       await stripe.Stripe.instance.presentPaymentSheet(
//           options: const stripe.PaymentSheetPresentOptions(timeout: 1200000));

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Payment successfully completed'),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('$e'),
//         ),
//       );
//     }
//   }
// }
