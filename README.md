# Projet FPGA - Branche V2

## Objectif de cette branche
Étendre l'architecture V1 (NIOS + PIO) avec l'intégration de la SDRAM externe.

## Nouveautés par rapport à V1
1. Ajout du contrôleur SDRAM dans l'architecture Qsys (`niosII_v1.qsys`).
2. Routage de l'interface SDRAM jusqu'au top VHDL (`lights.vhd`).
3. Placement du programme Nios II en espace mémoire SDRAM.
4. Mise à jour du code C avec les nouvelles adresses de périphériques PIO.

Correspondance interne vers Qsys:
- `sdram_wire_*` : interface conduit du contrôleur SDRAM.
- `sdram_clk_clk` : sortie horloge vers `DRAM_CLK`.

## Rôle du code C
Le fichier `app_software/niosII_light_v2.c` garde la même logique fonctionnelle que V1:
- lire les interrupteurs,
- recopier la valeur sur les LEDs.

La différence importante est l'adressage mémoire (espace V2):
- `switches` -> `0x02003000`
- `leds` -> `0x02003010`

Ces adresses valident la nouvelle carte mémoire après ajout SDRAM.

## Fichiers principaux
- `niosII_v1.qsys` : architecture matérielle avec SDRAM.
- `lights.vhd` : top-level avec ports SDRAM.
- `app_software/niosII_light_v2.c` : programme C de test en V2.


