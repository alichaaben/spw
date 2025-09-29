// services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse {
  final String nextToken;
  final String state;
  final String code;
  final List<Transaction> list;
  final int totalItems;

  ApiResponse({
    required this.nextToken,
    required this.state,
    required this.code,
    required this.list,
    required this.totalItems,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      nextToken: json['nextToken'] ?? '',
      state: json['state'] ?? '',
      code: json['code'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      list: (json['list'] as List? ?? [])
          .map((item) => Transaction.fromJson(item))
          .toList(),
    );
  }
}

class Transaction {
  final String idTransaction;
  final String montant;
  final String datePaiement;
  final String etatws;
  final String etat;
  final String? service;
  final String abreviation;
  final String signe;
  final String hasTicket;
  final String imageUrl;
  final String icon;

  Transaction({
    required this.idTransaction,
    required this.montant,
    required this.datePaiement,
    required this.etatws,
    required this.etat,
    required this.service,
    required this.abreviation,
    required this.signe,
    required this.hasTicket,
    required this.imageUrl,
    required this.icon,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      idTransaction: json['id_transaction']?.toString() ?? '',
      montant: json['montant']?.toString() ?? '0.000',
      datePaiement: json['date_paiement']?.toString() ?? '',
      etatws: json['etatws']?.toString() ?? '',
      etat: json['etat']?.toString() ?? '',
      service: json['service']?.toString(),
      abreviation: json['abreviation']?.toString() ?? '',
      signe: json['signe']?.toString() ?? '+',
      hasTicket: json['hasTicket']?.toString() ?? 'no',
      imageUrl: json['imageUrl']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'info',
    );
  }

  // Convert to your existing Transaction model
  Transaction toAppTransaction() {
    return Transaction(
      idTransaction: idTransaction,
      montant: montant,
      datePaiement: datePaiement,
      etatws: etatws,
      etat: etat,
      service: service,
      abreviation: abreviation,
      signe: signe,
      hasTicket: hasTicket,
      imageUrl: imageUrl,
      icon: icon,
    );
  }
}

class TransactionService {
  static const String baseUrl = 'https://spw.demo-tunisie.tn/api';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<ApiResponse> getTransactionHistory({
    String? nextToken,
    int limit = 20,
  }) async {
    try {
      final Uri uri = Uri.parse('$baseUrl/gestiontransaction/historiqueTransaction');
      
      final Map<String, dynamic> body = {
        'limit': limit,
        if (nextToken != null && nextToken.isNotEmpty) 'nextToken': nextToken,
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ApiResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
}