module "anna" {
  source = "./modules/mitarbeiterprofil"

  name       = "Anna"
  rolle      = "Trainerin"
  output_dir = "${path.module}/output"
}

module "ben" {
  source = "./modules/mitarbeiterprofil"

  name       = "Ben"
  rolle      = "Entwickler"
  output_dir = "${path.module}/output"
}

module "carla" {
  source = "./modules/mitarbeiterprofil"

  name       = "Carla"
  rolle      = "Entwicklerin"
  output_dir = "${path.module}/output"
}

output "profil_pfade" {
  value = [module.anna.pfad, module.ben.pfad, module.carla.pfad]
}
