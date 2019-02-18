# VehicleExplorer for FS19 aka VeEx19
**This is a revamp of the good old VehicleSort from FS17**

For beginners: VehicleExplorer helps you organize your vehicles, by showing you a list which can be organized, well, sorted by you.
Besides that it has a couple of additional functionality. See below.

Feedback, this readme and additional information incl. source code can be find at: https://github.com/sperrgebiet/FS19_VehicleExplorer

**Please download the latest version directly from GitHub**
[Latest version](https://github.com/sperrgebiet/FS19_VehicleExplorer/blob/master/FS19_VehicleExplorer.zip?raw=true)

### Features
* List of all steerable vehicles (Specialization: Enterable)
* Set a customer order for your vehicles
  * Your order is saved in the default vehicles.xml, so no additional clutter
* Enter your vehicles directly with a click of a (mouse) button
  * This is meant literally, see known issues ;)
* Park your vehicles, so that a switch of vehicles via Tab ignores them
* Repair vehicles and its implements
* Let your vehicle and implements get cleaned on a repair from your friendly VeEx staff ;)
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
  * Move infobox up/down
  * Show/hide a background for the infobox/store image
  * Change text size
  * Change text alignment
  * Change list background transparency
  * Enable/disable saving of the additional vehicle status (motor, turnedOn, lights)
  * Show/hide keybindings in the game F1 help menu (needs a game restart to take affect)
  * Clean vehicle & implements on a repair
* Tardis integration
  * TBD - Explanation of Tardis integration
  

### Known issues
* Although you can change all the keyboard bindings, the mouse actions are hardcoded for now
  * Left mouse click: Enter vehicle
  * Right mouse click: Select vehicle (to e.g. move it)
  * Right mouse click: Change value in the config menu
  * Mouse wheel: Selection up/down in list
* ~~The actual 'tab order' of vehicles is not changed~~ -> Workaround available
* Metric measuring units are used
* Max of three columns. If you've more vehicles (which would be insane anyways ;) , just disable the display of brand name etc
* A wrong value for horse power is displayed for trains
* Sometimes selling or resetting a vehicle is causing a flickering of the vehicle list. I've already an idea why, just have to look more into it.
As a workaround you just have to move any vehicle a position up or down, then a reshuffle is triggered and the list is rendered properly again.

### Incompatible Mods
* ~~SpeedControl~~
  * ~~Actually both work fine side by side. There is just a keybinding overlap. So you've to set new keybindings through the game menu for Key 1, Key 2, Key NumPad Plus, Key NumPad Minus~~
  * Changed the default keybinding. So there is no overlap anymore.

## Default Keybinding
LAlt + v -> Show/hide vehicle list
LAlt + KeyPad Minus -> Show/hide config menu 
KeyPad Enter -> Enter vehicle
LAlt + p -> Toggle parking
LAlt + KeyPad 5 -> Select item (for moving the vehicle) or to change values in the config
LAlt + KeyPad 8 -> Move up in the list/config
LAlt + KeyPad 2 -> Move down in the list/config
LAlt + 1 -> Move up fast in the list/config
LAlt + 2 -> Move down fast in the list/config
LAlt + R -> Repair vehicle incl. implements
Tab -> Next vehicle; VeEx own switch vehicle implementation (necessary to tab through vehicles in your own order)
Shift + Tab -> Previous vehicle; VeEx own switch vehicle implementation (necessary to tab through vehicles in your own order)

**_ If you want to use the 'sorted tabbing', make sure you drop the default key binding in the game menu. I didn't find a way to overwrite the default vehicle switching, and I think
it's better to let you, the user, this choice anyways. _**

Mouse Left: Enter vehicle
Mouse Right:  Select item/change values in config
Mouse Wheel: List up/down

## Meaning of colors used
|Color|Meaning|
|:---:|---|
|White|Standard|
|Green|Current player is controlling vehicle|
|Orange|Vehicle selected|
|Red|Vehicle locked (necessary to move it up/down in the list)|
|Grey|Vehicle is parked|
|Blue|Vehicle is controlled by AI (Helper or Courseplay)|
|Light Pink|Vehicle is controlled by FollowMe (not yet available)|
|Yellow|Engine is running|

## Note that the current version does NOT support multiplayer!
Quite frankly, I've no idea about the MP code needed and also no possibility to test it. Actually I think it shouldn't be a big deal, and maybe it already works by just changing
the MP setting in the moddesc.xml from false to true. I assume just the parking possibility has an impact to MP.

## Credits
Primarily to Dschonny & Slivicon. At least those are the names which were mentioned in the FS17 VehicleSort I used as a foundation. But the majority of code has changed anyways.
Also Kudos to the guys and gals from CoursePlay, VehicleInspector, VehicleFruitHud, EnhancedVehicle and many more for some inspiration and ideas.
Additionally Ifko[nator] for the RegisterSpecialization script.


## Latest Version
0.9.0.7 - I consider it as Beta. I tested it quite a lot myself, but hope for some helpful feedback from the community.

-----


# VehicleExplorer für LS19 aka VeEx19
**Dies ist eine Reinkarnation von VehicleSort aus LS17**

Für Neueinsteiger: VehicleExplorer hilft beim organisiere der Fahrzeuge. Es zeigt eine Liste welche dann selbst nach eigenen Wünschen sortiert werden kann.

Feedback, dieses ReadMe und weitere Informationen sowie der Quelltext findet sich unter: https://github.com/sperrgebiet/FS19_VehicleExplorer

**Bitte lade die letzte Version direkt von bei GitHub herunter**
[Letzte Version](https://github.com/sperrgebiet/FS19_VehicleExplorer/blob/master/FS19_VehicleExplorer.zip?raw=true)

### Funktionen
* Liste aller steuerbaren Fahrzeuge (Specialization: Enterable)
* Definition einer eigener Reihenfolge der Fahrzeuge
  * Die Reihenfolge wird in der Standard vehicles.xml gespeichert, also kein zusätzliches Wirrwar
* Fahrzeugwechsel einfach durch einen Mausklick
  * Dies meine ich wortwörtlich, siehe Bekannte Probleme ;)
* Parke die Fahrzeuge, sodass sie von einem Fahrzeugwechsel via Tab ignoriert werden
* Reparatur von Fahrzeugen und angehängten Geräten
* Waschen von Fahrzeugen und Anbaugeräten nach einer Reparatur durch das freundliche VeEx Personal
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
  * Rauf/runter verschieben der Infobox
  * Anzeigen/verstecken eines Hintergrundes für die Infobox/Shop Bild
  * Ändern der Schriftgröße
  * Textausrichtung ändern
  * Ändern der Hintergrundtransparenz
  * Aktivieren/deaktivieren des speicherns der zusätzlichen Fahrzeugstati (motor, turnedOn, lights)
  * Anzeigen/verstecken der Tastenbelegung im F1 Hilfemenü (benötigt einen Neustart des Spiels)
  * Aktivieren/deaktivieren des automatischen waschen von Fahrzeuge und Anbaugeräte beim Reparieren
* Tardis Integration
  * TBD - Explanation of Tardis integration

### Bekannte Probleme
* Wenn man auch die Tastaturbelegung verändern kann, so sind die Mausaktionen im Moment nicht veränderbar
  * Linke Maustaste: Ins Fahrzeug einsteigen
  * Rechte Maustaste: Fahrzeug auswählen (zum Verschieben)
  * Rechte Maustaste: Wert im Konfigurationsmenü ändern
  * Mausrad: Rauf/Runter in der Liste
* ~~Die eigentliche 'Tab-Reihenfolge' des Spiels wird nicht verändert~~ -> Workaround vorhanden
* Metrische Masseinheit wird für die Geschwindigkeitsanzeige verwendet
* Maximal drei Spalten in der Liste. Wenn du mehr Fahrzeuge hast )was sowieso schon bedenklich ist ;), dann einfach die Markennamen oder Füllmengen deaktiveren um mehr Platz zu haben.
* Bei Zügen wird die Leistung/PS falsch berechnet
* Manchmal verursacht das verkaufen oder zurücksetzen eines Fahrzeuges ein flackern der Fahrzeugliste. Ich hab auch schon eine Idee warum, muss mich nur mehr damit beschäftigen.
Als vorübergehende Lösung braucht man einfach nur ein Fahrzeug eine Position rauf oder runter schieben, dabei wird ein reorganisieren der Liste angestossen und es funktioniert wieder.

### Inkompatible Mods
* ~~SpeedControl~~
  * ~~Beide funktionieren einwandfrei nebeneinander. Es existiert nur eine Doppelbelegung der Tastaturbelegung. Im Spielmenü setze einfach neue Tasten für Taste 1, Taste 2, Taste NumPad Plus, Taste NumPad Minus~~
  * Habe die Standard Tastenbelegung verändert. Somit gibt es keinen Konflikt mehr.  

## Standard Tastenbelegung
LAlt + v -> Anzeigen/verstecken der Fahrzeugliste
LAlt + KeyPad Minus -> Anzeigen/verstecken des Konfigurationsmenüs
LAlt + KeyPad Enter -> Ins Fahrzeug wechseln
LAlt + p -> Fahrzeug parken/ausparken
LAlt + KeyPad 5 -> Fahrzeug auswählen (zum Verschieben) und ändern eines Wertes in der Konfiguration
LAlt + KeyPad 8 -> Rauf in der Liste/Konfiguration
LAlt + KeyPad 2 -> Runter in der Liste/Konfiguration
LAlt + 1 -> Schnell rauf in der Liste/Konfiguration
LAlt + 2 -> Schnell runter in der Liste/Konfiguration
LAlt + R -> Repariere Fahrzeug inkl. Anbaugeräte
Tab -> Nächstes Fahrzeug; VeEx eigene Implementierung des Fahrzeugwechsels via Tabulator, damit man auch die eigene Sortierung verwendet wird
Shift + Tab -> Vorheriges Fahrzeug; VeEx eigene Implementierung des Fahrzeugwechsels via Tabulator, damit man auch die eigene Sortierung verwendet wird

**_ Wenn du das 'sortierte Tabbing' zum Wechseln der Fahrzeuge verwenden möchtest musst du die Standard Tastenbelegung dafür in den Spieleinstellungen verwerfen. Ich habe keine
Möglichkeit gefunden dies zu überschreiben, und finde auch das es besser ist diese Wahl dir, dem User, zu überlassen. _**

Linke Maustaste: Ins Fahrzeug wechseln
Rechte Maustaste:  Fahrzeug auswählen/Eintrag im Konfigurationsmenü ändern
Mausrad: Liste rauf/runterscrollen

## Bedeutung der verwendeten Farben
|Farbe|Bedeutung|
|:---:|---|
|Weiss|Standard|
|Grün|Derzeitiger Spieler kontrolliert das Fahrzeug|
|Orange|Fahrzeug ist ausgewählt|
|Rot|Fahrzeug ist "gesperrt", notwendig um es in der Liste rauf/runter zu schieben|
|Grau|Fahrzeug ist geparkt|
|Blau|Fahrzeug wird von der KI kontrolliert (Helfer oder CoursePlay)|
|Helles Pink|Fahrzeug wird von FollowMe kontrolliert (noch nicht verfügbar)|
|Gelb|Motor is ein|

## Beachte, dass die jetzige Version kein Multiplayer unterstützt!
Ehrlich gesagt habe ich keine Ahnung was für MP Code notwendig wäre und auch keine Möglichkeit es zu testen. Vielleicht funktioniert es einfach nur in de moddesc.xml von false auf true zu wechseln.
Ich glaube nur das parken von Fahrzeugen sollte einen Einfluss auf MP haben.

## Credits
Primär an Dschonny & Slivicon. Zumindest waren das die Namen die in der LS17 VehicleSort Version genannt wurden welche als Basis diente. Aber der Grossteil des codes hat sich sowieso verändert.
Auch Kudos an die Jungs und Mädls von CoursePlay, VehicleInspector, VehicleFruitHud, EnhancedVehicle und vielen anderen für Inspirationen und Ideen.
Des weiteren noch Ifko[nator] für das RegisterSpecialization Skript.

## Letzte Version
0.9.0.7 - I würd mal sagen dies ist noch eine Beta. Ich hab zwar selbst recht viel getestet, hoffe aber auf hilfreiche Rückmeldungen von der Community.


# Screenshots
![fsscreen1](https://user-images.githubusercontent.com/20586786/52771954-986b1580-3037-11e9-8e0a-470cdd3c3855.png)
![fsscreen2](https://user-images.githubusercontent.com/20586786/52771955-986b1580-3037-11e9-9880-8c9cb681538d.png)
![fsscreen3](https://user-images.githubusercontent.com/20586786/52771956-986b1580-3037-11e9-999a-7a1c52a57298.png)
![fsscreen4](https://user-images.githubusercontent.com/20586786/52771957-986b1580-3037-11e9-9b32-f98a17d1ef75.png)
![fsscreen5](https://user-images.githubusercontent.com/20586786/52771958-9903ac00-3037-11e9-8083-a22a3c1f8468.png)
![fsscreen6](https://user-images.githubusercontent.com/20586786/52771959-9903ac00-3037-11e9-9d49-59c586aa82dd.png)
![fsscreen7](https://user-images.githubusercontent.com/20586786/52771960-9903ac00-3037-11e9-8afc-284196ea6c9a.png)
![fsscreen8](https://user-images.githubusercontent.com/20586786/52771961-9903ac00-3037-11e9-876c-3bb01aa0cd06.png)
![fsscreen9](https://user-images.githubusercontent.com/20586786/52771962-999c4280-3037-11e9-81b1-a6bb0b2fc38d.png)
