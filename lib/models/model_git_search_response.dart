


class ModelGitSearchResponse implements Comparable {
  int totalCount;
  List<Map<String, dynamic>> files; //file name: [file pasth, repo full name]


   
  ModelGitSearchResponse({
    this.totalCount, this.files
  });

  //toString() => files.forEach((file) => file.toString());
  //'git search results: $totalCount  ';

  ModelGitSearchResponse.fromJson(Map<String, dynamic> json) : 
  TODO
      id = json["id"], frid = json["frid"], az = json["az"], 
      dp = json["dp"], lg = json["lg"], sc = json["sc"], exc = json["exc"];
      //latlng = LatLng(json["latlng"]["latitude"], json["latlng"]["longitude"]);


  @override
  int compareTo(other) {
    //if (this.id <= other.frid) return -1;
    if (this.frid <= this.id && this.id <= other.id) return -1;
    else if (this.frid > this.id && this.frid <= other.frid) return -1;
    else return 1;
  }

}

