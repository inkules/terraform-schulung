# TODO: Diese drei Ressourcen sind strukturell identisch - nur projekt und
# status unterscheiden sich. Baut ein Modul "modules/projektstatus/" mit
# Variablen "projekt", "status" und "output_dir", das genau das erzeugt,
# was hier drei Mal hardcodiert steht. Ersetzt die drei Ressourcen unten
# durch drei "module"-Blöcke, die dieses Modul aufrufen.

resource "local_file" "status_website" {
  filename = "${path.module}/output/website.txt"
  content  = "Projekt: Website\nStatus: aktiv"
}

resource "local_file" "status_migration" {
  filename = "${path.module}/output/migration.txt"
  content  = "Projekt: Migration\nStatus: pausiert"
}

resource "local_file" "status_schulung" {
  filename = "${path.module}/output/schulung.txt"
  content  = "Projekt: Schulung\nStatus: abgeschlossen"
}
