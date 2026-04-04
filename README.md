# Projet FPGA - Branche V1

## Objectif de cette branche
Implémenter la partie NIOS + PIO.

## Ce qui a été fait
1. Étude des blocs VHDL fournis dans le projet.
2. Mise en place de l'architecture matérielle NIOS + PIO dans Qsys.
3. Génération et intégration du système matériel dans Quartus.
4. Développement d'un programme C pour piloter le PIO.

## Signaux et interfaces ajoutés/utilisés
### Niveau top VHDL (`lights.vhd`)
- `CLOCK_50` : horloge système injectée dans Nios II (`clk_clk`).
- `KEY(0)` : reset actif bas du système (`reset_reset_n`).
- `SW(7 downto 0)` : entrée 8 bits lue via le PIO d'entrée (`sw_export`).
- `LED(7 downto 0)` : sortie 8 bits pilotée via le PIO de sortie (`led_export`).

### Niveau interconnexion Qsys (`niosII_v1`)
- `sw_export` : port Avalon PIO en entrée vers le processeur Nios II.
- `led_export` : port Avalon PIO en sortie depuis le processeur Nios II.

## Rôle du programme C
Le fichier `app_software/niosII_light_v1.c` réalise une boucle de test minimale de la chaîne
NIOS -> bus Avalon -> PIO :
- lecture continue de la valeur des interrupteurs (`switches` à l'adresse `0x0003000`),
- écriture immédiate de cette valeur vers les LEDs (`leds` à l'adresse `0x0003010`).

Ce programme valide que le mapping mémoire des PIO est correct et que la communication
matériel/logiciel fonctionne sur la version V1.

## Fichiers principaux
- `niosII_v1.qsys` : architecture Qsys de la version V1.
- `lights.vhd` : logique VHDL liée au pilotage.
- `app_software/niosII_light_v1.c` : programme C de pilotage du PIO.

## Remarque importante
L'ajout et la validation de la SDRAM ne sont pas traités dans cette branche V1.
Ils sont réalisés dans la branche dédiée à la SDRAM nommée V2.
