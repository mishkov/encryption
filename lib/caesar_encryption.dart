import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaesarEncryption extends StatefulWidget {
  static const route = '/caesar';

  const CaesarEncryption({Key? key}) : super(key: key);

  @override
  State<CaesarEncryption> createState() => CcaesarEncryptionState();
}

class CcaesarEncryptionState extends State<CaesarEncryption> {
  final _sourceController = TextEditingController();
  final _encryptedController = TextEditingController();
  final _keyController = TextEditingController(text: '10');

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
      appBar: AppBar(title: const Text('Шифрование Цезаря')),
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
    final messenger = ScaffoldMessenger.of(context);

    final key = int.tryParse(_keyController.text);
    if (key == null) {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: const Text('Некорректный ключ!'),
          actions: [
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    for (final char in _alphabet) {
      _table[char] =
          _alphabet[(_alphabet.indexOf(char) + key) % _alphabet.length];
    }

    final source = _sourceController.text.toUpperCase().characters;
    String encryptedText = '';
    for (final char in source) {
      if (_alphabet.contains(char)) {
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
    final messenger = ScaffoldMessenger.of(context);

    final key = int.tryParse(_keyController.text);
    if (key == null) {
      messenger.showMaterialBanner(
        MaterialBanner(
          content: const Text('Некорректный ключ!'),
          actions: [
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    final source = _encryptedController.text.toUpperCase().characters;
    String decryptedText = '';
    for (final char in source) {
      if (_alphabet.contains(char)) {
        int index = _alphabet.indexOf(char) - key;
        if (index.isNegative) {
          index = _alphabet.length + index;
        }

        decryptedText += _alphabet[index];
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
                    1: IntrinsicColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: List.generate(
                        keys.length,
                        (index) {
                          final key = keys.elementAt(index);

                          return Text(key);
                        },
                      ),
                    ),
                    TableRow(
                      children: List.generate(
                        keys.length,
                        (index) {
                          final key = keys.elementAt(index);
                          final value = widget._table[key] ?? 'ERROR';

                          return Text(value);
                        },
                      ),
                    ),
                  ],
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

              formattedTable += '$key\t';
            }
            formattedTable += '\n';

            for (var i = 0; i < keys.length; i++) {
              final key = keys.elementAt(i);
              final value = widget._table[key];

              formattedTable += '$value\t';
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
