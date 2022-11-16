import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Playfair extends StatefulWidget {
  static const route = '/playfair';
  const Playfair({Key? key}) : super(key: key);

  @override
  State<Playfair> createState() => CcaesarEncryptionState();
}

class CcaesarEncryptionState extends State<Playfair> {
  final _sourceController = TextEditingController();
  final _encryptedController = TextEditingController();
  final _keyWordControleer = TextEditingController(text: 'РАБОТА');

  final _alphabet = [
    'А',
    'Б',
    'В',
    'Г',
    'Д',
    'Е',
    'Ж',
    'З',
    'И',
    'Й',
    'К',
    'Л',
    'М',
    'Н',
    'О',
    'П',
    'Р',
    'С',
    'Т',
    'У',
    'Ф',
    'Х',
    'Ц',
    'Ч',
    'Ш',
    'Щ',
    'Ъ',
    'Ы',
    'Ь',
    'Э',
    'Ю',
    'Я',
  ];

  List<List<String>> _table = [];
  final _tableWidth = 8;
  final _tableHeight = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шифрование Цезаря с ключевым словом')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth > 500 ? 500 : constraints.maxWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Используемый алфавит:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 4),
                    Text(_alphabet.join(', ')),
                    const SizedBox(height: 16),
                    Text(
                      'Размер таблицы:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 4),
                    Text('${_tableHeight}x$_tableWidth'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _sourceController,
                      decoration: const InputDecoration(
                        label: Text('Незашифрованный текст'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _encryptedController,
                      decoration: const InputDecoration(
                        label: Text('Зашифрованный текст'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            '[${_alphabet.join().toUpperCase()}${_alphabet.join().toLowerCase()}]',
                          ),
                        ),
                      ],
                      controller: _keyWordControleer,
                      decoration: const InputDecoration(
                        label: Text('Ключевое слово'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EncryptionTable(table: _table),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _decrypt,
                          child: const Text('Дешифровать'),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _encrypt,
                          child: const Text('Шифровать'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _encrypt() {
    final keyWordLettersToPaste = <String>{};
    for (final char in _keyWordControleer.text.characters) {
      if (_alphabet.contains(char)) {
        keyWordLettersToPaste.add(char);
      }
    }

    _table = List.generate(
      _tableWidth,
      (index) => List.generate(_tableHeight, (index) => ''),
    );

    var i = 0;
    for (; i < keyWordLettersToPaste.length; i++) {
      _table[i % _tableWidth][i ~/ _tableWidth] =
          keyWordLettersToPaste.elementAt(i);
    }

    final remainingLetters = <String>[];
    for (final char in _alphabet) {
      if (!keyWordLettersToPaste.contains(char)) {
        remainingLetters.add(char);
      }
    }

    for (final remainingLetter in remainingLetters) {
      _table[i % _tableWidth][i ~/ _tableWidth] = remainingLetter;
      i++;
    }

    final source = _sourceController.text.toUpperCase().characters;
    String encryptedText = '';
    for (final char in source) {
      if (_alphabet.contains(char)) {
        encryptedText += findInTable(char);
      } else {
        encryptedText += char;
      }
    }

    setState(() {
      _encryptedController.text = encryptedText;
    });
  }

  String findInTable(String key) {
    for (var i = 0; i < _table.length; i++) {
      for (var j = 0; j < _table[i].length; j++) {
        if (_table[i][j] == key) {
          if (j + 1 == _table[i].length) {
            return _table[i][0];
          } else {
            return _table[i][j + 1];
          }
        }
      }
    }

    throw Exception('No such key in table: $key');
  }

  void _decrypt() {
    final keyWordLettersToPaste = <String>{};
    for (final char in _keyWordControleer.text.characters) {
      if (_alphabet.contains(char)) {
        keyWordLettersToPaste.add(char);
      }
    }

    _table = List.generate(
      _tableWidth,
      (index) => List.generate(_tableHeight, (index) => ''),
    );

    var i = 0;
    for (; i < keyWordLettersToPaste.length; i++) {
      _table[i % _tableWidth][i ~/ _tableWidth] =
          keyWordLettersToPaste.elementAt(i);
    }

    final remainingLetters = <String>[];
    for (final char in _alphabet) {
      if (!keyWordLettersToPaste.contains(char)) {
        remainingLetters.add(char);
      }
    }

    for (final remainingLetter in remainingLetters) {
      _table[i % _tableWidth][i ~/ _tableWidth] = remainingLetter;
      i++;
    }

    final source = _encryptedController.text.toUpperCase().characters;
    String decryptedText = '';

    // TODO: Implement
    for (final char in source) {
      if (_alphabet.contains(char)) {
        decryptedText += findOriginInTable(char);
      } else {
        decryptedText += char;
      }
    }

    setState(() {
      _sourceController.text = decryptedText;
    });
  }

  String findOriginInTable(String key) {
    for (var i = 0; i < _table.length; i++) {
      for (var j = 0; j < _table[i].length; j++) {
        if (_table[i][j] == key) {
          if ((j - 1).isNegative) {
            return _table[i][_table[i].length - 1];
          } else {
            return _table[i][j - 1];
          }
        }
      }
    }

    throw Exception('No such key in table: $key');
  }
}

class EncryptionTable extends StatefulWidget {
  const EncryptionTable({
    Key? key,
    required this.table,
  }) : super(key: key);

  final List<List<String>> table;

  @override
  State<EncryptionTable> createState() => _EncryptionTableState();
}

class _EncryptionTableState extends State<EncryptionTable> {
  bool toShowTable = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Таблица подстановок:',
              style: Theme.of(context).textTheme.headline6,
            ),
            TextButton(
              onPressed: widget.table.isNotEmpty
                  ? () {
                      setState(() {
                        toShowTable = !toShowTable;
                      });
                    }
                  : null,
              child: Text('${toShowTable ? "Спрятать" : "Показать"} таблицу'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: toShowTable
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Table(
                      border: TableBorder.all(),
                      children: List.generate(
                        4,
                        (row) {
                          return TableRow(
                            children: List.generate(
                              8,
                              (column) {
                                return Text(
                                    widget.table[column][row].toString());
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String formattedTable = '';

                        for (var i = 0; i < 4; i++) {
                          String row = '';
                          for (var j = 0; j < 8; j++) {
                            row += '${widget.table[j][i]}\t';
                          }
                          row += '\n';
                          formattedTable += row;
                        }

                        Clipboard.setData(ClipboardData(text: formattedTable));
                      },
                      child: const Text('Копировать таблицу'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
