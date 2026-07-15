# Kaputt: Nach "filename" fehlt das Gleichheitszeichen.
resource "local_file" "status" {
  filename "${path.module}/status.txt"
  content  = "Hallo!"
}
