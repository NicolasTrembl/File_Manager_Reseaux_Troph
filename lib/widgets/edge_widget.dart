import 'package:flutter/material.dart';
import '/logic/graph.dart';
import '/widgets/edit_value.dart';

class EdgesWidget extends StatefulWidget {
  const EdgesWidget({
    super.key,
    required this.graph,
    required this.widgetSize,
    required this.setGlobalState,
  });

  final Graph graph;
  final Size widgetSize;
  final Function setGlobalState;

  @override
  State<EdgesWidget> createState() => _EdgesWidgetState();
}

class _EdgesWidgetState extends State<EdgesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints.loose(
        widget.widgetSize.height > 550
            ? widget.widgetSize
            : Size(
                widget.widgetSize.width > 300 ? widget.widgetSize.width : 300,
                550,
              ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edges",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    if (widget.graph.nodes.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text("You need at least 2 nodes to add an edge"),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      widget.graph.edges.add(
                        Edge(
                          source: widget.graph.nodes[0].alias,
                          target: widget.graph.nodes[1].alias,
                          weight: 1,
                          predationRate: 0.1,
                          assimilationRate: 0.1,
                        ),
                      );
                    });
                    widget.setGlobalState();
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: widget.graph.edges.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: EdgeCard(
                    key: UniqueKey(),
                    edge: widget.graph.edges[index],
                    graph: widget.graph,
                    setGlobalState: () {
                      setState(() {});
                      widget.setGlobalState();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EdgeCard extends StatefulWidget {
  const EdgeCard({
    super.key,
    required this.edge,
    required this.graph,
    required this.setGlobalState,
  });

  final Edge edge;
  final Graph graph;
  final Function setGlobalState;

  @override
  State<EdgeCard> createState() => _EdgeCardState();
}

class _EdgeCardState extends State<EdgeCard> {
  String from = "";
  String to = "";

  void deleteEdge() {
    setState(() {
      widget.graph.edges.remove(widget.edge);
    });
    widget.setGlobalState();
  }

  @override
  void initState() {
    from = widget.edge.source;
    to = widget.edge.target;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: deleteEdge,
        child: const Icon(Icons.delete),
      ),
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButton(
                value: from,
                isExpanded: true,
                underline: const SizedBox(),
                items: widget.graph.nodes
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.alias,
                        child: Center(child: Chip(label: Text(e.alias))),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    from = value!;
                    widget.edge.source = value;
                  });
                  widget.setGlobalState();
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_forward),
            ),
            Expanded(
              child: DropdownButton(
                value: to,
                isExpanded: true,
                underline: const SizedBox(),
                items: widget.graph.nodes
                    .map((e) => DropdownMenuItem(
                          value: e.alias,
                          child: Center(child: Chip(label: Text(e.alias))),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  setState(() {
                    to = value!;
                    widget.edge.target = value;
                  });
                  widget.setGlobalState();
                },
              ),
            ),
          ],
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionChip(
            label: Text(widget.edge.weight.toString()),
            avatar: const Icon(Icons.share_location_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: EditValueScreen(
                    value: widget.edge.weight,
                    onSet: (value) {
                      widget.edge.weight = value as int;
                      setState(() {});
                      widget.setGlobalState();
                    },
                    typeOfData: TypeOfData.number,
                    text: const [
                      "Weight",
                      "Enter the new weight",
                    ],
                  ),
                ),
              );
            },
          ),
          ActionChip(
            label: Text("${widget.edge.predationRate * 100}%"),
            avatar: const Icon(Icons.sports_gymnastics_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: EditValueScreen(
                      value: widget.edge.predationRate,
                      onSet: (value) {
                        widget.edge.predationRate = value as double;
                        setState(() {});
                        widget.setGlobalState();
                      },
                      typeOfData: TypeOfData.rate,
                      text: const [
                        "Predation rate",
                        "Enter the new predation rate",
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ActionChip(
            label: Text("${widget.edge.assimilationRate * 100}%"),
            avatar: const Icon(Icons.restaurant_menu_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: EditValueScreen(
                      value: widget.edge.assimilationRate,
                      onSet: (value) {
                        widget.edge.assimilationRate = value as double;
                        setState(() {});
                        widget.setGlobalState();
                      },
                      typeOfData: TypeOfData.rate,
                      text: const [
                        "Assimilation rate",
                        "Enter the new assimilation rate",
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
