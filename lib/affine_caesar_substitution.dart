import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'check_key.dart';

class AffineCaesarSubstitution extends StatefulWidget {
  static const route = '/affine-caesar-substitution';

  const AffineCaesarSubstitution({Key? key}) : super(key: key);

  @override
  State<AffineCaesarSubstitution> createState() => CcaesarEncryptionState();
}

class CcaesarEncryptionState extends State<AffineCaesarSubstitution> {
  final _sourceController = TextEditingController();
  final _encryptedController = TextEditingController();
  final _aController = TextEditingController(text: '3');
  final _bController = TextEditingController(text: '4');

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
  Map<String, String> _shiftedIndexes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Афинная система подстановок Цезаря')),
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
                      'm:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 4),
                    Text(_alphabet.length.toString()),
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
                      controller: _aController,
                      decoration: const InputDecoration(
                        label: Text('a'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: _bController,
                      decoration: const InputDecoration(
                        label: Text('b'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    EncryptionTable(
                      a: int.tryParse(_aController.text) ?? 0,
                      b: int.tryParse(_bController.text) ?? 0,
                      table: _table,
                      indexes: _shiftedIndexes,
                    ),
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
    final a = int.tryParse(_aController.text);
    if (!checkKey(() => a != null, 'Неверное знаячениеb a', context)) return;

    final b = int.tryParse(_bController.text);
    if (!checkKey(() => b != null, 'Неверное знаячение b', context)) return;

    if (!checkKey(
      () => b!.gcd(_alphabet.length) == 1,
      'Неверное знаячение b. Максимальный общий делитель m и b должен быть 1',
      context,
    )) return;

    for (final char in _alphabet) {
      final charIndex = _alphabet.indexOf(char);
      final shiftedIndex = (a! * charIndex + b!) % _alphabet.length;

      _table[char] = _alphabet[shiftedIndex];
      _shiftedIndexes[char] = shiftedIndex.toString();
    }

    final source = _sourceController.text.toUpperCase().characters;
    String encryptedText = '';
    for (final char in source) {
      if (_alphabet.contains(char)) {
        final charIndex = _alphabet.indexOf(char);
        final shiftedIndex = (a! * charIndex + b!) % _alphabet.length;

        encryptedText += _alphabet[shiftedIndex];
      } else {
        encryptedText += char;
      }
    }

    setState(() {
      _encryptedController.text = encryptedText;
    });
  }

  void _decrypt() {
    final a = int.tryParse(_aController.text);
    if (!checkKey(() => a != null, 'Неверное знаячениеb a', context)) return;

    final b = int.tryParse(_bController.text);
    if (!checkKey(() => b != null, 'Неверное знаячение b', context)) return;

    if (!checkKey(
      () => b!.gcd(_alphabet.length) == 1,
      'Неверное знаячение b. Максимальный общий делитель m и b должен быть 1',
      context,
    )) return;

    int reverseA = 0;
    while ((a! * reverseA) % _alphabet.length != 1) {
      reverseA++;
      if (reverseA > 200) {
        if (!checkKey(() => b != null,
            'Не удалось подобрать reverseA. Проверено до 200', context)) return;
      }
    }
    final source = _encryptedController.text.toUpperCase().characters;
    String decryptedText = '';
    for (final char in source) {
      if (_alphabet.contains(char)) {
        final charIndex = _alphabet.indexOf(char);
        int shiftedIndex = reverseA * (charIndex - b!) % _alphabet.length;

        decryptedText += _alphabet[shiftedIndex];
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
    required this.a,
    required this.b,
    required this.indexes,
  })  : _table = table,
        super(key: key);

  final int a;
  final int b;
  final Map<String, String> _table;
  final Map<String, String> indexes;

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
              ? Table(border: TableBorder.all(), children: [
                  TableRow(
                    children: [
                      const Text('t'),
                      Text('${widget.a}t+${widget.b}'),
                      const Text(''),
                    ],
                  ),
                  ...List.generate(
                    keys.length,
                    (index) {
                      final key = keys.elementAt(index);
                      final value = widget._table[key] ?? 'ERROR';

                      return TableRow(
                        children: [
                          Text(key),
                          Text(widget.indexes[value] ?? 'error'),
                          Text(value),
                        ],
                      );
                    },
                  ),
                ])
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
