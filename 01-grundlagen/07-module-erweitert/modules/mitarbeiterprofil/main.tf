resource "local_file" "profil" {
  filename = "${var.output_dir}/${var.name}.txt"
  content  = "Name: ${var.name}\nRolle: ${var.rolle}"
}
