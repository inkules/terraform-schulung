resource "local_file" "team_datei" {
  for_each = toset(var.team)

  filename = "${path.module}/output/${each.value}.txt"
  content  = "Hallo, ${each.value}!"
}
