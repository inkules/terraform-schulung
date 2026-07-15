# Kaputt: local_file kennt kein Attribut "text", sondern "content".
resource "local_file" "status" {
  filename = "${path.module}/status.txt"
  text     = "Hallo!"
}
