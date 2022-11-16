import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'check_key.dart';

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
    print(getBigramFor('А', 'Й'));
    final keyWordLettersToPaste = <String>{};
    for (final char in _keyWordControleer.text.toUpperCase().characters) {
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
    String text = '';
    for (final letter in source) {
      if (_alphabet.contains(letter.toUpperCase())) {
        text += letter;
      }
    }
    checkKey(
      () => text.length % 2 == 0,
      'шифруемый текст должен иметь четное количество букв!',
      context,
    );
    checkKey(
      () {
        for (int i = 1; i < text.length; i++) {
          if (text[i] == text[i - 1]) {
            return false;
          }
        }
        return true;
      },
      'В шифруемом тексте не должно быть биграмм, содержащих две одинаковые буквы',
      context,
    );

    String encryptedText = '';

    for (int i = 0; i < text.length; i += 2) {
      final a = text[i];
      final b = text[i + 1];
      final bigram = getBigramFor(a, b);

      encryptedText += bigram;
    }
    setState(() {
      _encryptedController.text = encryptedText;
    });
  }

  String getBigramFor(String a, String b) {
    String result = '';

    if (isInSameColumn(a, b)) {
      for (final column in _table) {
        final aIndex = column.indexOf(a);

        if (aIndex != -1) {
          result += column[(aIndex + 1) % column.length];
        }

        final bIndex = column.indexOf(b);
        if (bIndex != -1) {
          final index = (bIndex + 1) % column.length;
          result += column[index];
        }
      }
    } else if (isInSameRow(a, b)) {
      for (int row = 0; row < _table.first.length; row++) {
        int aIndex = -1;
        int bIndex = -1;
        for (int column = 0; column < _table.length; column++) {
          if (_table[column][row] == a) {
            aIndex = column;
          }

          if (_table[column][row] == b) {
            bIndex = column;
          }
        }

        if (aIndex != -1 && bIndex != -1) {
          int index = (aIndex + 1) % _table.length;
          result += _table[index][row];

          index = (bIndex + 1) % _table.length;
          result += _table[index][row];
        }
      }
    } else {
      // x - column
      // y - row
      int ax = -1, ay = -1, bx = -1, by = -1;

      for (int row = 0; row < _table.first.length; row++) {
        for (int column = 0; column < _table.length; column++) {
          if (_table[column][row] == a) {
            ax = column;
            ay = row;
          }

          if (_table[column][row] == b) {
            bx = column;
            by = row;
          }
        }
      }

      if (ax == -1 || ay == -1 || bx == -1 || by == -1) {
        throw Exception();
      }

      int newX = ax;
      int newY = by;
      final rightResult = _table[newX][newY];
      newX = bx;
      newY = ay;
      final leftResult = _table[newX][newY];
      result += leftResult;
      result += rightResult;
    }

    return result.isNotEmpty ? result : a + b;
  }

  bool isInSameRowOrColumn(String a, String b) {
    return isInSameRow(a, b) || isInSameColumn(a, b);
  }

  bool isInSameColumn(String a, String b) {
    for (final column in _table) {
      if (column.contains(a) && column.contains(b)) {
        return true;
      }
    }

    return false;
  }

  bool isInSameRow(String a, String b) {
    for (int row = 0; row < _table.first.length; row++) {
      bool isContainA = false;
      bool isContainB = false;
      for (int column = 0; column < _table.length; column++) {
        if (_table[column][row] == a) {
          isContainA = true;
        }
        if (_table[column][row] == b) {
          isContainB = true;
        }
      }

      if (isContainA && isContainB) {
        return true;
      }
    }

    return false;
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
