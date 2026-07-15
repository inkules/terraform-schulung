resource "local_file" "status" {
  filename = "${var.output_dir}/${lower(var.projekt)}.txt"
  content  = "Projekt: ${var.projekt}\nStatus: ${var.status}"
}
