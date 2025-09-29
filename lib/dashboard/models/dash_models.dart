

class MerchantVerificationResponse {
  final String nextToken;
  final String state;
  final String code;
  final String nomBoutique;
  final String montantMin;
  final String montantMax;
  final String logo;

  MerchantVerificationResponse({
    required this.nextToken,
    required this.state,
    required this.code,
    required this.nomBoutique,
    required this.montantMin,
    required this.montantMax,
    required this.logo,
  });

  factory MerchantVerificationResponse.fromJson(Map<String, dynamic> json) {
    return MerchantVerificationResponse(
      nextToken: json['nextToken'] ?? '',
      state: json['state'] ?? '',
      code: json['code'] ?? '',
      nomBoutique: json['nomBoutique'] ?? '',
      montantMin: json['montant_min'] ?? '',
      montantMax: json['montant_max'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  bool get isSuccess => state == 'ok' && code == '00';
}



// Add this model class for the payment response
class PaymentVerificationResponse {
  final String nextToken;
  final String state;
  final String code;
  final String montantPay;
  final String montant;
  final String nomBoutique;
  final double remise;
  final String montantMin;
  final String montantMax;
  final String bonusClient;
  final String montantPayInternationale;
  final String commissionSupplementaire;
  final List<PaymentMethod> paymentMethods;
  final int nbPoint;
  final String logo;

  PaymentVerificationResponse({
    required this.nextToken,
    required this.state,
    required this.code,
    required this.montantPay,
    required this.montant,
    required this.nomBoutique,
    required this.remise,
    required this.montantMin,
    required this.montantMax,
    required this.bonusClient,
    required this.montantPayInternationale,
    required this.commissionSupplementaire,
    required this.paymentMethods,
    required this.nbPoint,
    required this.logo,
  });

  factory PaymentVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResponse(
      nextToken: json['nextToken'] ?? '',
      state: json['state'] ?? '',
      code: json['code'] ?? '',
      montantPay: json['montant_pay'] ?? '',
      montant: json['montant'] ?? '',
      nomBoutique: json['nomBoutique'] ?? '',
      remise: (json['remise'] as num?)?.toDouble() ?? 0.0,
      montantMin: json['montant_min'] ?? '',
      montantMax: json['montant_max'] ?? '',
      bonusClient: json['bonus_client'] ?? '',
      montantPayInternationale: json['montantPayInternationale'] ?? '',
      commissionSupplementaire: json['commission_supplementaire'] ?? '',
      paymentMethods: (json['paymentMethods'] as List? ?? [])
          .map((item) => PaymentMethod.fromJson(item))
          .toList(),
      nbPoint: json['nbPoint'] ?? 0,
      logo: json['logo'] ?? '',
    );
  }

  bool get isSuccess => state == 'ok' && code == '00';
}

class PaymentMethod {
  final String methode;
  final String libelle;
  final String? solde;
  final List<dynamic> listCartes;
  final List<dynamic> listWallets;

  PaymentMethod({
    required this.methode,
    required this.libelle,
    this.solde,
    required this.listCartes,
    required this.listWallets,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      methode: json['methode'] ?? '',
      libelle: json['libelle'] ?? '',
      solde: json['solde'],
      listCartes: json['listCartes'] ?? [],
      listWallets: json['listWallets'] ?? [],
    );
  }
}




// Add this model class for the payment validation response
class PaymentValidationResponse {
  final String state;
  final String code;
  final String nextToken;
  final String idTransaction;
  final String datePaiement;
  final String nomBoutique;
  final String service;
  final String montant;
  final String montantBase;
  final String codePaiement;
  final double remise;
  final String etatws;
  final String etat;
  final String bonus;
  final String modePaiement;
  final String message;
  final String soldeAfterPayment;
  final int nbPoint;
  final String etiquettePaiement;

  PaymentValidationResponse({
    required this.state,
    required this.code,
    required this.nextToken,
    required this.idTransaction,
    required this.datePaiement,
    required this.nomBoutique,
    required this.service,
    required this.montant,
    required this.montantBase,
    required this.codePaiement,
    required this.remise,
    required this.etatws,
    required this.etat,
    required this.bonus,
    required this.modePaiement,
    required this.message,
    required this.soldeAfterPayment,
    required this.nbPoint,
    required this.etiquettePaiement,
  });

  factory PaymentValidationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentValidationResponse(
      state: json['state'] ?? '',
      code: json['code'] ?? '',
      nextToken: json['nextToken'] ?? '',
      idTransaction: json['id_transaction'] ?? '',
      datePaiement: json['date_paiement'] ?? '',
      nomBoutique: json['nom_boutique'] ?? '',
      service: json['service'] ?? '',
      montant: json['montant'] ?? '',
      montantBase: json['montant_base'] ?? '',
      codePaiement: json['code_paiement'] ?? '',
      remise: (json['remise'] as num?)?.toDouble() ?? 0.0,
      etatws: json['etatws'] ?? '',
      etat: json['etat'] ?? '',
      bonus: json['bonus'] ?? '',
      modePaiement: json['mode_paiement'] ?? '',
      message: json['message'] ?? '',
      soldeAfterPayment: json['soldeAfterPayment'] ?? '',
      nbPoint: json['nbPoint'] ?? 0,
      etiquettePaiement: json['etiquette_paiement'] ?? '',
    );
  }

  bool get isSuccess => state == 'ok' && code == '00';
}



class WalletTransferResponse {
  final String state;
  final String code;
  final String nextToken;
  final String idTransaction;
  final String datePaiement;
  final String service;
  final String montant;
  final String etatws;
  final String etat;
  final String modePaiement;
  final String message;
  final String soldeAfterPayment;
  final String numeroDestinataire;

  WalletTransferResponse({
    required this.state,
    required this.code,
    required this.nextToken,
    required this.idTransaction,
    required this.datePaiement,
    required this.service,
    required this.montant,
    required this.etatws,
    required this.etat,
    required this.modePaiement,
    required this.message,
    required this.soldeAfterPayment,
    required this.numeroDestinataire,
  });

  factory WalletTransferResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransferResponse(
      state: json['state'] ?? '',
      code: json['code'] ?? '',
      nextToken: json['nextToken'] ?? '',
      idTransaction: json['id_transaction'] ?? '',
      datePaiement: json['date_paiement'] ?? '',
      service: json['service'] ?? '',
      montant: json['montant'] ?? '',
      etatws: json['etatws'] ?? '',
      etat: json['etat'] ?? '',
      modePaiement: json['mode_paiement'] ?? '',
      message: json['message'] ?? '',
      soldeAfterPayment: json['soldeAfterPayment'] ?? '',
      numeroDestinataire: json['numeroDestinataire'] ?? '',
    );
  }

  bool get isSuccess => state == 'ok' && code == '00';
}
 

class TransferRequestResponse {
  final String code;
  final String state;
  final String nextToken;
  final String nomDestinataire;
  final String montantPayInternationale;
  final String montantPay;
  final String commissionSupplementaire;
  final List<PaymentMethod> paymentMethods;
  final int nbPoint;

  TransferRequestResponse({
    required this.code,
    required this.state,
    required this.nextToken,
    required this.nomDestinataire,
    required this.montantPayInternationale,
    required this.montantPay,
    required this.commissionSupplementaire,
    required this.paymentMethods,
    required this.nbPoint,
  });

  factory TransferRequestResponse.fromJson(Map<String, dynamic> json) {
    return TransferRequestResponse(
      code: json['code'] ?? '',
      state: json['state'] ?? '',
      nextToken: json['nextToken'] ?? '',
      nomDestinataire: json['nomDestinataire'] ?? '',
      montantPayInternationale: json['montantPayInternationale'] ?? '',
      montantPay: json['montant_pay'] ?? '',
      commissionSupplementaire: json['commission_supplementaire'] ?? '',
      paymentMethods: (json['paymentMethods'] as List? ?? [])
          .map((item) => PaymentMethod.fromJson(item))
          .toList(),
      nbPoint: json['nbPoint'] ?? 0,
    );
  }

  bool get isSuccess => state == 'ok' && code == '00';
  String get fullName => nomDestinataire;
}
 

class TransferValidationResponse {
  final String code;
  final String state;
  final String soldeAfterPayment;
  final String message;
  final String nextToken;
  final String idTransaction;
  final String datePaiement;
  final String idWalletBeneficiaire;
  final String nomBeneficiaire;
  final String montant;
  final String etatws;
  final String etat;
  final String modePaiement;
  final int nbPoint;

  TransferValidationResponse({
    required this.code,
    required this.state,
    required this.soldeAfterPayment,
    required this.message,
    required this.nextToken,
    required this.idTransaction,
    required this.datePaiement,
    required this.idWalletBeneficiaire,
    required this.nomBeneficiaire,
    required this.montant,
    required this.etatws,
    required this.etat,
    required this.modePaiement,
    required this.nbPoint,
  });

  factory TransferValidationResponse.fromJson(Map<String, dynamic> json) {
    return TransferValidationResponse(
      code: json['code'] ?? '',
      state: json['state'] ?? '',
      soldeAfterPayment: json['soldeAfterPayment'] ?? '',
      message: json['message'] ?? '',
      nextToken: json['nextToken'] ?? '',
      idTransaction: json['id_transaction'] ?? '',
      datePaiement: json['date_paiement'] ?? '',
      idWalletBeneficiaire: json['idWalletBeneficiaire'] ?? '',
      nomBeneficiaire: json['nomBeneficiaire'] ?? '',
      montant: json['montant'] ?? '',
      etatws: json['etatws'] ?? '',
      etat: json['etat'] ?? '',
      modePaiement: json['mode_paiement'] ?? '',
      nbPoint: json['nbPoint'] ?? 0,
    );
  }

  bool get isSuccess => state == 'ok' && code == '00';
}
