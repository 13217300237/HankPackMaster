import 'package:fluent_ui/fluent_ui.dart';

import '../../comm/url_check_util.dart';

class CreateProjectDialogWidget extends StatefulWidget {
  final TextEditingController gitUrlTextController;

  final TextEditingController branchNameTextController;

  const CreateProjectDialogWidget(
      {super.key,
      required this.gitUrlTextController,
      required this.branchNameTextController});

  @override
  State<CreateProjectDialogWidget> createState() =>
      _CreateProjectDialogWidgetState();
}

class _CreateProjectDialogWidgetState extends State<CreateProjectDialogWidget> {
  var isValidGitUrlRes = true;

  var textStyle = const TextStyle(fontSize: 18);
  var textMustStyle = TextStyle(fontSize: 18, color: Colors.red);

  var errStyle = TextStyle(fontSize: 16, color: Colors.red);

  @override
  void initState() {
    super.initState();
    widget.gitUrlTextController.addListener(() {
      if (widget.gitUrlTextController.text.isEmpty) {
        isValidGitUrlRes = true;
      } else {
        isValidGitUrlRes = isValidGitUrl(widget.gitUrlTextController.text);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var gitUrlLabel =
        SizedBox(width: 100, child: Text('gitUrl', style: textStyle));
    var mustLabel = SizedBox(width: 20, child: Text("*", style: textMustStyle));
    var isValidGitUrlTip = Visibility(
      visible: !isValidGitUrlRes,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text("这不是一个正确的git地址", style: errStyle),
      ),
    );
    var branchNameLabel =
        SizedBox(width: 100, child: Text('branchName', style: textStyle));

    var gitUrlTextBox = Expanded(
      child: TextBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.green.withOpacity(.1)),
          unfocusedColor: Colors.transparent,
          highlightColor: Colors.transparent,
          expands: false,
          maxLines: 1,
          style: textStyle,
          controller: widget.gitUrlTextController),
    );
    var branchNameTextBox = Expanded(
      child: TextBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.green.withOpacity(.1)),
          unfocusedColor: Colors.transparent,
          highlightColor: Colors.transparent,
          expands: false,
          maxLines: 1,
          style: textStyle,
          controller: widget.branchNameTextController),
    );
    var gitUrlRow = Row(children: [
      gitUrlLabel,
      mustLabel,
      gitUrlTextBox,
    ]);
    var branchNameRow = Row(children: [
      branchNameLabel,
      mustLabel,
      branchNameTextBox,
    ]);

    // 弹窗
    var contentWidget = Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 5),
      gitUrlRow,
      isValidGitUrlTip,
      const SizedBox(height: 10),
      branchNameRow,
    ]);

    return contentWidget;
  }
}
