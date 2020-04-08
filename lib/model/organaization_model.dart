
class Organization{

  String text;
  bool selected;
  String value;
  String color;
  String image;


  Organization(this.text, this.selected, this.value, this.color, this.image);


  Organization.fromMap(Map<String,dynamic> map){
    text=map['text'];
    selected=map['selected'];
    value=map['value'];
    color=map['color'];
    image=map['image'];

  }
}