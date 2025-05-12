class ComparativeIncomes {
  int weekNumber;

  double totalIncome;
  
  double totalExpense;

  int totalProfit;

  ComparativeIncomes({
    required this.weekNumber,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalProfit,
  });

  factory ComparativeIncomes.fromJson(Map<String, dynamic> json) {
    return ComparativeIncomes(
      weekNumber: (json['weekNumbers'] as num).toInt(), // Convert to int
      totalIncome: (json['totalIncome'] as num).toDouble(), // Convert to double
      totalExpense: (json['totalExpense'] as num).toDouble(), // Convert to double
      totalProfit: (json['totalProfit'] as num).toInt(), // Convert to int
    );
  }
}