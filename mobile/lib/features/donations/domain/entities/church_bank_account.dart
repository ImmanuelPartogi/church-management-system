class ChurchBankAccount {
  final int id;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final bool isActive;
  final int displayOrder;

  const ChurchBankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.isActive,
    required this.displayOrder,
  });
}
