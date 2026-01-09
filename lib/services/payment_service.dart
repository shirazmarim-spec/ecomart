import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final ApiService api = ApiService();
  final String publishableKey =
      'pk_test_51ShK3eFEjUBLA4HFUp6hrTYrhSirvLMXKfHsQny135p7U5r9iHpTEXmYnKEwfObBPIRcgCPvUtYynJ4cCBq7t8zN00i3ZTy8z4';

  Future<void> init() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  Future<String> createPaymentIntent(int orderId) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/payments/intent'),
      headers: await api.getHeaders(withToken: true),
      body: jsonEncode({'order_id': orderId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['client_secret'];
    } else {
      throw Exception('Failed to create payment intent: ${response.body}');
    }
  }

  Future<bool> confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Ecomart',
          allowsDelayedPaymentMethods: true,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } catch (e) {
      debugPrint('Payment error: $e');
      return false;
    }
  }
}
