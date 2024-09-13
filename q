cours 2 : 
exercice 1:
Protocole avec contrôle de flux "stop and wait" + détection d'erreurs et retransmission sur acquittement négatif
hypothèse: pas d'erreur sur les aquitements, pas de perte (quelque soit le paquet)


type paquet = structure{octet type, octet ctrl, message info}
Données:
Message buffer  
paquet buffer
------------------------------------------
début
tant que vrai faire
    de_application(buffer);
    pdata.info <- buffer;
    pdata.ctrl <- generer_controle(pdata);
    répeter
        vers_reseau(pdata);
        de_reseau(pack); // bloquant
    jusqu'à pack.type=ack
    fin
fin

Données:
Message buffer
paquet pdata, pack
début
tant que vrai faire
    de_reseau(pdata);
    if verifier_controle(pdata) alors 
        buffer <- pdata.info
        vers_application(buffer);
        pack.type <- ACK;
    sinon
        pack.type <- NACK;
    vers_reseau(pack);
    fin
fin



2)
protocole avec contrôle de flux et reprise sur les erreurs "stop and wait"
(par : positive acknowledgment with retransmission)
dans le type de données paquet : rajout d'un "numseq" pour numéroter les paquets de données (au moins modulo 2)
type paquet = structure {octet type, entier numseq, octet ctrl, message info}

données :
Message buffer
Paquet pdata, pack
Evenement evt
entier prochain_paquet


Début
prochain_paquet <- 0;
tant que vrai faire
    de_application(buffer);
    pdata.info <- buffer; 
    pdata.numseq <- prochain_paquet;
    pdata.ctrl <- generer_controle(pdata);
    vers_reseau(pdata);
    depart_temporisateur();
    evt <- attendre
    tant que evt = timeout faire
        //réémission
        vers_reseau(pdata);
        depart_temporisateur();
        evt <- attendre();
        fin
    // paquet d'ack reçus (evt == paquet_arrivée)
    de_reseau(pack) // retrait de l'ack du buffer de réception
    arreter_temporisateur();
    prochain_paquet <- inc(prochain_paquet ,2);
    fin
fin