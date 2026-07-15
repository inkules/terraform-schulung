# TODO: Baut hier eine "local_file"-Ressource "gruss", die eine Datei
# "output/<name>-gruss.txt" mit Inhalt "Hallo, <name>! Willkommen im Kurs."
# erzeugt.
#
# Stolperfalle: Das Modul wird zweimal mit derselben "source" aufgerufen -
# path.module zeigt für beide Instanzen auf denselben Ordner und würde zu
# einem Dateikonflikt führen. Nutzt stattdessen path.root (zeigt auf den
# aufrufenden Root-Ordner) und baut var.name mit in den Dateinamen ein,
# damit jede Instanz ihre eigene Datei bekommt.
