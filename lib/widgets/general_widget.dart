import 'package:flutter/material.dart';
import '/logic/graph.dart';

class GeneralWidget extends StatefulWidget {
  const GeneralWidget({
    super.key,
    required this.widgetSize,
    required this.graph,
    required this.setGlobalState,
  });

  final Size widgetSize;
  final Graph graph;
  final Function setGlobalState;

  @override
  State<GeneralWidget> createState() => _GeneralWidgetState();
}

class _GeneralWidgetState extends State<GeneralWidget> {
  TextEditingController controller = TextEditingController();
  int order = 0;
  int size = 0;

  List<String> possibleParams = ["autoID", "autoOverride", "useAlias"];

  @override
  void initState() {
    controller.text = widget.graph.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.loose(
        widget.widgetSize.height > 300
            ? widget.widgetSize
            : Size(
                widget.widgetSize.width > 300 ? widget.widgetSize.width : 300,
                300,
              ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Général",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Titre",
                ),
                onChanged: (String value) {
                  widget.graph.name = value;
                },
                onSubmitted: (String value) {
                  widget.graph.name = value;
                  setState(() {});
                  widget.setGlobalState();
                },
                onTapOutside: (_) {
                  widget.graph.name = controller.text;
                  setState(() {});
                  widget.setGlobalState();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ordre : ${widget.graph.order}"),
                  Text("Taille : ${widget.graph.size}"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    for (String param in possibleParams)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ChoiceChip.elevated(
                          label: Text(param),
                          selected: widget.graph.params.contains(param),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                widget.graph.params.add(param);
                              } else {
                                widget.graph.params.remove(param);
                              }
                            });
                            widget.setGlobalState();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
