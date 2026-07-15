# Kaputt: local.a und local.b hängen zirkulär voneinander ab.
locals {
  a = local.b
  b = local.a
}

resource "local_file" "status" {
  filename = "${path.module}/status.txt"
  content  = local.a
}
