resource "local_file" "beispiel" {
  filename = "${path.module}/output/${var.filename}"
  content  = var.content
}
