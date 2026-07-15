resource "local_file" "team_datei" {
  # TODO: var.team ist eine list(string) - für for_each braucht ihr aber
  # ein set oder eine map. Ergänzt hier for_each mit der richtigen
  # Umwandlung (Hinweis: toset()).

  filename = "${path.module}/output/${each.value}.txt"
  content  = "Hallo, ${each.value}!"
}
