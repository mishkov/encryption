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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шифрование Цезаря')),
      body: Center(
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

    final source = _sourceController.text.toUpperCase().characters;
    String encryptedText = '';
    for (final char in source) {
      if (_alphabet.contains(char)) {
        encryptedText +=
            _alphabet[(_alphabet.indexOf(char) + key) % _alphabet.length];
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
