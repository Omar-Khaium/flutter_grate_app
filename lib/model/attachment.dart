import 'dart:io';

class Attachment {
  int id;
  String url;
  File file;
  String name;
  bool isUploading;
  bool isUploadSucceed;
  String token;

  Attachment(this.id, this.url, this.file, this.name, this.isUploading, this.isUploadSucceed, this.token);
}