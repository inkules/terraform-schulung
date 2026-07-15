# Kaputt: die URL zeigt auf eine nicht existierende Domain. Data Sources
# werden schon während "terraform plan" ausgewertet (nicht erst bei apply) -
# hier zeigt sich also, dass auch ein "plan" bereits echte Netzwerk-/API-
# Aufrufe auslösen kann, sobald Data Sources im Spiel sind.
data "http" "status" {
  url = "https://diese-domain-existiert-hoffentlich-nicht-xyz123abc.invalid/status"
}
