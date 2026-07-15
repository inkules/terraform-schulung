resource "local_file" "eintrag" {
  filename = "${path.module}/eintrag.txt"
  content  = "Wichtiger Eintrag - bitte nicht neu erstellen lassen."
}
