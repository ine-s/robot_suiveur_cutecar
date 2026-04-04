# Projet FPGA - Branche V3

## Objectif de cette branche
Étendre l'architecture V2 (NIOS + PIO + SDRAM) en ajoutant le pilotage des moteurs DC
et effectuer la caractérisation de ces moteurs.

## Nouvelles fonctionnalités V3
1. Ajout du bloc PWM (`PWM_generation.vhd`) pour piloter les moteurs DC.
2. Intégration des ports moteurs dans le top VHD (`lights.vhd`):
   - `MTRR_P`, `MTRR_N` : commandes moteur droit.
   - `MTRL_P`, `MTRL_N` : commandes moteur gauche.
   - `MTR_Sleep_n` : commande de sommeil des drivers moteur.
   - `VCC3P3_PWRON_n` : activation de l'alimentation 3.3V des moteurs.
3. Export des signaux moteur depuis Nios II via `moteur_r_export` et `moteur_l_export`.

## Signaux moteur (lights.vhd)
- `moteur_r_export` : commande moteur droit depuis Nios II (16 bits).
- `moteur_l_export` : commande moteur gauche depuis Nios II (16 bits).
- Les 14 bits des commandes sont routés vers le bloc `PWM_generation`.
- Les bits de contrôle additionnels peuvent gérer direction/frein.

## Rôle du bloc PWM_generation
Le module `PWM_generation` reçoit :
- `s_writedataR` (14 bits) : rapport cyclique pour moteur droit.
- `s_writedataL` (14 bits) : rapport cyclique pour moteur gauche.

Il génère les signaux PWM différentiels :
- `dc_motor_p_R`, `dc_motor_n_R` : paire moteur droit.
- `dc_motor_p_L`, `dc_motor_n_L` : paire moteur gauche.

## Objectif du code C en V3 (Caractérisation)
Le programme C doit déterminer et valider par expérience :
1. **Vitesse minimale des roues** : le seuil minimal pour que les roues commencent à tourner (moteur gelé).
2. **Vitesse minimale de déplacement** : seuil pour que le robot se déplace :
   - Sans piles (friction seule).
   - Avec piles.
3. **Vitesse minimale en mouvement sans arrêt** : vitesse minimale durant le déplacement pour ne pas arrêter une roue.
4. **Hystérésie** : écart entre vitesse de démarrage et vitesse de freinage.

Le code C modifie les valeurs envoyées aux moteurs et observe/enregistre le comportement.

## Fichiers principaux
- `niosII_v1.qsys` : architecture Qsys avec moteurs.
- `lights.vhd` : top VHDL avec ports moteurs et contrôle PWM.
- `PWM_generation.vhd` : générateur PWM pour commande moteurs.

## Transition V2 → V3
V2 validait NIOS + PIO + SDRAM.  
V3 ajoute la caractérisation et le contrôle des moteurs DC via PWM.


