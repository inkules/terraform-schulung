resource "local_file" "raetsel" {
  filename = var.output_pfad
  content = templatefile("${path.module}/templates/raetsel.html.tftpl", {
    titel = var.titel
    farbe = var.farbe
  })
}
