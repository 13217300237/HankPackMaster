bool isValidGitUrl(String url) {
  RegExp regex = RegExp(
    r'^((git|ssh|http(s)?)|(git@[\w\.]+))(:(\/\/)?)([\w\.@\:\/\-~]+)(\.git)(\/)?$',
    caseSensitive: false,
    multiLine: false,
  );
  return regex.hasMatch(url);
}

bool isHttpsUrl(String url) {
  RegExp regex = RegExp(
    r'^(http|https):\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(:[0-9]+)?(\/[a-zA-Z0-9\-_\.\~\%\/\?\#\&\=]*)?$',
    caseSensitive: false,
    multiLine: false,
  );
  return regex.hasMatch(url);
}
