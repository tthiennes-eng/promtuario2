import 'package:flutter_test/flutter_test.dart';
import 'package:promt/core/network/api_client.dart';

void main() {
  test('ApiClient.resolveOrigin supports localhost, LAN IP, custom port, and HTTPS URLs', () {
    expect(ApiClient.resolveOrigin('https://clinica.ufma.br/'), 'https://clinica.ufma.br');
    expect(ApiClient.resolveOrigin('http://192.168.1.10:8080'), 'http://192.168.1.10:8080');
    expect(ApiClient.resolveOrigin('192.168.1.10'), 'http://192.168.1.10:5000');
    expect(ApiClient.resolveOrigin('192.168.1.10:7000'), 'http://192.168.1.10:7000');
  });
}
