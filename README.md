# VehicleExplorer for FS19 aka VeEx19
**This is a revamp of the good old VehicleSort from FS17**

For beginners: VehicleExplorer helps you organize your vehicles, by showing you a list which can be organized, well, sorted by you.
Besides that it has a couple of additional functionality. See below.

Feedback, this readme and additional information incl. source code can be find at: https://github.com/sperrgebiet/FS19_VehicleExplorer

**Please download the latest version directly from GitHub**
[Latest version](https://github.com/sperrgebiet/FS19_VehicleExplorer/blob/master/FS19_VehicleExplorer.zip)

### Features
* List of all steerable vehicles (Specialization: Enterable)
* Set a customer order for your vehicles
  * Your order is saved in the default vehicles.xml, so no additional clutter
* Enter your vehicles directly with a click of a (mouse) button
  * This is meant literally, see known issues ;)
* Park your vehicles, so that a switch of vehicles via Tab ignores them
* Repair vehicles and its implements
* Displaying a store image next to the list
* Info box with additional informations
* Motor on/off, turned on/off (for e.g. harvester) and light status is saved and restored
* Different colors in the list if a vehicle is selected, or currently used by a helper/Courseplay
* Config Menu
  * Config is saved per savegame within modsSettings/VehicleExplorer/savegameX
  * Show/hide trains in the list
  * Show/hide station cranes in the list (No idea if that actually works, would need a map with a crane to test)
  * Show/hide steerable implements/trailers (e.g. forwarder trailer with crane)
  * Show/hide brand names in the list
  * Show/hide your own name when you enter a vehicle
  * Show/hide horse power in the list
  * Show/hide fill levels in the list
  * Show/hide implements in the list
  * Show/hide store images
  * Show/hide infobox
  * Change text size
  * Change list background transparency
  * Enable/disable saving of the additional vehicle status (motor, turnedOn, lights)
  * Show/hide keybindings in the game F1 help menu (needs a game restart to take affect)

### Known issues
* Although you can change all the keyboard bindings, the mouse actions are hardcoded for now
  * Left mouse click: Enter vehicle
  * Right mouse click: Select vehicle (to e.g. move it)
  * Right mouse click: Change value in the config menu
  * Mouse wheel: Selection up/down in list
* The actual 'tab order' of vehicles is not changed
* Metric measuring units are used
* Chaining for implements
  * For now just the directly attached implements get respected. This means for repair and the info box just a e.g. trailer is recognized, but not a trailer which is attached to another trailer
* Max of three columns. If you've more vehicles (which would be insane anyways ;) , just disable the display of brand name etc
* A wrong value for horse power is displayed for trains
* Sometimes selling or resetting a vehicle is causing a flickering of the vehicle list. I've already an idea why, just have to look more into it.
As a workaround you just have to move any vehicle a position up or down, then a reshuffle is triggered and the list is rendered properly again.

### Incompatible Mods
* SpeedControl (to be fixed)

## Default Keybinding
KeyPad 0 -> Show/hide vehicle list
KeyPad Minus -> Show/hide config menu 
KeyPad Enter -> Enter vehicle
KeyPad Plus -> Toggle parking
KeyPad 5 -> Select item (for moving the vehicle) or to change values in the config
KeyPad 8 -> Move up in the list/config
KeyPad 2 -> Move down in the list/config
1 -> Move up fast in the list/config
2 -> Move down fast in the list/config
LAlt + R -> Repair vehicle incl. implements

Mouse Left: Enter vehicle
Mouse Right:  Select item/change values in config
Mouse Wheel: List up/down

## Note that the current version does NOT support multiplayer!
Quite frankly, I've no idea about the MP code needed and also no possibility to test it. Actually I think it shouldn't be a big deal, and maybe it already works by just changing
the MP setting in the moddesc.xml from false to true. I assume just the parking possibility has an impact to MP.

## Credits
Primarily to Dschonny & Slivicon. At least those are the names which were mentioned in the FS17 VehicleSort I used as a foundation. But the majority of code has changed anyways.
Also Kudos to the guys and gals from CoursePlay, VehicleInspector, VehicleFruitHud, EnhancedVehicle and many more for some inspiration and ideas.
Additionally Ifko[nator] for the RegisterSpecialization script.


## Latest Version
0.9.0.2 - I consider it as Beta. I tested it quite a lot myself, but hope for some helpful feedback from the community.

-----


# VehicleExplorer für LS19 aka VeEx19
**Dies ist eine Reinkarnation von VehicleSort aus LS17**

Für Neueinsteiger: VehicleExplorer hilft beim organisiere der Fahrzeuge. Es zeigt eine Liste welche dann selbst nach eigenen Wünschen sortiert werden kann.

Feedback, dieses ReadMe und weitere Informationen sowie der Quelltext findet sich unter: https://github.com/sperrgebiet/FS19_VehicleExplorer

**Bitte lade die letzte Version direkt von bei GitHub herunter**
[Letzte Version](https://github.com/sperrgebiet/FS19_VehicleExplorer/blob/master/FS19_VehicleExplorer.zip)

### Funktionen
* Liste aller steuerbaren Fahrzeuge (Specialization: Enterable)
* Definition einer eigener Reihenfolge der Fahrzeuge
  * Die Reihenfolge wird in der Standard vehicles.xml gespeichert, also kein zusätzliches Wirrwar
* Fahrzeugwechsel einfach durch einen Mausklick
  * Dies meine ich wortwörtlich, siehe Bekannte Probleme ;)
* Parke die Fahrzeuge, sodass sie von einem Fahrzeugwechsel via Tab ignoriert werden
* Reparatur von Fahrzeugen und angehängten Geräten
* Anzeige eines Shop-Bildes neben der Fahrzeugliste
* Info Box neben der Fahrzeugliste mit weiteren Details
* Motor ein/aus, Gerätefunktionen ein/aus (für z.B. Drescher) und Licht-Status werden gespeichert und beim laden wieder hergestellt
* Unterschiedliche Farben in der Liste für selektiert, momentane Verwendung eines Helfers/CoursePlay
* Konfigurationsmenü
  * Die Konfiguration ist pro Speicherslot unter modsSettings-VehicleExplorer/savegameX zu finden
  * Anzeigen/verstecken von Zügen in der Liste
  * Anzeigen/verstecken von Stationskränen (kA ob das Funktioniert, bräuchte ne Map mit Kränen dafür)
  * Anzeigen/verstecken von Markennamen
  * Anzeigen/verstecken des eigenen Namens wenn man sich in einem Fahrzeug befindet
  * Anzeigen/verstecken der Leistung (PS) bei einem Fahrzeug
  * Anzeigen/verstecken der Füllmengen in der Liste
  * Anzeigen/verstecken von Anbaugeräten/Hängern in der Liste
  * Anzeigen/verstecken Shop Bild
  * Anzeigen/verstecken der Infobox
  * Ändern der Schriftgröße
  * Ändern der Hintergrundtransparenz
  * Aktivieren/deaktivieren des speicherns der zusätzlichen Fahrzeugstati (motor, turnedOn, lights)
  * Anzeigen/verstecken der Tastenbelegung im F1 Hilfemenü (benötigt einen Neustart des Spiels)

### Bekannte Probleme
* Wenn man auch die Tastaturbelegung verändern kann, so sind die Mausaktionen im Moment nicht veränderbar
  * Linke Maustaste: Ins Fahrzeug einsteigen
  * Rechte Maustaste: Fahrzeug auswählen (zum Verschieben)
  * Rechte Maustaste: Wert im Konfigurationsmenü ändern
  * Mausrad: Rauf/Runter in der Liste
* Die eigentliche 'Tab-Reihenfolge' des Spiels wird nicht verändert
* Metrische Masseinheit wird für die Geschwindigkeitsanzeige verwendet
* Verkettung von Geräten/Anhängern
  * Nur die direkt angehängten Geräte/Anhänger werden berücksichtig. Beim reparieren z.b. wird nur der Anhäng des Traktors berücksichtigt, jedoch nicht ein Anhänger der am Anhänger hängt.
* Maximal drei Spalten in der Liste. Wenn du mehr Fahrzeuge hast )was sowieso schon bedenklich ist ;), dann einfach die Markennamen oder Füllmengen deaktiveren um mehr Platz zu haben.
* Bei Zügen wird die Leistung/PS falsch berechnet
* Manchmal verursacht das verkaufen oder zurücksetzen eines Fahrzeuges ein flackern der Fahrzeugliste. Ich hab auch schon eine Idee warum, muss mich nur mehr damit beschäftigen.
Als vorübergehende Lösung braucht man einfach nur ein Fahrzeug eine Position rauf oder runter schieben, dabei wird ein reorganisieren der Liste angestossen und es funktioniert wieder.

### Inkompatible Mods
* SpeedControl (to be fixed)

## Standard Tastenbelegung
KeyPad 0 -> Anzeigen/verstecken der Fahrzeugliste
KeyPad Minus -> Anzeigen/verstecken des Konfigurationsmenüs
KeyPad Enter -> Ins Fahrzeug wechseln
KeyPad Plus -> Fahrzeug parken/ausparken
KeyPad 5 -> Fahrzeug auswählen (zum Verschieben) und ändern eines Wertes in der Konfiguration
KeyPad 8 -> Rauf in der Liste/Konfiguration
KeyPad 2 -> Runter in der Liste/Konfiguration
1 -> Schnell rauf in der Liste/Konfiguration
2 -> Schnell runter in der Liste/Konfiguration
LAlt + R -> Repariere Fahrzeug inkl. Anbaugeräte

Linke Maustaste: Ins Fahrzeug wechseln
Rechte Maustaste:  Fahrzeug auswählen/Eintrag im Konfigurationsmenü ändern
Mausrad: Liste rauf/runterscrollen

## Beachte, dass die jetzige Version kein Multiplayer unterstützt!
Ehrlich gesagt habe ich keine Ahnung was für MP Code notwendig wäre und auch keine Möglichkeit es zu testen. Vielleicht funktioniert es einfach nur in de moddesc.xml von false auf true zu wechseln.
Ich glaube nur das parken von Fahrzeugen sollte einen Einfluss auf MP haben.

## Credits
Primär an Dschonny & Slivicon. Zumindest waren das die Namen die in der LS17 VehicleSort Version genannt wurden welche als Basis diente. Aber der Grossteil des codes hat sich sowieso verändert.
Auch Kudos an die Jungs und Mädls von CoursePlay, VehicleInspector, VehicleFruitHud, EnhancedVehicle und vielen anderen für Inspirationen und Ideen.
Des weiteren noch Ifko[nator] für das RegisterSpecialization Skript.

## Letzte Version
0.9.0.2 - I würd mal sagen dies ist noch eine Beta. Ich hab zwar selbst recht viel getestet, hoffe aber auf hilfreiche Rückmeldungen von der Community.
