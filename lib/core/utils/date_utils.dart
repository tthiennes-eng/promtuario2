class SafeDateParser {
  /// Converte qualquer valor (DateTime, int, String) para DateTime Local de forma resiliente.
  static DateTime parse(dynamic v) {
    return parseNullable(v) ?? DateTime.now();
  }

  /// Versão que retorna null se o valor for inválido ou nulo.
  static DateTime? parseNullable(dynamic v) {
    if (v == null || v.toString().trim().isEmpty || v.toString() == 'null') {
      return null;
    }
    
    try {
      // 1. Se já for DateTime
      if (v is DateTime) return v.isUtc ? v.toLocal() : v;
      
      // 2. Se for um número (Timestamp vindo do Drift ou API)
      if (v is int) {
        if (v < 10000000000) return DateTime.fromMillisecondsSinceEpoch(v * 1000).toLocal();
        return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
      }
      
      final s = v.toString().trim();
      
      // 3. Tentar parse de String numérica
      final n = int.tryParse(s);
      if (n != null && s.length >= 10) {
        if (n < 10000000000) return DateTime.fromMillisecondsSinceEpoch(n * 1000).toLocal();
        return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
      }

      // 4. Tentar parse ISO padrão
      final dateStr = (s.contains('T') || s.contains(' ')) ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return null;
    }
  }
}
