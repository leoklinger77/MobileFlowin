class AvailableBanks {
  static const List<String> bancos = [
    'Carteira',
    'XP',
    'BTG',
    'Itaú',
    'Banco Inter',
    'Bradesco',
    'Caixa',
    'Santander',
    'Nubank',
    'Banco do Brasil',
  ];
  static const List<String> tiposConta = ['Corrente', 'Poupança', 'Investimentos'];

  /// Retorna o índice (posição) do banco na lista, ou -1 se não encontrado
  static int parseStringBank(String bank) {
    return bancos.indexOf(bank);
  }

  /// Retorna o nome do banco correspondente ao índice, ou 'Desconhecido' se o índice for inválido
  static String parseIntBank(int bank) {
    if (bank >= 0 && bank < bancos.length) {
      return bancos[bank];
    }
    return 'Desconhecido';
  }
}
