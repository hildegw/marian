


class ModelGitSearchResponse {
  int totalCount;
  List<dynamic> items;

  ModelGitSearchResponse() {
    this.totalCount = totalCount;
    this.items = items;
  }

  toString() { 
    String filing = "";
    createFiles(this.items).forEach((it) => filing += it.toString());
    return "$totalCount: $filing";
  }

  List<ModelGitFile> createFiles(List<dynamic> items) {
    List<ModelGitFile> files = [];
    items.forEach((item) { 
      files.add(ModelGitFile.fromJson(item));
    });
    return files;
  }

  ModelGitSearchResponse.fromJson(Map<String, dynamic> json) : 
    items = json["items"],
    totalCount = json["total_count"];
}

class ModelGitFile {
  String filename;
  String path;
  String fullName;

  ModelGitFile({
    this.filename, this.path, this.fullName
  });

  toString() => "$filename, $path, $fullName";

  ModelGitFile.fromJson(Map<String, dynamic> json) : 
    filename = json["name"],
    path = json["path"],
    fullName = json["repository"]["full_name"];
}