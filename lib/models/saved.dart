class Saved {
  final String title;
  final String address;
  final double latitude;
  final double longitude;

  Saved({required this.latitude,required this.longitude,required this.title,required this.address});

  factory Saved.fromJson(Map<String,dynamic> json){
      return Saved(latitude: json['latitude'], longitude: json['longitude'], title: json['name'],address: json['address']);
  }

  Map<String,dynamic> toJson(){
    return {
      'name':title,
      'address':address,
      'latitude':latitude,
      'longitude':longitude,
    };
  }
}


// Temporarily Storing data in the app

List<Saved> saved = [];