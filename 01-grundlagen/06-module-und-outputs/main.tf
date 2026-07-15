module "seite" {
  source = "./modules/webseite"

  titel   = "Terraform-Schulung"
  tagline = "Von den Grundlagen bis zur eigenen Cloud-App"
  farbe   = "#5c3aa5"
  links = [
    { label = "Terraform Docs", url = "https://developer.hashicorp.com/terraform" },
    { label = "Terraform Registry", url = "https://registry.terraform.io" },
  ]
  output_dir = "${path.module}/output"
}

# Dasselbe Modul ein zweites Mal - andere Farbe, eigener output_dir.
# Zeigt: ein Modul lässt sich beliebig oft mit unterschiedlichen Werten
# aufrufen, jeder Aufruf bekommt seinen eigenen Platz im State.
module "seite2" {
  source = "./modules/webseite"

  titel   = "Terraform-Schulung"
  tagline = "Von den Grundlagen bis zur eigenen Cloud-App"
  farbe   = "#95b683"
  links = [
    { label = "Terraform Docs", url = "https://developer.hashicorp.com/terraform" },
    { label = "Terraform Registry", url = "https://registry.terraform.io" },
  ]
  output_dir = "${path.module}/output2"
}

# Ein drittes, komplett anders aufgebautes Modul: kein HTML aus Variablen
# zusammengesetzt, sondern eine fertige Seite mit eigenem JS/CSS, bei der nur
# Titel und Farbe von außen kommen. Der Inhalt (hier: 15 Quizfragen) steckt
# direkt im Template.
module "tag1_raetsel" {
  source = "./modules/raetsel"

  titel       = "Tag-1-Check: Terraform-Grundlagen"
  farbe       = "#5c3aa5"
  output_pfad = "${path.module}/output/raetsel.html"
}
