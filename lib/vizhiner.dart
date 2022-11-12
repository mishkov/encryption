import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Vizhiner extends StatefulWidget {
  static const route = '/vizhiner';
  const Vizhiner({Key? key}) : super(key: key);

  @override
  State<Vizhiner> createState() => CcaesarEncryptionState();
}

class CcaesarEncryptionState extends State<Vizhiner> {
  final _sourceController = TextEditingController();
  final _encryptedController = TextEditingController();
  final _keyWordControleer = TextEditingController(text: 'ИНФОРМАЦИЯ');

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

  final List<List<String>> _table = List.filled(4, []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Система Вижинера')),
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
    String encryptedText = '';

    final message = _sourceController.text.toUpperCase().characters;

    for (int rowIndex = 0; rowIndex < _table.length; rowIndex++) {
      _table[rowIndex] = List.filled(message.length, ' ');
    }

    int keyWordIterator = 0;
    final keyWord = _keyWordControleer.text.toUpperCase();
    for (int i = 0; i < message.length; i++) {
      // message
      _table[0][i] = message.elementAt(i);

      // keyword
      if (keyWord.isNotEmpty) {
        if (_alphabet.contains(message.elementAt(i))) {
          _table[1][i] = keyWord[keyWordIterator];
          keyWordIterator++;
          if (keyWordIterator == keyWord.length) {
            keyWordIterator = 0;
          }
        }
      }

      // keys
      if (_alphabet.contains(_table[1][i])) {
        _table[2][i] = _alphabet.indexOf(_table[1][i]).toString();
      }

      // result
      if (int.tryParse(_table[2][i]) != null) {
        _table[3][i] = _encryptSingle(
          message.elementAt(i),
          int.parse(_table[2][i]),
        );
      } else {
        _table[3][i] = message.elementAt(i);
      }

      encryptedText += _table[3][i];
    }

    setState(() {
      _encryptedController.text = encryptedText;
    });
  }

  String _encryptSingle(String source, int key) {
    if (_alphabet.contains(source)) {
      final index = (_alphabet.indexOf(source) + key) % _alphabet.length;
      return _alphabet[index];
    }

    return source;
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
    final rowNames = ['Сообщение', 'Ключевое слово', 'Ключ', 'Шифртекст'];

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
              onPressed: () {
                setState(() {
                  toShowTable = !toShowTable;
                });
              },
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
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                      },
                      border: TableBorder.all(),
                      children: List.generate(
                        4,
                        (row) {
                          return TableRow(
                            children: [
                              Text(rowNames[row]),
                              ...List.generate(
                                widget.table[row].length,
                                (column) {
                                  return Text(
                                    widget.table[row][column].toString(),
                                  );
                                },
                              ),
                            ],
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
                          String row = '${rowNames[i]}\t';
                          for (var j = 0; j < widget.table[i].length; j++) {
                            row += '${widget.table[i][j]}\t';
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
