import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:lista_atividade/persistence/manipula_arquivo.dart';
import 'package:lista_atividade/model/atividade.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ManipulaArquivo manipulaArquivo = ManipulaArquivo();

  final _atividadeController = TextEditingController();
  Map<String, dynamic>? _ultimoRemovido;
  int? _ultimoRemovidoPos;
  List _atividadeList = [];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Atividades"),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _atividadeController,
                    decoration: InputDecoration(labelText: "Nova atividade"),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addAtividade();
                  },
                  child: Text("+"),
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _atividadeList.length,
                  itemBuilder: buildItem),
            ),
          ),
        ],
      ),
    );
  }

  //carregar atividades gravadas
  @override
  void initState() {
    super.initState();
    manipulaArquivo.readAtividade().then((dado) {
      setState(() {
        _atividadeList = json.decode(dado);
      });
    });
  }

  //adiciona nova atividade a lista
  void _addAtividade() {
    setState(() {
      Map<String, dynamic> novaAtividade = Map();
      Atividade atividade = Atividade(_atividadeController.text, false);
      novaAtividade = atividade.getAtividade();
      _atividadeController.text = "";
      _atividadeList.add(novaAtividade);
      manipulaArquivo.saveAtividade(_atividadeList);
    });
  }

  //Metodo responsavel por ordenar atividades nao concluidas acima das concluidas
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _atividadeList.sort((a, b) {
        if (a["concluida"] && !b["concluida"])
          return 1;
        else if (!a["concluida"] && b["concluida"])
          return -1;
        else
          return 0;
      });
      manipulaArquivo.saveAtividade(_atividadeList);
    });
    return null;
  }

  //excluir item e desfazer exclusao
  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_atividadeList[index]["nome"]),
        value: _atividadeList[index]["concluida"],
        secondary: CircleAvatar(
          child: Icon(
              _atividadeList[index]["concluida"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _atividadeList[index]["concluida"] = c;
            manipulaArquivo.saveAtividade(_atividadeList);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _ultimoRemovido = Map.from(_atividadeList[index]);
          _ultimoRemovidoPos = index;
          _atividadeList.removeAt(index);
          manipulaArquivo.saveAtividade(_atividadeList);
          final snack = SnackBar(
            content: Text("Atividade \"${_ultimoRemovido!["nome"]}\"removida!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _atividadeList.insert(_ultimoRemovidoPos!, _ultimoRemovido);
                    manipulaArquivo.saveAtividade(_atividadeList);
                  });
                }),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }
}
