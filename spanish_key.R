# Cargar librerías
library(xml2)
library(sentimentr)

# Cargar archivo
archivo <- "https://raw.githubusercontent.com/mananoreboton/en-es-en-Dic/master/src/main/resources/dic/es-en.xml"
xml_data <- read_xml(archivo)

# Palabras en español
c <- xml_find_all(xml_data, './/c')
spanish_words <- xml_text(c)

# Palabras en inglés
d <- xml_find_all(xml_data, './/d')
english_words <- xml_text(d)

# Crear diccionario
es_en_dictionary <- data.frame(
  spanish = spanish_words,
  english = english_words
)

# Eliminar filas vacías
es_en_dictionary <- subset(es_en_dictionary, english != "")

# Hacer análisis de sentimiento
polarity <- sentiment_by(es_en_dictionary$english)

# Crear diccionario con variable numérica
es_dictionary <- data.frame(
  words = es_en_dictionary$spanish,
  polarity,
  stringsAsFactors = FALSE
)

# Borrar filas
es_dictionary <- es_dictionary[-c(1:5,9:14),]

# Borrar columnas
es_dictionary <- es_dictionary[,-c(2,3,4)]

# Cambiar nombre de ave_sentiment a polarity
colnames(es_dictionary) <- c('words','polarity')

# Eliminar ceros
es_dictionary <- subset(es_dictionary, polarity != 0)

# Detectar y eliminar duplicados
es_dictionary$duplicated <- duplicated(es_dictionary$words)
es_dictionary <- subset(es_dictionary, duplicated != 'TRUE')

# Cambiar el número de fila
row.names(es_dictionary) <- c(1:nrow(es_dictionary))

# Eliminar columna con variable lógica
es_dictionary <- es_dictionary[,-3]

# Ver si el dataframe es un key
is_key(es_dictionary) # FALSE

# Convertir diccionario en key
es_key <- as_key(es_dictionary, comparison = NULL)
is_key(es_key) # TRUE

# Redondear valores de polaridad
es_key$y <- round(es_key$y, 2)

# Guardar key
save(es_key, file = "es_key.Rda")

# Probar key
texto <- c('No me ha encantado esta película.','Eres un verdadero amigo.','Todo esto es muy malo.')
sentiment_by(texto, polarity_dt = es_key)

# Resultado
#   element_id word_count sd ave_sentiment
#1:          1          7 NA    -0.4686759
#2:          2          4 NA     0.7750000
#3:          3          6 NA    -0.3354102
