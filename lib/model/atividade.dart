class Atividade {
  String _nome;
  bool _concluida;

  Atividade(this._nome, this._concluida);

  bool get concluida => _concluida;
  String get nome => _nome;

  Map<String, dynamic> getAtividade() {
    Map<String, dynamic> atividade = Map();
    atividade["nome"] = _nome;
    atividade["concluida"] = _concluida;
    return atividade;
  }
}
