# NetflixDB - Sistema di Gestione Piattaforma Streaming Video

Database relazionale progettato per gestire le informazioni di una piattaforma di streaming video (tipo Netflix), realizzato per il corso di Basi di Dati presso l'Università degli Studi di Padova.


## Descrizione del Progetto

Questo progetto implementa una base di dati completa per la gestione di:
- **Account utenti** con profili multipli personalizzati
- **Catalogo contenuti multimediali** (Film, Serie TV, Documentari)
- **Interazioni utenti-contenuti** (visualizzazioni e cronologia)
- **Gestione cast e produzione** (attori, registi, sceneggiatori)

Il sistema gestisce account con profili multipli (identificati da nome, PIN e lingua preferita), un catalogo organizzato in tre categorie principali (film, serie TV con episodi, documentari), e traccia tutte le attività di visualizzazione degli utenti.

## Caratteristiche Principali

### Gestione Account e Profili
- Account identificati da email univoca con credenziali sicure
- Metodi di pagamento associati per abbonamenti
- Profili multipli per famiglia con PIN di sicurezza
- Personalizzazione con immagini profilo

### Catalogo Contenuti
- **Film**: con durata, produzione (regia/sceneggiatura), cast
- **Serie TV**: organizzate in stagioni ed episodi individuali
- **Documentari**: categorizzati per argomento
- Informazioni comuni: titolo, categoria, data uscita, classificazione età, valutazione

### Tracking e Analytics
- Registrazione visualizzazioni per profilo
- Contatori ottimizzati per numero contenuti visti
- Query analitiche per raccomandazioni personalizzate

## Struttura del Database

### Schema E-R
Il database è progettato seguendo un modello Entità-Relazione con:
- **Entità principali**: Account, Profilo, Contenuto, Film, SerieTV, Documentario, Episodio, Attore, Produzione, MetodoPagamento, Immagine
- **Relazioni**: Contiene (Account-Profilo 1:N), Guarda (Profilo-Contenuto N:N), Include (SerieTV-Episodio 1:N), Recita_Film/Recita_Serie (Attore-Contenuto N:N)
- **Generalizzazione totale ed esclusiva**: Contenuto specializzato in Film, Serie TV e Documentario

### Ottimizzazioni
Il progetto include:
- **Analisi delle ridondanze** con calcolo costi operazionali
- Attributi ridondati mantenuti per performance: `numeroContenuti` in Profilo, `numTotaleEpisodi` in SerieTV
- **5 indici ottimizzati** per accelerare query frequenti su categoria, visualizzazioni, valutazioni, classificazione e date

## Installazione e Setup

### Prerequisiti
- PostgreSQL (versione 12 o superiore)
- GCC compiler per il programma C
- Libreria libpq-dev (header PostgreSQL)

### Installazione Database

```bash
# 1. Creare il database
psql -U postgres -c "CREATE DATABASE NetflixDB;"

# 2. Importare lo schema e i dati
psql -U postgres -d NetflixDB -f NetflixDB.sql
```

### Compilazione Programma C

```bash
# Compilazione standard
gcc -o execute_query execute_query.c -lpq

# Se PostgreSQL è installato in percorsi non standard
gcc -o execute_query -I/usr/include/postgresql execute_query.c -L/usr/lib/postgresql -lpq
```

## Utilizzo

### Esecuzione del Software

```bash
./execute_query
```

Il programma offre un menu interattivo con:

1. **Query parametrizzata per categoria** - Visualizza numero di contenuti visti dai profili filtrato per categoria (Film/SerieTV/Documentario)
2. **Profili con N documentari visti** - Trova profili che hanno visto almeno X documentari (parametrizzabile)
3. **Valutazione media contenuti per profilo** - Analizza le preferenze di visualizzazione
4. **Contenuti per classificazione d'età** - Statistiche su visualizzazioni e valutazioni medie
5. **Contenuti anno specifico** - Profili attivi che hanno visto contenuti di un determinato anno (parametrizzabile)
6. **Query personalizzata** - Esegui query SQL custom

### Esempi di Query

**Query 1**: Numero di film visti dai profili
```sql
SELECT p.nome AS NomeProfilo, c.categoria, COUNT(*) AS NumeroContenuti
FROM Profilo p
JOIN Guarda g ON p.idProfilo = g.idProfilo
JOIN Contenuto c ON g.idContenuto = c.idContenuto
WHERE c.categoria = 'Film'
GROUP BY p.idProfilo, p.nome, c.categoria
ORDER BY NumeroContenuti DESC;
```

**Query 2**: Profili con almeno 3 documentari visti
```sql
SELECT p.nome AS NomeProfilo, COUNT(DISTINCT c.idContenuto) AS NumDocumentari
FROM Profilo p
JOIN Guarda g ON p.idProfilo = g.idProfilo
JOIN Contenuto c ON g.idContenuto = c.idContenuto
WHERE c.categoria = 'Documentario'
GROUP BY p.idProfilo, p.nome
HAVING COUNT(DISTINCT c.idContenuto) >= 3
ORDER BY NumDocumentari DESC;
```

## Struttura File del Progetto

```
NetflixDB/
├── NetflixDB.sql          # Script SQL completo (schema + dati + query)
├── execute_query.c        # Programma C per interrogazioni database
├── dependencies/          # Librerie PostgreSQL
│   └── include/
│       ├── libpq-fe.h
│       ├── pg_config_ext.h
│       └── postgres_ext.h
└── README.md              # Questo file
```

## Schema Relazionale

Le tabelle principali del database:

- **Account**(email, password, telefono)
- **MetodoDiPagamento**(numeroCarta, circuito, scadenza, intestatario, tipoCarta, fk_email)
- **Profilo**(idProfilo, nome, PIN, linguaPreferita, numeroContenuti, fk_email, fk_idImmagine)
- **Contenuto**(idContenuto, titolo, categoria, descrizione, dataUscita, classificazione, valutazione)
- **Film**(fk_idContenuto, durata, fk_idProduzione)
- **SerieTV**(fk_idContenuto, numStagioni, numTotaleEpisodi, fk_idProduzione)
- **Documentario**(fk_idContenuto, argomento, durata)
- **Episodio**(idEpisodio, titolo, durata, numeroEpisodio, descrizione, fk_idSerieTV)
- **Attore**(idAttore, nome, cognome, eta)
- **Produzione**(idProduzione, regia, sceneggiatura)
- **Guarda**(fk_idProfilo, fk_idContenuto)
- **Recita_serie**(fk_idSerieTV, fk_idAttore)
- **Recita_film**(fk_idFilm, fk_idAttore)

## Vincoli di Integrità

Il database implementa:
- **Primary Keys** su tutte le entità
- **Foreign Keys** con integrità referenziale
- **CHECK constraints** per valutazioni (0-10)
- **ENUM** per classificazioni età (T, 6+, 12+, 14+, 16+, 18+)
- **Vincolo univocità** nomi profili all'interno dello stesso account

## Indici Ottimizzati

```sql
CREATE INDEX idx_categoria ON Contenuto(categoria);
CREATE INDEX idx_guarda_profilo_contenuto ON Guarda(idProfilo, idContenuto);
CREATE INDEX idx_valutazione ON Contenuto(valutazione);
CREATE INDEX idx_classificazione ON Contenuto(classificazione);
CREATE INDEX idx_dataUscita ON Contenuto(dataUscita);
```

## Configurazione Connessione

Il programma C si connette al database con i seguenti parametri (modificabili in [execute_query.c:7](execute_query.c#L7)):

```c
const char *conninfo = "dbname=NetflixDB user=postgres password=123456 host=localhost port=5432";
```

**Importante**: Modifica password e credenziali prima dell'uso in produzione.

## Analisi delle Performance

L'analisi economica delle operazioni ha dimostrato che:
- Mantenere `numeroContenuti` riduce i costi da 50.400 a 2.400 accessi/giorno
- Mantenere `numTotaleEpisodi` riduce i costi da 255.040 a 5.090 accessi/giorno

Questi attributi ridondanti sono essenziali per una piattaforma streaming con alta frequenza di letture.

## Licenza

Progetto accademico realizzato per il corso di Basi di Dati - Università degli Studi di Padova.

## Contatti

Per domande o informazioni sul progetto, contattare gli autori.
