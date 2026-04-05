# Projet FPGA - Branche V5

## Objectif V5
Ajouter a la branche suivi de ligne une logique d'aller-retour:
1. Suivre la ligne jusqu'a `fin_SL`.
2. Marquer une pause.
3. Tourner sur place jusqu'a realigner le robot avec la ligne (`fin_rot`).
4. Repartir en suivi de ligne dans l'autre sens.

## Architecture materielle V5
- `v5_roundtrip_core.vhd`: top-level V5.
- `CTL_SL`: controleur de suivi de ligne.
- `CTL_Rot`: controleur de rotation sur place.
- `PWM_generation.vhd`: actionnement des deux moteurs.
- `capteurs_sol_seuil.vhd`: acquisition capteurs + seuillage.
- `nios_v5_system.qsys`: interface Nios/PIO (commandes et etats).

Le multiplexage des commandes moteurs est priorise ainsi:
1. Rotation (`start_Rot = 1`)
2. Suivi de ligne (`start_SL = 1`)
3. Commande directe Nios (mode manuel)

## Machine d'etats logiciel (aller-retour)
Le programme `software/niosII_v5_roundtrip.c` utilise 4 etats:
1. `WAIT`: attente de detection de ligne.
2. `FOLLOW`: suivi de ligne actif (`start_SL = 1`).
3. `PAUSE`: arret temporaire apres `fin_SL`.
4. `ROTATE`: rotation jusqu'a `fin_rot`, puis reprise du suivi.


La direction de rotation est alternee a chaque cycle pour faire l'aller-retour.

## Interface Nios (PIO) - V5

Semantique des ports:
- `PORT_S[0] = start_SL`
- `PORT_S[1] = start_Rot`
- `PORT_S[2] = dir_Rot`
- `PORT_E[0] = fin_SL`
- `PORT_E[1] = fin_rot`


## Comportement attendu V5
- Si la ligne est detectee, le robot suit la ligne.
- A `fin_SL`, le robot s'arrete, attend, puis lance une rotation.
- A `fin_rot`, la rotation s'arrete et le suivi de ligne reprend.
- Le cycle se repete en inversant la direction de rotation a chaque tour.

