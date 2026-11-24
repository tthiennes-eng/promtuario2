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
    
    // 1. Se já for DateTime, garante fuso local
    if (v is DateTime) return v.isUtc ? v.toLocal() : v;
    
    // 2. Se for um número (Timestamp vindo do Drift ou API)
    if (v is int) {
      // Drift armazena segundos por padrão em algumas versões. 
      // Se < 10^11, tratamos como segundos.
      if (v < 100000000000) return DateTime.fromMillisecondsSinceEpoch(v * 1000).toLocal();
      return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
    }
    
    final s = v.toString().trim();
    
    // 3. Tentar parse de String numérica (timestamp em texto)
    final n = int.tryParse(s);
    if (n != null && s.length >= 10) {
      if (n < 100000000000) return DateTime.fromMillisecondsSinceEpoch(n * 1000).toLocal();
      return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
    }

    // 4. Tentar formatos comuns brasileiros (DD/MM/YYYY)
    if (s.contains('/') && s.split('/').length >= 3) {
      try {
        final parts = s.split(' ');
        final dateParts = parts[0].split('/');
        int day = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int year = int.parse(dateParts[2]);
        DateTime dt = DateTime(year, month, day);
        if (parts.length > 1 && parts[1].contains(':')) {
          final timeParts = parts[1].split(':');
          dt = dt.add(Duration(
            hours: int.parse(timeParts[0]), 
            minutes: int.parse(timeParts[1]),
            seconds: timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
          ));
        }
        return dt;
      } catch (_) {}
    }

    // 5. Tentar parse ISO padrão
    try {
      final dateStr = (s.contains('T') || s.contains(' ')) ? s : '${s}T00:00:00';
      final dt = DateTime.parse(dateStr);
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (e) {
      return null;
    }
  }
}
