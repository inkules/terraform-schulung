# Kaputt: Es gibt var.content, aber hier wird var.message referenziert (Tippfehler).
resource "local_file" "status" {
  filename = "${path.module}/status.txt"
  content  = var.message
}
