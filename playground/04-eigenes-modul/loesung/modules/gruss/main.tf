resource "local_file" "gruss" {
  # path.root (nicht path.module!) zeigt auf den aufrufenden Ordner - wichtig,
  # weil beide Modul-Instanzen sich denselben Modul-Quellordner teilen und
  # path.module deshalb für beide identisch wäre (Dateikonflikt).
  filename = "${path.root}/output/${var.name}-gruss.txt"
  content  = "Hallo, ${var.name}! Willkommen im Kurs."
}
