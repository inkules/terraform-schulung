module "gruss_mira" {
  source = "./modules/gruss"
  name   = "Mira"
}

module "gruss_jonas" {
  source = "./modules/gruss"
  name   = "Jonas"
}

output "gruss_pfade" {
  value = [module.gruss_mira.pfad, module.gruss_jonas.pfad]
}
