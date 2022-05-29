import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ManipulaArquivo {
  Future<File> _criarArquivo() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/atividades.json");
  }

  Future<String> readAtividade() async {
    try {
      final file = await _criarArquivo();
      return file.readAsString();
    } catch (e) {
      return "Erro ao ler arquivo";
    }
  }

  Future<File> saveAtividade(List atividadeList) async {
    String data = json.encode(atividadeList);
    final file = await _criarArquivo();
    return file.writeAsString(data);
  }
}
