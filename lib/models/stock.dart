class Stock {
  static List<Map<String, dynamic>> stockMovements = [];
  static List<Map<String, dynamic>> movements = [];
}

enum StockMovementType {
  entry('Entrée'),
  exit('Sortie'),
  adjustment('Ajustement'),
  transfer('Transfert');

  final String label;
  const StockMovementType(this.label);
}
