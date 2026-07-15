# Simuliert eine "deployte App-Konfiguration" pro Modul-Instanz.
# In echt wären das z.B. azurerm_service_plan + azurerm_linux_web_app -
# das Prinzip (ein Modul, mehrfach über for_each aufgerufen) bleibt identisch.
resource "local_file" "app_config" {
  filename = "${var.output_dir}/${var.name}.txt"
  content  = "App: ${var.name}\nSKU: ${var.sku}\nInstanzen: ${var.instance_count}"
}
