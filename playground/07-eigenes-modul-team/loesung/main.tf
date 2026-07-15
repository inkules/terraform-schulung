module "website" {
  source = "./modules/projektstatus"

  projekt    = "Website"
  status     = "aktiv"
  output_dir = "${path.module}/output"
}

module "migration" {
  source = "./modules/projektstatus"

  projekt    = "Migration"
  status     = "pausiert"
  output_dir = "${path.module}/output"
}

module "schulung" {
  source = "./modules/projektstatus"

  projekt    = "Schulung"
  status     = "abgeschlossen"
  output_dir = "${path.module}/output"
}
