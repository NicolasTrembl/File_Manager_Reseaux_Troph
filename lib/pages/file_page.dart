import 'dart:io';
import "package:flutter/material.dart";
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '/logic/graph.dart';
import '/widgets/general_widget.dart';
import '/widgets/node_widget.dart';
import '/widgets/edge_widget.dart';
import '/widgets/sim_widget.dart';
import '/logic/save.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key, required this.file});

  final File? file;

  @override
  State<FilePage> createState() => _FilePageState();
}

final saveKeySet = LogicalKeySet(
  LogicalKeyboardKey.control, // Replace with control on Windows
  LogicalKeyboardKey.keyS,
);

class SaveIntent extends Intent {
  const SaveIntent();
}

class _FilePageState extends State<FilePage> {
  File? file;
  Graph? graph;
  final FocusNode _focusNode = FocusNode();
  TextEditingController controller = TextEditingController();

  void readFile() async {
    String fileContent;
    String simContent;

    if (file == null) return;

    if (file!.path.endsWith(".eco")) {
      fileContent = await file!.readAsString();
      File simF = File("${file!.path.split(".")[0]}.sim");
      if (simF.existsSync()) {
        simContent = await simF.readAsString();
      } else {
        simContent = "";
      }
    } else {
      simContent = await file!.readAsString();
      File ecoF = File("${file!.path.split(".")[0]}.eco");
      if (ecoF.existsSync()) {
        fileContent = await ecoF.readAsString();
      } else {
        fileContent = "";
      }
    }

    Graph newGraph = Graph.fromFile(
      fileContent,
      simContent,
    );

    setState(() {
      graph = newGraph;
    });
  }

  void globalSetState() {
    setState(() {});
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode
        .dispose(); // Dispose of the focus node when the widget is removed
    super.dispose();
  }

  void save() async {
    if (!canSave()) {
      return;
    }

    if (file == null) {
      String? path = await FilePicker.platform.saveFile(
        type: FileType.custom,
        allowedExtensions: ["eco", "sim"],
        dialogTitle: "Save file",
      );

      if (path != null) {
        file = File(path);
      }
    }

    List<String> ecoParam = ["autoID"];

    if (file != null) {
      String cont1 = "${graph!.name}\n\n${graph!.order} "
          "${graph!.size}\n"
          "\n${graph!.params.where((e) => ecoParam.contains(e)).map((e) => "#$e").join("\n")}\n"
          "\n${graph!.nodes.map((e) => "${e.name} (${e.alias}) {${(e.deathRate * 100).toStringAsFixed(2)} / ${(e.birthRate * 100).toStringAsFixed(2)} / ${e.capacity} / ${e.population} / ${e.biomassPerCapita}}").join(" | ")}\n"
          "\n${graph!.edges.map((e) => "${e.source} -> ${e.target} {${e.predationRate} / ${e.assimilationRate}}").join(" \n ")}";
      file = File("${file!.path.split(".")[0]}.eco");
      if (file == null) return;

      file!.writeAsString(
        cont1,
      );

      String cont2 =
          "${graph!.params.where((e) => !ecoParam.contains(e)).map((e) => "#$e").join("\n")}\n";
      cont2 +=
          "| Count | ${graph!.sim.iterOrder.map((e) => "|$e").join()}|\n| :- ${graph!.sim.iterOrder.map((e) => "| - ").join()}|\n${graph!.sim.iter.map((e) => "| ${graph!.sim.iter.indexOf(e)}${e.map((e) => "|$e").join()}").join("|\n")}|";

      if (graph!.sim.numb > 0) {
        await File("${file!.path.split(".")[0]}.sim").writeAsString(
          cont2,
        );
      } else {
        await File("${file!.path.split(".")[0]}.sim").writeAsString(
          "",
        );
      }
    }

    setState(() {});
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  bool canSave() {
    if (graph == null) {
      return false;
    }

    // Fatal errors :

    // Check that the graph has at least one node
    if (graph!.nodes.isEmpty) {
      showErrorSnackBar("The graph has no nodes");
      return false;
    }

    // Check that no node has the same alias as another
    for (int i = 0; i < graph!.nodes.length; i++) {
      for (int j = i + 1; j < graph!.nodes.length; j++) {
        if (graph!.nodes[i].alias == graph!.nodes[j].alias) {
          showErrorSnackBar("Two nodes have the same alias");
          return false;
        }
      }
    }

    // Check that the graph has at least one edge
    if (graph!.edges.isEmpty) {
      showErrorSnackBar("The graph has no edges");
      return false;
    }

    // Check that the sum of each node predation rates is 1

    for (int i = 0; i < graph!.nodes.length; i++) {
      if (graph!.edges
          .where((e) => e.source == graph!.nodes[i].alias)
          .isEmpty) {
        continue;
      }
      double sum = 0;
      for (Edge edge in graph!.edges) {
        if (edge.source == graph!.nodes[i].alias) {
          sum += edge.predationRate;
        }
      }
      if (sum != 1) {
        showErrorSnackBar(
          "The sum of the predation rates of node ${graph!.nodes[i].alias} "
          "is not equal to 1",
        );
        return false;
      }
    }

    // Warnings :

    // Check that no node has the same name as another
    for (int i = 0; i < graph!.nodes.length; i++) {
      for (int j = i + 1; j < graph!.nodes.length; j++) {
        if (graph!.nodes[i].name == graph!.nodes[j].name) {
          showWarningSnackBar("Two nodes have the same name");
        }
      }
    }

    // Check that no edge has the same source and target as another
    for (int i = 0; i < graph!.edges.length; i++) {
      for (int j = i + 1; j < graph!.edges.length; j++) {
        if (graph!.edges[i].source == graph!.edges[j].source &&
            graph!.edges[i].target == graph!.edges[j].target) {
          showWarningSnackBar("Two edges have the same source and target");
        }
      }
    }

    // Check that no node capacity is smaller than the population * biomassPerCapita
    for (int i = 0; i < graph!.nodes.length; i++) {
      if (graph!.nodes[i].capacity <
          graph!.nodes[i].population * graph!.nodes[i].biomassPerCapita) {
        showWarningSnackBar(
          "The capacity of node ${graph!.nodes[i].alias} "
          "(${graph!.nodes[i].capacity}) is smaller than the "
          "population * biomassPerCapita "
          "(${graph!.nodes[i].population * graph!.nodes[i].biomassPerCapita})",
        );
      }
    }

    return true;
  }

  @override
  void initState() {
    if (widget.file != null) {
      file = widget.file;
      readFile();
    } else {
      graph = Graph(
        name: "New Graph",
        params: [],
        nodes: [],
        edges: [],
        sim: Sim(
          numb: 0,
          iter: [],
          iterOrder: [],
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        // Define the shortcut for Ctrl + S
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const SaveIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          // Define the action to perform when the shortcut is triggered
          SaveIntent: CallbackAction<SaveIntent>(onInvoke: (intent) {
            save();
            return null;
          }),
        },
        child: Focus(
          focusNode: _focusNode,
          child: Scaffold(
            appBar: AppBar(
              title: file != null
                  ? Text(file!.path.split("\\").last.split(".").first)
                  : const Text("New Graph"),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      if (file != null) {
                        if (file!.path.split(".").last == "eco") {
                          File("${file!.path.split(".")[0]}.sim").delete();
                          file!.delete();
                        } else {
                          File("${file!.path.split(".")[0]}.eco").delete();
                          file!.delete();
                        }
                      }
                      Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                      );
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: save,
                    icon: const Icon(Icons.save),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PopupMenuButton(
                    child: const Icon(Icons.download),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("Export as .dot"),
                            subtitle: const Text(
                              "Export the nodes and edges as a .dot / .gv file",
                            ),
                            onTap: () {
                              if (!canSave()) {
                                return;
                              }
                              Export().exportToDot(graph);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("Export as .graphml"),
                            subtitle: const Text(
                              "Export the nodes and edges as a .grapml file",
                            ),
                            onTap: () {
                              if (!canSave()) {
                                return;
                              }
                              Export().exportToGrahpml(graph);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("Export as .gexf"),
                            subtitle: const Text(
                              "Export the nodes and edges as a .gexf file (the gephi format)",
                            ),
                            onTap: () {
                              if (!canSave()) {
                                return;
                              }
                              Export().exportToGexf(graph);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("Export as .json"),
                            subtitle: const Text(
                              "Export the graph and the simulation as a .json file",
                            ),
                            onTap: () {
                              if (!canSave()) {
                                return;
                              }
                              Export().exportToJson(graph);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("Export as .csv"),
                            subtitle: const Text(
                              "Export the simulation as a .csv file",
                            ),
                            onTap: () {
                              if (!canSave()) {
                                return;
                              }
                              Export().exportToCsv(graph);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            title: const Text("Export as .xlsx"),
                            subtitle: const Text(
                              "Export the simulation as a .xlsx file (the excel format)",
                            ),
                            onTap: () {
                              if (!canSave()) {
                                return;
                              }
                              Export().exportToXlsx(graph);
                            },
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
            body: graph == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SizedBox.expand(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.spaceEvenly,
                        direction: Axis.vertical,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GeneralWidget(
                              widgetSize: Size(
                                MediaQuery.of(context).size.width * 7 / 16,
                                MediaQuery.of(context).size.height * 5 / 16,
                              ),
                              graph: graph!,
                              setGlobalState: globalSetState,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: NodeWidget(
                              widgetSize: Size(
                                MediaQuery.of(context).size.width * 7 / 16,
                                MediaQuery.of(context).size.height * 7 / 16,
                              ),
                              graph: graph!,
                              setGlobalState: globalSetState,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: EdgesWidget(
                              widgetSize: Size(
                                MediaQuery.of(context).size.width * 7 / 16,
                                MediaQuery.of(context).size.height * 14 / 16,
                              ),
                              graph: graph!,
                              setGlobalState: globalSetState,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SimWidget(
                              widgetSize: Size(
                                MediaQuery.of(context).size.width * 7 / 16,
                                MediaQuery.of(context).size.height * 14 / 16,
                              ),
                              sim: graph!.sim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
