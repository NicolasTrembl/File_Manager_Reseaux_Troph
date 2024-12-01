import 'package:flutter/material.dart';
import '/logic/graph.dart';

class SimWidget extends StatefulWidget {
  const SimWidget({super.key, required this.sim, required this.widgetSize});

  final Sim sim;
  final Size widgetSize;

  @override
  State<SimWidget> createState() => _SimWidgetState();
}

class _SimWidgetState extends State<SimWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: BoxConstraints.loose(
        widget.widgetSize.width > 550
            ? widget.widgetSize
            : Size(550, widget.widgetSize.height),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Simulation (${widget.sim.numb})",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.sim.iterOrder.map((e) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  e,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),
          ),
          widget.sim.numb > 0
              ? Expanded(
                  child: ListView.separated(
                    itemCount: widget.sim.numb,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SimCard(
                          iter: widget.sim.iter[index],
                        ),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Text("No simulation data"),
                ),
        ],
      ),
    );
  }
}

class SimCard extends StatelessWidget {
  const SimCard({super.key, required this.iter});

  final List<int> iter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: iter.map((e) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "$e",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }
}
