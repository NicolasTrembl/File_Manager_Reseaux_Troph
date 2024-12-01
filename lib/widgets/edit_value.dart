import 'package:flutter/material.dart';
import '/logic/graph.dart';

class EditValueScreen extends StatefulWidget {
  const EditValueScreen({
    super.key,
    required this.value,
    required this.onSet,
    required this.typeOfData,
    required this.text,
  });

  final dynamic value;
  final void Function(dynamic) onSet;
  final TypeOfData typeOfData;
  final List<String> text;

  @override
  State<EditValueScreen> createState() => _EditValueScreenState();
}

class _EditValueScreenState extends State<EditValueScreen> {
  dynamic value;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    value = widget.value;

    if (widget.typeOfData == TypeOfData.rate) {
      controller.text = (value * 100).toString();
    } else {
      controller.text = value.toString();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              widget.text[1],
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width * 0.15,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Value",
                      border: InputBorder.none,
                      suffix: widget.typeOfData == TypeOfData.rate
                          ? const Text("%")
                          : widget.typeOfData == TypeOfData.kg
                              ? const Text("kg")
                              : null,
                    ),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    controller: controller,
                    autofocus: true,
                    onSubmitted: (String value) {
                      setState(() {
                        if (widget.typeOfData == TypeOfData.rate) {
                          this.value = double.parse(value) / 100;
                          if (this.value > 1) {
                            this.value = 1.0;
                          }
                        } else if (widget.typeOfData == TypeOfData.kg) {
                          this.value = double.parse(value);
                        } else {
                          this.value = int.parse(value);
                        }
                        if (this.value < 0) {
                          this.value = 0;
                        }
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        if (widget.typeOfData == TypeOfData.rate) {
                          value = double.parse(controller.text) / 100;
                          if (value > 1) {
                            value = 1.0;
                          }
                        } else if (widget.typeOfData == TypeOfData.kg) {
                          value = double.parse(controller.text);
                        } else {
                          value = int.parse(controller.text);
                        }
                        if (value < 0) {
                          value = 0;
                        }
                      });
                      widget.onSet(value);
                      Navigator.of(context).pop();
                    },
                    onTapOutside: (_) {
                      setState(() {
                        if (widget.typeOfData == TypeOfData.rate) {
                          value = double.parse(controller.text) / 100;
                          if (value < 0) {
                            value = 0.0;
                          }
                          if (value > 1) {
                            value = 1.0;
                          }
                        } else if (widget.typeOfData == TypeOfData.kg) {
                          value = double.parse(controller.text);
                          if (value < 0) {
                            value = 0.0;
                          }
                        } else {
                          value = int.parse(controller.text);
                          if (value < 0) {
                            value = 0;
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            Row(
              children: [
                const Spacer(
                  flex: 2,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (widget.typeOfData == TypeOfData.rate) {
                        value = double.parse(controller.text) / 100;
                        if (value < 0) {
                          value = 0.0;
                        }
                        if (value > 1) {
                          value = 1.0;
                        }
                      } else if (widget.typeOfData == TypeOfData.kg) {
                        value = double.parse(controller.text);
                        if (value < 0) {
                          value = 0.0;
                        }
                      } else {
                        value = int.parse(controller.text);
                        if (value < 0) {
                          value = 0;
                        }
                      }
                    });
                    widget.onSet(value);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Confirm"),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                const Spacer(
                  flex: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
