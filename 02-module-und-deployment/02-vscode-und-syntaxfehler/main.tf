resource "local_file" "messy" {
      filename = "${path.module}/messy.txt"
  content =    var.content



  }
