#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dependencies/include/libpq-fe.h"

PGconn* connectDB() {
    const char *conninfo = "dbname=NetflixDB user=youruser password=yourpassword host=localhost port=yourport";
    PGconn *conn = PQconnectdb(conninfo);
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "Errore connessione DB: %s\n", PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    }
    return conn;
}

void closeDB(PGconn *conn) {
    PQfinish(conn);
}

void printResult(PGresult *res) {
    int rows = PQntuples(res);
    int cols = PQnfields(res);
    
    
    for (int i = 0; i < cols; i++) {
        printf("%-25s", PQfname(res, i));
    }
    printf("\n");
    
    
    for (int i = 0; i < cols; i++) {
        printf("%-25s", "-------------------------");
    }
    printf("\n");
    
    
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%-25s", PQgetvalue(res, i, j));
        }
        printf("\n");
    }
    printf("\nTotale righe: %d\n", rows);
    PQclear(res);
}

void executeSimpleQuery(PGconn *conn, const char *query) {
    PGresult *res = PQexec(conn, query);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query fallita: %s\n", PQerrorMessage(conn));
        PQclear(res);
    } else {
        printResult(res);
    }
}

void executeParamQuery(PGconn *conn, const char *sql, int paramCount, const char **params) {
    PGresult *res = PQexecParams(conn, sql, paramCount, NULL, params, NULL, NULL, 0);
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Query parametrica fallita: %s\n", PQerrorMessage(conn));
        PQclear(res);
    } else {
        printResult(res);
    }
}

int main() {
    PGconn *conn = connectDB();
    int choice;
    
    // Variabili per parametri numerici
    int minDocumentari, anno, minAccessi;
    char minDocumentariStr[20], annoStr[20], minAccessiStr[20];
    
    // Variabili per parametri stringa
    char categoria[50];
    
    char sqlText[2048];

    printf("=== SISTEMA GESTIONALE PIATTAFORMA STREAMING NETFLIX ===\n");
    printf("Database collegato con successo!\n");

    while (1) {
        printf("\n--- Menu Netflix Database ---\n");
        printf("1) Numero di contenuti visti dai profili (PARAMETRIZZABILE per categoria)\n");
        printf("2) Profili con almeno X documentari visti (PARAMETRIZZABILE)\n");
        printf("3) Valutazione media dei contenuti visti per profilo\n");
        printf("4) Numero medio di contenuti per classificazione d'eta' (PARAMETRIZZABILE)\n");
        printf("5) Contenuti di un anno specifico visti da profili attivi (PARAMETRIZZABILE)\n");
        printf("6) Esegui QUERY personalizzata\n");
        printf("0) Esci\n");
        printf("Scelta: ");
        
        if (scanf("%d", &choice) != 1) {
            printf("Input non valido!\n");
            break;
        }
        getchar(); 

        switch (choice) {
            case 1:
                printf("Inserisci la categoria di contenuto (Film/SerieTV/Documentario): ");
                if (fgets(categoria, sizeof(categoria), stdin) != NULL) {
                    
                    size_t len = strlen(categoria);
                    if (len > 0 && categoria[len-1] == '\n') {
                        categoria[len-1] = '\0';
                    }
                    
                    const char *params1[] = {categoria};
                    
                    printf("Eseguendo query: Numero di contenuti visti dai profili per categoria: %s\n", categoria);
                    executeParamQuery(conn,
                        "SELECT p.nome AS NomeProfilo, c.categoria, COUNT(*) AS NumeroContenuti "
                        "FROM Profilo p "
                        "JOIN Guarda g ON p.idProfilo = g.idProfilo "
                        "JOIN Contenuto c ON g.idContenuto = c.idContenuto "
                        "WHERE c.categoria = $1 "
                        "GROUP BY p.idProfilo, p.nome, c.categoria "
                        "ORDER BY NumeroContenuti DESC;",
                        1, params1);
                } else {
                    printf("Errore nell'input della categoria!\n");
                }
                break;
                
            case 2:
                printf("Inserisci il numero minimo di documentari visti: ");
                if (scanf("%d", &minDocumentari) != 1) {
                    printf("Numero non valido!\n");
                    getchar();
                    break;
                }
                getchar();
                
                sprintf(minDocumentariStr, "%d", minDocumentari);
                const char *params2[] = {minDocumentariStr};
                
                printf("Eseguendo query per profili con almeno %d documentari...\n", minDocumentari);
                executeParamQuery(conn,
                    "SELECT p.nome AS NomeProfilo, COUNT(DISTINCT c.idContenuto) AS NumDocumentari "
                    "FROM Profilo p "
                    "JOIN Guarda g ON p.idProfilo = g.idProfilo "
                    "JOIN Contenuto c ON g.idContenuto = c.idContenuto "
                    "WHERE c.categoria = 'Documentario' "
                    "GROUP BY p.idProfilo, p.nome "
                    "HAVING COUNT(DISTINCT c.idContenuto) >= $1 "
                    "ORDER BY NumDocumentari DESC;",
                    1, params2);
                break;
                
            case 3:
                printf("Eseguendo query: Valutazione media contenuti per profilo...\n");
                executeSimpleQuery(conn,
                    "SELECT p.nome AS NomeProfilo, ROUND(AVG(c.valutazione), 2) AS ValutazioneMediaContenutiVisti "
                    "FROM Profilo p "
                    "JOIN Guarda g ON p.idProfilo = g.idProfilo "
                    "JOIN Contenuto c ON g.idContenuto = c.idContenuto "
                    "WHERE c.valutazione IS NOT NULL "
                    "GROUP BY p.idProfilo, p.nome "
                    "ORDER BY ValutazioneMediaContenutiVisti DESC;");
                break;
                
            case 4:
                printf("Vuoi vedere:\n");
                printf("1) Tutte le classificazioni\n");
                printf("2) Una classificazione specifica\n");
                printf("Scelta: ");
                int subChoice;
                if (scanf("%d", &subChoice) != 1) {
                    printf("Scelta non valida!\n");
                    getchar();
                    break;
                }
                getchar();
                
                if (subChoice == 1) {
                    printf("Eseguendo query per tutte le classificazioni d'eta'...\n");
                    executeSimpleQuery(conn,
                        "SELECT c.classificazione, "
                        "COUNT(*) AS TotaleVisualizzazioni, "
                        "ROUND(AVG(c.valutazione), 2) AS ValutazioneMedia "
                        "FROM Guarda g "
                        "JOIN Contenuto c ON g.idContenuto = c.idContenuto "
                        "WHERE c.valutazione IS NOT NULL "
                        "GROUP BY c.classificazione "
                        "ORDER BY ValutazioneMedia DESC;");
                } else if (subChoice == 2) {
                    char classificazione[10];
                    printf("Inserisci la classificazione d'eta' (T/6+/12+/14+/16+/18+): ");
                    if (fgets(classificazione, sizeof(classificazione), stdin) != NULL) {
                        
                        size_t len = strlen(classificazione);
                        if (len > 0 && classificazione[len-1] == '\n') {
                            classificazione[len-1] = '\0';
                        }
                        
                        const char *params4[] = {classificazione};
                        
                        printf("Eseguendo query per classificazione: %s\n", classificazione);
                        executeParamQuery(conn,
                            "SELECT c.classificazione, "
                            "COUNT(*) AS TotaleVisualizzazioni, "
                            "ROUND(AVG(c.valutazione), 2) AS ValutazioneMedia "
                            "FROM Guarda g "
                            "JOIN Contenuto c ON g.idContenuto = c.idContenuto "
                            "WHERE c.valutazione IS NOT NULL AND c.classificazione = $1 "
                            "GROUP BY c.classificazione "
                            "ORDER BY ValutazioneMedia DESC;",
                            1, params4);
                    } else {
                        printf("Errore nell'input della classificazione!\n");
                    }
                } else {
                    printf("Scelta non valida!\n");
                }
                break;
                
            case 5:
                printf("Inserisci l'anno di uscita dei contenuti da analizzare (es. 2025): ");
                if (scanf("%d", &anno) != 1) {
                    printf("Anno non valido!\n");
                    getchar();
                    break;
                }
                
                printf("Inserisci il numero minimo di accessi annuali per i profili: ");
                if (scanf("%d", &minAccessi) != 1) {
                    printf("Numero di accessi non valido!\n");
                    getchar();
                    break;
                }
                getchar();
                
                sprintf(annoStr, "%d", anno);
                sprintf(minAccessiStr, "%d", minAccessi);
                const char *params5[] = {annoStr, annoStr, minAccessiStr};
                
                printf("Eseguendo query: Profili che hanno visto contenuti dell'anno %d con più di %d accessi...\n", anno, minAccessi);
                executeParamQuery(conn,
                    "SELECT p.nome AS NomeProfilo, COUNT(*) AS VisualizzazioniAnnuali "
                    "FROM Profilo p "
                    "JOIN Guarda g ON p.idProfilo = g.idProfilo "
                    "JOIN Contenuto c ON g.idContenuto = c.idContenuto "
                    "WHERE c.dataUscita BETWEEN ($1 || '-01-01')::date AND ($2 || '-12-31')::date "
                    "GROUP BY p.idProfilo, p.nome "
                    "HAVING COUNT(*) > $3::integer "
                    "ORDER BY VisualizzazioniAnnuali DESC;",
                    3, params5);
                break;
                
            case 6:
                printf("Inserisci la query SQL da eseguire (termina premendo INVIO):\n");
                printf("Query: ");
                if (fgets(sqlText, sizeof(sqlText), stdin) != NULL) {
                    
                    size_t len = strlen(sqlText);
                    if (len > 0 && sqlText[len-1] == '\n') {
                        sqlText[len-1] = '\0';
                    }
                    
                    if (strlen(sqlText) > 0) {
                        printf("Eseguendo query personalizzata...\n");
                        executeSimpleQuery(conn, sqlText);
                    } else {
                        printf("Query vuota, operazione annullata.\n");
                    }
                }
                break;
                
            case 0:
                printf("Chiusura connessione database...\n");
                closeDB(conn);
                printf("Arrivederci!\n");
                return 0;
                
            default:
                printf("Opzione non valida. Scegli un numero da 0 a 6.\n");
        }
        
        printf("\nPremi INVIO per continuare...");
        getchar();
    }
    
    closeDB(conn);
    return 0;
}
