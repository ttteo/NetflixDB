DROP TABLE IF EXISTS Recita_film;
DROP TABLE IF EXISTS Recita_serie;
DROP TABLE IF EXISTS Attore;
DROP TABLE IF EXISTS Episodio;
DROP TABLE IF EXISTS Documentario;
DROP TABLE IF EXISTS SerieTV;
DROP TABLE IF EXISTS Film;
DROP TABLE IF EXISTS Guarda;
DROP TABLE IF EXISTS Contenuto;
DROP TABLE IF EXISTS Profilo;
DROP TABLE IF EXISTS Immagine;
DROP TABLE IF EXISTS MetodoDiPagamento;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS Produzione;

DROP TYPE IF EXISTS AgeRating;
CREATE TYPE AgeRating AS ENUM('T', '6+', '12+', '14+', '16+', '18+');

CREATE TABLE Account(
    email VARCHAR(100) PRIMARY KEY,
    password VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL
);

CREATE TABLE MetodoDiPagamento (
    numeroCarta VARCHAR(16) PRIMARY KEY,
    circuito VARCHAR(20) NOT NULL,
    scadenza DATE NOT NULL,
    intestatario VARCHAR(100) NOT NULL,
    tipoCarta VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    FOREIGN KEY (email) REFERENCES Account(email)
);

CREATE TABLE Immagine(
    idImmagine INT PRIMARY KEY,
    percorsoImmagine VARCHAR(255) NOT NULL
);

CREATE TABLE Profilo (
    idProfilo INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    PIN CHAR(4) NOT NULL,
    LinguaPreferita VARCHAR(20) NOT NULL,
    NumeroContenuti INT NOT NULL,
    email VARCHAR(100) NOT NULL,
    idImmagine INT NOT NULL,
    UNIQUE (email, nome),
    FOREIGN KEY (email) REFERENCES Account(email),
    FOREIGN KEY (idImmagine) REFERENCES Immagine(idImmagine)
);

CREATE TABLE Contenuto (
    idContenuto INT PRIMARY KEY,
    titolo VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    descrizione TEXT NOT NULL,
    dataUscita DATE NOT NULL,
    classificazione AgeRating,
    valutazione DECIMAL(3, 1) CHECK (valutazione >= 0 AND valutazione <= 10)
);

CREATE TABLE Guarda(
    idProfilo INT NOT NULL,
    idContenuto INT NOT NULL,
    PRIMARY KEY (idProfilo, idContenuto),
    FOREIGN KEY (idProfilo) REFERENCES Profilo(idProfilo),
    FOREIGN KEY (idContenuto) REFERENCES Contenuto(idContenuto)
);

CREATE TABLE Produzione(
    idProduzione INT PRIMARY KEY,
    regia VARCHAR(100) NOT NULL,
    sceneggiatura VARCHAR(100) NOT NULL
);

CREATE TABLE Film (
    idContenuto INT PRIMARY KEY NOT NULL,
    durata INT NOT NULL,
    idProduzione INT NOT NULL,
    FOREIGN KEY (idContenuto) REFERENCES Contenuto(idContenuto),
    FOREIGN KEY (idProduzione) REFERENCES Produzione(idProduzione)
);

CREATE TABLE SerieTV (
    idContenuto INT PRIMARY KEY NOT NULL,
    numStagioni INT NOT NULL,
    numTotaleEpisodi INT NOT NULL,
    idProduzione INT NOT NULL,
    FOREIGN KEY (idProduzione) REFERENCES Produzione(idProduzione),
    FOREIGN KEY (idContenuto) REFERENCES Contenuto(idContenuto)
);

CREATE TABLE Documentario (
    idContenuto INT PRIMARY KEY NOT NULL,
    argomento VARCHAR(100) NOT NULL,
    durata INT NOT NULL,
    FOREIGN KEY (idContenuto) REFERENCES Contenuto(idContenuto)
);

CREATE TABLE Episodio (
    idEpisodio INT PRIMARY KEY,
    titolo VARCHAR(100) NOT NULL,
    durata INT NOT NULL,
    numeroEpisodio INT NOT NULL,
    descrizione TEXT NOT NULL,
    idSerieTV INT NOT NULL,
    UNIQUE (idSerieTV, numeroEpisodio),
    FOREIGN KEY (idSerieTV) REFERENCES SerieTV(idContenuto)
);

CREATE TABLE Attore (
    idAttore INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cognome VARCHAR(100) NOT NULL,
    eta INT NOT NULL
);

CREATE TABLE Recita_serie (
    idSerieTV INT NOT NULL,
    idAttore INT NOT NULL,
    PRIMARY KEY (idSerieTV, idAttore),
    FOREIGN KEY (idSerieTV) REFERENCES SerieTV(idContenuto),
    FOREIGN KEY (idAttore) REFERENCES Attore(idAttore)
);

CREATE TABLE Recita_film (
    idFilm INT NOT NULL,
    idAttore INT NOT NULL,
    PRIMARY KEY (idFilm, idAttore),
    FOREIGN KEY (idFilm) REFERENCES Film(idContenuto),
    FOREIGN KEY (idAttore) REFERENCES Attore(idAttore)
);

-- Account
INSERT INTO Account (email, password, telefono) VALUES
('john.doe@gmail.com', 'password123', '+14155552671'),
('maria.rossi@email.it', 'qwerty2024', '+393331234567'),
('akira.tanaka@jpmail.jp', 'sakura2024', '+81312345678'),
('lucas.martin@frmail.fr', 'bonjour2024', '+33612345678'),
('sofia.garcia@esmail.es', 'contraseña2024', '+34612345678'),
('emma.smith@ukmail.co.uk', 'london2024', '+447911123456'),
('li.wei@cnmail.cn', 'beijing2024', '+8613812345678'),
('lucas.silva@brmail.br', 'brasil2024', '+5511998765432');

-- MetodoDiPagamento
INSERT INTO MetodoDiPagamento (numeroCarta, circuito, scadenza, intestatario, tipoCarta, email) VALUES
('4111111111111111', 'Visa', '2027-05-31', 'John Doe', 'Credito', 'john.doe@gmail.com'),
('5555444433332222', 'Mastercard', '2026-11-30', 'Maria Rossi', 'Debito', 'maria.rossi@email.it'),
('378282246310005', 'American Express', '2028-03-31', 'Akira Tanaka', 'Credito', 'akira.tanaka@jpmail.jp'),
('4000123412341234', 'Visa', '2029-08-31', 'Lucas Martin', 'Credito', 'lucas.martin@frmail.fr'),
('6011000990139424', 'Discover', '2027-12-31', 'Sofia Garcia', 'Debito', 'sofia.garcia@esmail.es');

-- Immagine
INSERT INTO Immagine (idImmagine, percorsoImmagine) VALUES
(1, 'img/profili/john.png'),
(2, 'img/profili/maria.png'),
(3, 'img/profili/akira.png'),
(4, 'img/profili/lucas.png'),
(5, 'img/profili/sofia.png'),
(6, 'img/profili/emma.png'),
(7, 'img/profili/wei.png'),
(8, 'img/profili/lucasbr.png'),
(9, 'img/profili/john_child.png'),
(10, 'img/profili/maria_kid.png'),
(11, 'img/profili/akira_alt.png');

-- Profilo
INSERT INTO Profilo (idProfilo, nome, PIN, LinguaPreferita, NumeroContenuti, email, idImmagine) VALUES
(1, 'John', '1234', 'English', 5, 'john.doe@gmail.com', 1),
(2, 'Maria', '5678', 'Italiano', 3, 'maria.rossi@email.it', 2),
(3, 'Akira', '4321', '日本語', 7, 'akira.tanaka@jpmail.jp', 3),
(4, 'Lucas', '2468', 'Français', 2, 'lucas.martin@frmail.fr', 4),
(5, 'Sofia', '1357', 'Español', 4, 'sofia.garcia@esmail.es', 5),
(6, 'Emma', '2468', 'English', 6, 'emma.smith@ukmail.co.uk', 6),
(7, 'Wei', '8888', '中文', 8, 'li.wei@cnmail.cn', 7),
(8, 'LucasBR', '2024', 'Português', 5, 'lucas.silva@brmail.br', 8),
(9, 'Johnny', '1111', 'English', 2, 'john.doe@gmail.com', 9),
(10, 'Mary', '2222', 'Italiano', 1, 'maria.rossi@email.it', 10),
(11, 'Aki', '3333', '日本語', 3, 'akira.tanaka@jpmail.jp', 11);

-- Produzione
INSERT INTO Produzione (idProduzione, regia, sceneggiatura) VALUES
(1, 'Christopher Nolan', 'Jonathan Nolan'),
(2, 'Hayao Miyazaki', 'Hayao Miyazaki'),
(3, 'Vince Gilligan', 'Vince Gilligan'),
(4, 'Bong Joon-ho', 'Han Jin-won'),
(5, 'Greta Gerwig', 'Greta Gerwig'),
(6, 'Baran bo Odar', 'Jantje Friese'),
(7, 'Steven Spielberg', 'Melissa Mathison'),
(8, 'James Cameron', 'James Cameron'),
(9, 'David Attenborough', 'David Attenborough'),
(10, 'Werner Herzog', 'Werner Herzog'),
(11, 'Morgan Neville', 'Morgan Neville');

-- Contenuto
INSERT INTO Contenuto (idContenuto, titolo, categoria, descrizione, dataUscita, classificazione, valutazione) VALUES
(1, 'Inception', 'Film', 'A mind-bending thriller about dreams within dreams.', '2010-07-16', '12+', 8.8),
(2, 'Spirited Away', 'Film', 'A young girl enters a magical world of spirits.', '2001-07-20', '6+', 9.0),
(3, 'Breaking Bad', 'SerieTV', 'A chemistry teacher turns to making meth.', '2008-01-20', '16+', 9.5),
(4, 'Our Planet', 'Documentario', 'A documentary about the beauty of nature.', '2019-04-05', 'T', 8.9),
(5, 'Parasite', 'Film', 'A poor family schemes to become employed by a wealthy family.', '2019-05-30', '16+', 8.6),
(6, 'Stranger Things', 'SerieTV', 'A group of kids faces supernatural forces in their town.', '2016-07-15', '14+', 8.7),
(7, 'Barbie', 'Film', 'Barbie and Ken embark on a journey of self-discovery.', '2023-07-21', '6+', 7.2),
(8, 'Dark', 'SerieTV', 'A family saga with a supernatural twist set in Germany.', '2017-12-01', '16+', 8.8),
(9, 'E.T. the Extra-Terrestrial', 'Film', 'A troubled child summons the courage to help a friendly alien escape Earth.', '1982-06-11', '6+', 7.8),
(10, 'Avatar', 'Film', 'A paraplegic Marine dispatched to the moon Pandora.', '2009-12-18', '12+', 7.9),
(11, 'La La Land', 'Film', 'A jazz pianist falls for an aspiring actress in Los Angeles.', '2016-12-09', '12+', 8.0),
(12, 'Planet Earth', 'Documentario', 'A stunning look at the diversity of our planet.', '2006-03-05', 'T', 9.4),
(13, 'Grizzly Man', 'Documentario', 'A man lives among grizzly bears in Alaska.', '2005-08-12', '14+', 7.8),
(14, '20 Feet from Stardom', 'Documentario', 'Backup singers live in a world just beyond the spotlight.', '2013-01-17', 'T', 7.4),
(15, 'The Blue Planet', 'Documentario', 'Exploring the world''s oceans.', '2001-09-12', 'T', 9.0),
(16, 'Cosmos', 'Documentario', 'A journey through space and time.', '1980-09-28', 'T', 9.3),
(17, 'Inside Bill''s Brain', 'Documentario', 'A look into Bill Gates'' mind.', '2019-09-20', 'T', 7.9),
(18, 'Oceans: The Next Wave', 'Documentario', 'A new look at the world''s oceans.', '2025-03-15', 'T', 8.5),
(19, 'The Future of Space', 'Documentario', 'Exploring future space missions.', '2025-06-10', 'T', 8.7),
(20, 'Cyber City', 'Film', 'A sci-fi thriller set in a futuristic city.', '2025-01-20', '12+', 7.9),
(21, 'Love in Kyoto', 'Film', 'A romantic drama in Japan.', '2025-02-14', '6+', 8.1),
(22, 'The Last Symphony', 'Film', 'A musical journey.', '2025-09-30', 'T', 7.8);

-- Film
INSERT INTO Film (idContenuto, durata, idProduzione) VALUES
(1, 148, 1),
(2, 125, 2),
(5, 132, 4),
(7, 114, 6),
(9, 115, 8),
(10, 162, 9),
(11, 128, 6),
(20, 120, 1),
(21, 110, 2),
(22, 130, 3);

-- SerieTV
INSERT INTO SerieTV (idContenuto, numStagioni, numTotaleEpisodi, idProduzione) VALUES
(3, 5, 62, 3),
(6, 4, 34, 5),
(8, 3, 26, 7);

-- Documentario
INSERT INTO Documentario (idContenuto, argomento, durata) VALUES
(4, 'Nature', 50),
(12, 'Nature', 60),
(13, 'Wildlife', 105),
(14, 'Music', 90),
(15, 'Oceans', 60),
(16, 'Space', 55),
(17, 'Biography', 50),
(18, 'Oceans', 55),
(19, 'Space', 60);

-- Episodio
INSERT INTO Episodio (idEpisodio, titolo, durata, numeroEpisodio, descrizione, idSerieTV) VALUES
(1, 'Pilot', 58, 1, 'Walter White, a chemistry teacher, is diagnosed with cancer.', 3),
(2, 'Cat''s in the Bag...', 48, 2, 'Walt and Jesse clean up the mess.', 3),
(3, '...And the Bag''s in the River', 48, 3, 'Walt faces tough choices as the situation escalates.', 3),
(4, 'Cancer Man', 48, 4, 'Walt tells his family about his illness.', 3),
(5, 'Gray Matter', 47, 5, 'Walt and Skyler attend a former colleague’s party.', 3),
(6, 'The Vanishing of Will Byers', 47, 1, 'A young boy disappears, and a small town uncovers a mystery.', 6),
(7, 'The Weirdo on Maple Street', 55, 2, 'The boys encounter a mysterious girl.', 6),
(8, 'Holly, Jolly', 51, 3, 'Joyce diventa convinta che Will le stia comunicando.', 6),
(9, 'The Body', 50, 4, 'I ragazzi fanno una scoperta e Eleven dimostra il suo valore.', 6),
(10, 'The Flea and the Acrobat', 53, 5, 'I ragazzi cercano di trovare il varco.', 6),
(11, 'Secrets', 52, 1, 'A child''s disappearance sets four families on a frantic hunt.', 8),
(12, 'Lies', 45, 2, 'The families begin to realize their secrets are connected.', 8),
(13, 'Past and Present', 46, 3, 'Ulrich looks for answers and the past comes to light.', 8);

-- Attore
INSERT INTO Attore (idAttore, nome, cognome, eta) VALUES
(1, 'Leonardo', 'DiCaprio', 49),
(2, 'Bryan', 'Cranston', 68),
(3, 'Rumi', 'Hiiragi', 36),
(4, 'Aaron', 'Paul', 45),
(5, 'Song', 'Kang-ho', 57),
(6, 'Millie', 'Bobby Brown', 20),
(7, 'Margot', 'Robbie', 34),
(8, 'Ryan', 'Gosling', 44);

-- Recita_film
INSERT INTO Recita_film (idFilm, idAttore) VALUES
(1, 1),
(2, 3),
(5, 5),
(7, 7),
(7, 8),
(20, 1),
(21, 3),
(22, 5);

-- Recita_serie
INSERT INTO Recita_serie (idSerieTV, idAttore) VALUES
(3, 2),
(3, 4),
(6, 6);

-- Guarda (chi guarda cosa)
INSERT INTO Guarda (idProfilo, idContenuto) VALUES
(1, 1),
(2, 2),
(3, 3),
(1, 4),
(4, 5),
(5, 6),
(5, 7),
(1, 2), 
(1, 3),
(2, 1),
(2, 6),
(3, 5),
(3, 8),
(4, 9),
(4, 12),
(5, 10),
(5, 11),
(6, 1),
(6, 4),
(6, 13),
(7, 6),
(7, 8),
(7, 14),
(8, 2),
(8, 5),
(8, 12),
(3, 4),
(3, 12),
(3, 13),
(5, 4),
(5, 12),
(5, 13),
(6, 12),
(3, 15),
(3, 16),
(5, 15),
(5, 17),
(6, 16),
(6, 17),
(1, 18),
(1, 19),
(1, 20),
(1, 21),
(1, 22),
(2, 18),
(2, 19),
(2, 20),
(2, 21),
(3, 18),
(3, 19),
(3, 20),
(3, 21),
(3, 22),
(5, 18),
(5, 19),
(5, 20),
(5, 21),
(1, 5),
(1, 7),
(1, 9),
(1, 10),
(1, 11),
(3, 2),
(5, 2),
(9, 5),
(9, 7),
(9, 9),
(9, 10),
(9, 11),
(10, 5),
(10, 7),
(10, 9),
(10, 10),
(10, 11),
(11, 5),
(11, 7),
(11, 9),
(11, 10),
(11, 11);

-- INDICI
-- Categoria usata per filtro e group by
CREATE INDEX idx_categoria ON Contenuto(categoria);

-- Combinazione utile per COUNT(DISTINCT) e JOIN su Guarda
CREATE INDEX idx_guarda_profilo_contenuto ON Guarda(idProfilo, idContenuto);

-- Valutazione usata in media per profilo e classificazione
CREATE INDEX idx_valutazione ON Contenuto(valutazione);

-- Classificazione aggregata per calcolare media per età
CREATE INDEX idx_classificazione ON Contenuto(classificazione);

-- Data di uscita usata in BETWEEN (visualizzazioni annuali)
CREATE INDEX idx_dataUscita ON Contenuto(dataUscita);

/*
-- QUERY
-- 1: Numero di film visti dai profili
-- (PARAMETRIZZABILE con la categoria, nell'esempio 'Film')
SELECT p.nome AS NomeProfilo, c.categoria, COUNT(*) AS NumeroContenuti
FROM Profilo p
JOIN Guarda g ON p.idProfilo = g.idProfilo
JOIN Contenuto c ON g.idContenuto = c.idContenuto
WHERE c.categoria = 'Film'
GROUP BY p.idProfilo, p.nome, c.categoria
ORDER BY NumeroContenuti DESC;

-- 2: Profili che hanno visto almeno 3 documentari distinti
-- (PARAMETRIZZABILE con il numero minimo di documentari, nell'esempio 3)
SELECT p.nome AS NomeProfilo, COUNT(DISTINCT c.idContenuto) AS NumDocumentari
FROM Profilo p
JOIN Guarda g ON p.idProfilo = g.idProfilo
JOIN Contenuto c ON g.idContenuto = c.idContenuto
WHERE c.categoria = 'Documentario'
GROUP BY p.idProfilo, p.nome
HAVING COUNT(DISTINCT c.idContenuto) >= 3
ORDER BY NumDocumentari DESC;

-- 3: Valutazione media dei contenuti visti per profilo
SELECT p.nome AS NomeProfilo, AVG(c.valutazione) AS ValutazioneMediaContenutiVisti
FROM Profilo p
JOIN Guarda g ON p.idProfilo = g.idProfilo
JOIN Contenuto c ON g.idContenuto = c.idContenuto
GROUP BY p.idProfilo, p.nome;

-- 4: Numero medio di contenuti visti per classificazione d'età
SELECT c.classificazione, COUNT(*) AS TotaleVisualizzazioni, ROUND(AVG(c.valutazione), 2) AS ValutazioneMedia
FROM Guarda g
JOIN Contenuto c ON g.idContenuto = c.idContenuto
GROUP BY c.classificazione
ORDER BY ValutazioneMedia DESC;

-- 5: Contenuti usciti durante l'anno 2025 guardati dai profili con più di 3 accessi annuali
-- (PARAMETRIZZABILE con l'anno, nell'esempio 2025 e con il numero minimo di accessi annuali, nell'esempio 3)
SELECT p.nome AS NomeProfilo, COUNT(*) AS VisualizzazioniAnnuali
FROM Profilo p
JOIN Guarda g ON p.idProfilo = g.idProfilo
JOIN Contenuto c ON g.idContenuto = c.idContenuto
WHERE c.dataUscita BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.idProfilo, p.nome
HAVING COUNT(*) > 3
ORDER BY VisualizzazioniAnnuali DESC;

*/