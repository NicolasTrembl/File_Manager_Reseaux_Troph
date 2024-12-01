import 'package:flutter/material.dart';
import '/logic/graph.dart';
import '/widgets/edit_value.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget({
    super.key,
    required this.graph,
    required this.widgetSize,
    required this.setGlobalState,
  });

  final Graph graph;
  final Size widgetSize;
  final Function setGlobalState;

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints.loose(
        widget.widgetSize.height > 300
            ? widget.widgetSize
            : Size(
                widget.widgetSize.width > 300 ? widget.widgetSize.width : 300,
                300,
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
                  "Noeud",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    setState(() {
                      widget.graph.nodes.add(
                        Node(
                          name: "New Node",
                          alias: "NN",
                          deathRate: 0.1,
                          birthRate: 0.1,
                          capacity: 100,
                          population: 10,
                          biomassPerCapita: 0.1,
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
              // shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.graph.nodes.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NodeCard(
                    key: UniqueKey(),
                    node: widget.graph.nodes[index],
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

class NodeCard extends StatefulWidget {
  const NodeCard({
    super.key,
    required this.node,
    required this.graph,
    required this.setGlobalState,
  });

  final Node node;
  final Graph graph;
  final Function setGlobalState;

  @override
  State<NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<NodeCard> {
  TextEditingController controller = TextEditingController();
  TextEditingController aliasController = TextEditingController();

  @override
  void initState() {
    controller.text = widget.node.name;
    aliasController.text = widget.node.alias;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          setState(() {
            widget.graph.edges.removeWhere(
              (element) =>
                  element.source == widget.node.alias ||
                  element.target == widget.node.alias,
            );
            widget.graph.nodes.remove(widget.node);
          });
          widget.setGlobalState();
        },
        child: const Icon(Icons.delete),
      ),
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: const InputDecoration(
            labelText: "Name",
            border: InputBorder.none,
          ),
          controller: controller,
          onSubmitted: (String value) {
            widget.node.name = value;

            widget.setGlobalState();
          },
          onChanged: (String value) {
            widget.node.name = value;
          },
        ),
      ),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionChip(
            label: Text("${(widget.node.deathRate * 100)}%"),
            avatar: const Icon(Icons.dangerous_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: EditValueScreen(
                    value: widget.node.deathRate,
                    onSet: (value) {
                      widget.node.deathRate = value as double;

                      setState(() {});
                      widget.setGlobalState();
                    },
                    typeOfData: TypeOfData.rate,
                    text: const [
                      "Mortality Rate",
                      "Enter the new mortality rate",
                    ],
                  ),
                ),
              );
            },
          ),
          ActionChip(
            label: Text("${widget.node.birthRate * 100}%"),
            avatar: const Icon(Icons.child_friendly_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: EditValueScreen(
                    value: widget.node.birthRate,
                    onSet: (value) {
                      widget.node.birthRate = value as double;

                      setState(() {});
                      widget.setGlobalState();
                    },
                    typeOfData: TypeOfData.rate,
                    text: const [
                      "Birth rate",
                      "Enter the new birth rate",
                    ],
                  ),
                ),
              );
            },
          ),
          ActionChip(
            label: Text(widget.node.capacity.toString()),
            avatar: const Icon(Icons.filter_tilt_shift_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: EditValueScreen(
                    value: widget.node.capacity,
                    onSet: (value) {
                      widget.node.capacity = value;

                      setState(() {});
                      widget.setGlobalState();
                    },
                    typeOfData: TypeOfData.kg,
                    text: const [
                      "Capacity",
                      "Enter the new capacity",
                    ],
                  ),
                ),
              );
            },
          ),
          ActionChip(
            label: Text(widget.node.population.toString()),
            avatar: const Icon(Icons.people),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: EditValueScreen(
                    value: widget.node.population,
                    onSet: (value) {
                      widget.node.population = value as int;
                      setState(() {});
                      widget.setGlobalState();
                    },
                    typeOfData: TypeOfData.number,
                    text: const [
                      "Population",
                      "Enter the new population",
                    ],
                  ),
                ),
              );
            },
          ),
          ActionChip(
            label: Text(widget.node.biomassPerCapita.toString()),
            avatar: const Icon(Icons.biotech_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: EditValueScreen(
                    value: widget.node.biomassPerCapita,
                    onSet: (value) {
                      widget.node.biomassPerCapita = value as double;
                      setState(() {});
                      widget.setGlobalState();
                    },
                    typeOfData: TypeOfData.kg,
                    text: const [
                      "Biomass per capita",
                      "Enter the new biomass per capita",
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          textAlign: TextAlign.center,
          controller: aliasController,
          onSubmitted: (String value) {
            for (Edge edge in widget.graph.edges) {
              if (edge.source == widget.node.alias) {
                edge.source = value;
              }
              if (edge.target == widget.node.alias) {
                edge.target = value;
              }
            }

            widget.graph.nodes[widget.graph.nodes.indexOf(widget.node)].alias =
                value;
            setState(() {
              widget.node.alias = value;
            });

            widget.setGlobalState();
          },
          onTapOutside: (_) {
            for (Edge edge in widget.graph.edges) {
              if (edge.source == widget.node.alias) {
                edge.source = aliasController.text;
              }
              if (edge.target == widget.node.alias) {
                edge.target = aliasController.text;
              }
            }
            setState(() {
              widget.node.alias = aliasController.text;
            });

            widget.graph.nodes[widget.graph.nodes.indexOf(widget.node)].alias =
                aliasController.text;

            widget.setGlobalState();
          },
        ),
      ),
    );
  }
}
