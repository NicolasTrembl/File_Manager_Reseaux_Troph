import 'dart:io';
import "package:flutter/material.dart";
import 'package:file_picker/file_picker.dart';
import '/pages/file_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Welcome to the File Manager",
            style: Theme.of(context).textTheme.displayLarge),
        Text("What would you like to do?",
            style: Theme.of(context).textTheme.headlineMedium),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BigWelcomeButton(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FilePage(
                          file: null,
                        ),
                      ),
                    );
                  },
                  children: [
                    Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 30,
                    ),
                    Text(
                      "Create new file",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BigWelcomeButton(
                  onTap: () async {
                    // ask for a file
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ["eco", "sim"],
                      dialogTitle: "Select a file",
                    );

                    if (result != null) {
                      File file = File(result.files.single.path!);
                      // open the file
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FilePage(
                            file: file,
                          ),
                        ),
                      );
                    } else {
                      // User canceled the picker
                    }
                  },
                  children: [
                    Icon(
                      Icons.download,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 30,
                    ),
                    Text(
                      "Open file",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    ));
  }
}

class BigWelcomeButton extends StatelessWidget {
  const BigWelcomeButton({
    super.key,
    required this.children,
    required this.onTap,
  });

  final List<Widget> children;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}
