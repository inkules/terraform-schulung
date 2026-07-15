resource "local_file" "seite" {
  filename = "${var.output_dir}/index.html"
  content = templatefile("${path.module}/templates/index.html.tftpl", {
    titel   = var.titel
    tagline = var.tagline
    farbe   = var.farbe
    links   = var.links
  })
}
