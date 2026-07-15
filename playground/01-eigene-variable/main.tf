resource "local_file" "notiz" {
  filename = "${path.module}/notiz.txt"
  content  = "Diese Notiz wurde erstellt."
}

# TODO: Ergänzt hier eine Variable "autor" (type = string) mit einem
# Default eurer Wahl, und baut sie oben per String-Interpolation in
# "content" ein, z.B. "Diese Notiz wurde erstellt von <Name>."
