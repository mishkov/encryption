import 'package:encryption/affine_caesar_substitution.dart';
import 'package:encryption/caesar_encryption.dart';
import 'package:encryption/caesar_encryption_with_key_word.dart';
import 'package:flutter/material.dart';

import 'trisemus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Шифрование',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Шифрование'),
      routes: {
        CaesarEncryption.route: (context) => const CaesarEncryption(),
        AffineCaesarSubstitution.route: (context) =>
            const AffineCaesarSubstitution(),
        CaesarEncryptionWithKeyWord.route: (context) =>
            const CaesarEncryptionWithKeyWord(),
        Trisemus.route: (context) => const Trisemus(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth > 400 ? 400 : constraints.maxWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, CaesarEncryption.route);
                    },
                    child: const Text('Шифрование Цезаря'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, AffineCaesarSubstitution.route);
                    },
                    child: const Text('Aффинная система подстановок Цезаря'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        CaesarEncryptionWithKeyWord.route,
                      );
                    },
                    child: const Text('Шифрование Цезаря с ключевым словом'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Trisemus.route,
                      );
                    },
                    child: const Text('Трисемус'),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
