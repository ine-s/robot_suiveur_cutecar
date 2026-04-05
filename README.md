# Projet FPGA - Branche V4

## Objectif
Réaliser le suivi de ligne en utilisant les 7 capteurs sol, puis piloter les deux moteurs
avec une correction différentielle autour d'une vitesse de base.

## Principe de suivi de ligne
1. Le programme attend `start_SL = 1` (interrupteur SW0).
2. Les capteurs fournissent `vect_cap` (7 bits), disponible quand `data_ready = 1`.
3. La position de ligne `POSL` est estimée par une moyenne pondérée des capteurs actifs.
4. Un biais est calculé: `BIAS = Kp * POSL`.
5. Les consignes PWM sont appliquées :
	 - `PWM_droit = Constante + BIAS`
	 - `PWM_gauche = Constante - BIAS`
6. Si la ligne disparaît pendant plusieurs acquisitions successives, `fin_SL = 1` et les moteurs sont arrêtés.

## Signaux utilisés
- `start_SL`: SW0 lu via `INPUT` (adresse `0x3010`).
- `fin_SL`: généré en logiciel quand la ligne est perdue.
- `vect_cap`: vecteur capteurs seuillés lu via `VECT_CAP` (adresse `0x0050`).
- `data_ready`: validité d'échantillon via `DATA_READY_R` (adresse `0x0020`).
- `niveau`: seuil de détection écrit dans `NIVEAU` (adresse `0x0040`).

## Commande moteurs
- `CNTRL_RIGHT` (adresse `0x0000`) et `CNTRL_LEFT` (adresse `0x0010`).
- Format consigne moteur (14 bits):
	- bit13: go/stop
	- bit12: sens (0 = forward)
	- bits11..0: duty-cycle PWM

## Fichiers V4 utilisés
- `lights.vhd`: top-level de la branche V4.
- `line_follow_core.vhd`: coeur matériel (pont NIOS/ADC/PWM).
- `capteurs_sol_seuil.vhd`: acquisition ADC + seuillage des 7 capteurs.
- `PWM_generation.vhd`: génération PWM des deux moteurs.
- `software/niosII_v4_line_follow.c`: boucle de suivi de ligne (`start_SL`, `POSL`, `BIAS`, `fin_SL`).

## Validation expérimentale
Pendant les essais, les LEDs affichent:
- LED0 = `start_SL`
- LED1 = `fin_SL`

Le robot suit la ligne tant que `start_SL = 1` et s'arrête automatiquement quand la ligne est absente durablement.

