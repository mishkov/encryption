import 'package:encryption/check_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaesarEncryptionWithKeyWord extends StatefulWidget {
  static const route = '/caesar-with-key';

  const CaesarEncryptionWithKeyWord({Key? key}) : super(key: key);

  @override
  State<CaesarEncryptionWithKeyWord> createState() => CcaesarEncryptionState();
}

class CcaesarEncryptionState extends State<CaesarEncryptionWithKeyWord> {
  final _sourceController = TextEditingController();
  final _encryptedController = TextEditingController();
  final _keyController = TextEditingController(text: '10');
  final _keyWordControleer = TextEditingController(text: 'РАБОТА');

  final _alphabet = [
    'А',
    'Б',
    'В',
    'Г',
    'Д',
    'Е',
    'Ё',
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

  Map<String, String> _table = {};

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
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: _keyController,
                      decoration: const InputDecoration(
                        label: Text('Ключ'),
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
    final key = int.tryParse(_keyController.text);
    if (!checkKey(() => key != null, 'Некорректный ключ!', context)) return;
    if (!checkKey(
      () => (0 <= key!) && (key < _alphabet.length - 1),
      'Ключ должен быть в диапазоне 0<=ключ<=${_alphabet.length}',
      context,
    )) return;

    final keyWordLettersToPaste = <String>{};
    for (final char in _keyWordControleer.text.characters) {
      if (_alphabet.contains(char)) {
        keyWordLettersToPaste.add(char);
      }
    }

    _table = <String, String>{};
    var i = key!;
    for (var j = 0; j < keyWordLettersToPaste.length; i++, j++) {
      _table[_alphabet[i]] = keyWordLettersToPaste.elementAt(j);
    }

    final remainingLetters = <String>[];
    for (final char in _alphabet) {
      if (!keyWordLettersToPaste.contains(char)) {
        remainingLetters.add(char);
      }
    }

    for (final remainingLetter in remainingLetters) {
      _table[_alphabet[i]] = remainingLetter;
      i++;
      if (i == _alphabet.length) {
        i = 0;
      }
    }

    final source = _sourceController.text.toUpperCase().characters;
    String encryptedText = '';
    for (final char in source) {
      if (_table.containsKey(char)) {
        encryptedText += _table[char]!;
      } else {
        encryptedText += char;
      }
    }

    setState(() {
      _encryptedController.text = encryptedText;
    });
  }

  void _decrypt() {
    final key = int.tryParse(_keyController.text);
    if (!checkKey(() => key != null, 'Некорректный ключ!', context)) return;
    if (!checkKey(
      () => (0 <= key!) && (key < _alphabet.length - 1),
      'Ключ должен быть в диапазоне 0<=ключ<=${_alphabet.length}',
      context,
    )) return;

    final keyWordLettersToPaste = <String>{};
    for (final char in _keyWordControleer.text.characters) {
      if (_alphabet.contains(char)) {
        keyWordLettersToPaste.add(char);
      }
    }

    _table = <String, String>{};
    var i = key!;
    for (var j = 0; j < keyWordLettersToPaste.length; i++, j++) {
      _table[_alphabet[i]] = keyWordLettersToPaste.elementAt(j);
    }

    final remainingLetters = <String>[];
    for (final char in _alphabet) {
      if (!keyWordLettersToPaste.contains(char)) {
        remainingLetters.add(char);
      }
    }

    for (final remainingLetter in remainingLetters) {
      _table[_alphabet[i]] = remainingLetter;
      i++;
      if (i == _alphabet.length) {
        i = 0;
      }
    }

    final source = _encryptedController.text.toUpperCase().characters;
    String decryptedText = '';
    for (final char in source) {
      if (_table.containsValue(char)) {
        decryptedText += _table.keys.firstWhere((key) => _table[key] == char);
      } else {
        decryptedText += char;
      }
    }

    setState(() {
      _sourceController.text = decryptedText;
    });
  }
}

class EncryptionTable extends StatefulWidget {
  const EncryptionTable({
    Key? key,
    required Map<String, String> table,
  })  : _table = table,
        super(key: key);

  final Map<String, String> _table;

  @override
  State<EncryptionTable> createState() => _EncryptionTableState();
}

class _EncryptionTableState extends State<EncryptionTable> {
  bool toShowTable = false;

  @override
  Widget build(BuildContext context) {
    final keys = widget._table.keys;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Таблица соответствия:',
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
              ? Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    0: IntrinsicColumnWidth(),
                  },
                  children: List.generate(
                    keys.length,
                    (index) {
                      final key = keys.elementAt(index);
                      final value = widget._table[key] ?? 'ERROR';

                      return TableRow(
                        children: [
                          Text(index.toString()),
                          Text(key),
                          Text(value),
                        ],
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () {
            String formattedTable = '';

            for (var i = 0; i < keys.length; i++) {
              final key = keys.elementAt(i);
              final value = widget._table[key];

              formattedTable += '$i\t$key\t$value\t\n';
            }
            formattedTable += '\n';

            Clipboard.setData(ClipboardData(text: formattedTable));
          },
          child: const Text('Копировать таблицу'),
        ),
      ],
    );
  }
}
