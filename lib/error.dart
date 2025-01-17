import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> someFunction() async {
  try {
    // ... 可能抛出异常的代码 ...
  } catch (e, stackTrace) {
    print('发生错误: $e');
    await sendErrorLogToServer(e.toString(), stackTrace.toString());
  }
}

Future<void> sendErrorLogToServer(String error, String stackTrace) async {
  const url = 'https://your-server.com/api/logs';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'error': error,
      'stackTrace': stackTrace,
      'timestamp': DateTime.now().toIso8601String(),
      // 其他信息，如用户ID、设备信息等
    }),
  );

  if (response.statusCode == 200) {
    print('错误日志已成功发送到服务器');
  } else {
    print('发送错误日志失败: ${response.statusCode}');
  }
}