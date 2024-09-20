/*************************************************************
* proto_tdd_v0 -  émetteur                                   *
* TRANSFERT DE DONNEES  v0                                   *
*                                                            *
* Protocole sans contrôle de flux, sans reprise sur erreurs  *
*                                                            *
* E. Lavinal - Univ. de Toulouse III - Paul Sabatier         *
**************************************************************/

#include <stdio.h>
#include "application.h"
#include "couche_transport.h"
#include "services_reseau.h"

/* =============================== */
/* Programme principal - émetteur  */
/* =============================== */
int main(int argc, char* argv[])
{
    unsigned char message[MAX_INFO]; /* message de l'application */
    int taille_msg; /* taille du message */
    int prochain_paquet = 0;
    int evt; // evenement

    paquet_t paquet; /* paquet utilisé par le protocole */
    paquet_t pack; 





    init_reseau(EMISSION);

    printf("[TRP] Initialisation reseau : OK.\n");
    printf("[TRP] Debut execution protocole transport.\n");

    /* lecture de donnees provenant de la couche application */
    de_application(message, &taille_msg);

    /* tant que l'émetteur a des données à envoyer */
    while ( taille_msg != 0 ) {

        /* construction paquet */
        for (int i=0; i<taille_msg; i++) {
            paquet.info[i] = message[i];
        }
        paquet.lg_info = taille_msg;  
        paquet.type = DATA;
        paquet.num_seq = prochain_paquet;
        paquet.somme_ctrl = generer_controle(paquet);

        /* remise à la couche reseau */
        vers_reseau(&paquet);

        depart_temporisateur(100);
        evt = attendre();

        while (evt != PAQUET_RECU){
            vers_reseau(&paquet);
            depart_temporisateur(100);
            evt = attendre();
        }

        de_reseau(&pack);
        arret_temporisateur();
        prochain_paquet = inc(prochain_paquet, 2);

        /* lecture des donnees suivantes de la couche application */
        de_application(message, &taille_msg);
    }

    printf("[TRP] Fin execution protocole transfert de donnees (TDD).\n");
    return 0;

}
