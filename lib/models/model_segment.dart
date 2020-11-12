


class ModelSegment {
  int id;
  int frid;
  double az;
  double dp;
  double lg;
   
  //Map<String, dynamic> allUserInfo;


  ModelSegment({
    this.id, this.frid, this.az, this.dp, this.lg,
  });

  // static fromMap({String uid, Map<String, dynamic> data}) {
  //   if (data == null) return null;
  //   //print('user model has data from map ${data['badges'].toString()}');

  //   return UserModel(
  //     id: uid, 
  //     firstName: data['first'], 
  //     lastName: data['last'], 
  //     profileImage: data['profileImage'],
  //     phone: data['phone'],
  //     intention: data['intention'],
  //     badges: Badges.fromMap(data: data['badges']),
  //     allUserInfo: data,
  //   );
  // }

  // //updating user data from app during sign up or log in
  // Map<String, dynamic> toMap() {
  //   Map<String, dynamic> userData =
  //     {
  //       'uid': id, 
  //       'first': firstName, 
  //       'last': lastName, 
  //       'intention': intention, 
  //       'phone': phone,
  //     };
  //   if (profileImage != null) userData['profileImage'] = profileImage;
  //   return userData;
  // }

  toString() => 'from $frid to $id: az=$az dp=$dp lg=$lg';
}


