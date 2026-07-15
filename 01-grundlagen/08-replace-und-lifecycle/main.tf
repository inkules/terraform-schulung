# local_file löst bei so gut wie jeder Änderung ein Replace aus, da seine
# "id" ein Hash des Inhalts ist. create_before_destroy dreht die Reihenfolge
# um: Terraform legt die neue Datei an, BEVOR die alte gelöscht wird.
resource "local_file" "app" {
  filename = "${path.module}/output/${var.filename}"
  content  = var.content

  lifecycle {
    create_before_destroy = true
  }
}

# Gegen versehentliches "terraform destroy" geschützt.
resource "local_file" "geschuetzt" {
  filename = "${path.module}/output/geschuetzt.txt"
  content  = "Diese Datei ist vor destroy geschützt."

  lifecycle {
    prevent_destroy = true
  }
}
