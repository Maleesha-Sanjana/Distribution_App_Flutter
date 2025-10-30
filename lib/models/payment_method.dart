class PaymentMethod {
  final String id;
  final String name;
  final bool requiresDetails;
  final List<String>? requiredFields;

  const PaymentMethod({
    required this.id,
    required this.name,
    this.requiresDetails = false,
    this.requiredFields,
  });

  static List<PaymentMethod> get defaultMethods => const [
        PaymentMethod(
          id: 'cash',
          name: 'Cash',
          requiresDetails: false,
        ),
        PaymentMethod(
          id: 'cheque',
          name: 'Cheque',
          requiresDetails: true,
          requiredFields: ['cheque_number', 'bank', 'branch', 'date'],
        ),
        PaymentMethod(
          id: 'card',
          name: 'Credit/Debit Card',
          requiresDetails: true,
          requiredFields: ['card_number', 'card_type'],
        ),
        PaymentMethod(
          id: 'bank_transfer',
          name: 'Bank Transfer',
          requiresDetails: true,
          requiredFields: ['reference', 'bank', 'date'],
        ),
      ];
}
