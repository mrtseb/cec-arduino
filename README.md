# cec-arduino
Librairie arduinio pour le projet Courses en Cours

https://www.course-en-cours.com/fr/

Le challenge "Courses en cours" offre cette année la possibilité de piloter le moteur au travers d'une carte Arduino. 
Malheureusement pour le moment acune librairie ne prend en charge ce pilotage. C'est la raison d'être de ce dépôt.



Les fonctions permettent:

    - de récupérer des informations depuis l'Arduino connectée en série sur le port UART du moteur.
    - de configurer la course
    - de lancer la course

Limitations:

    - il n'y a pas controle du CRC

Le fichier excel "CeC - API Véhicule - V1.9.xlsx", décrit l'API de commande du moteur. Comme bien souvent dans les systèmes techniques modernes, l'échange d'informations 
se réalise au travers de l'envoi et de la réception de trames d'octets.

Le code fourni ici est un code Opensource. Merci simplement de conserver le droit de paternité de l'oeuvre et de citer le nom de l'auteur.

L'auteur est ouvert à toute remarque et toute contribution qui pourraient faire avancer le projet.
Pour toute question ou suggestion, s'adresser à sebastien.tack@ac-caen.fr . 

Lancement du projet: Février 2020

# A propos de l'auteur:

Sébastien TACK
Professeur de sciences de l'ingénieur au lycée Mezeray d'Argentan. 
sebastien.tack@ac-caen.fr
