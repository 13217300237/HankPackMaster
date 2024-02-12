bool isValidGitUrl(String url) {
  RegExp regex = RegExp(
    r'^((git|ssh|http(s)?)|(git@[\w\.]+))(:(\/\/)?)([\w\.@\:\/\-~]+)(\.git)(\/)?$',
    caseSensitive: false,
    multiLine: false,
  );
  return regex.hasMatch(url);
}
