import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    final a = int.tryParse(_aController.text);
    if (!checkKey(() => a != null, 'Неверное знаячениеb a')) return;

    final b = int.tryParse(_bController.text);
    if (!checkKey(() => b != null, 'Неверное знаячение b')) return;

    if (!checkKey(
      () => b!.gcd(_alphabet.length) == 1,
      'Неверное знаячение b. Максимальный общий делитель m и b должен быть 1',
    )) return;

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

  bool checkKey(bool Function() isValid, String errorMessage) {
    if (!isValid()) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showMaterialBanner(
        MaterialBanner(
          content: Text(errorMessage),
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
      return false;
    } else {
      return true;
    }
  }

  void _decrypt() {
    final messenger = ScaffoldMessenger.of(context);

    final key = int.tryParse(_aController.text);
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
