# ===============================================================
# Artículo: Modelos de aprendizaje supervisado aplicados a la 
# vigilancia prudencial del sistema financiero costarricense
# Autores: Hazel Brenes Umaña y Minor Acuña Araya
# Script:  01_Generar_Base.R
# Propósito: Descarga y depuración de datos contables desde el API
#            de la Sugef. Genera base de indicadores por entidad.
# Fecha:   2025-11-20
# Salidas esperadas:
#   - entradas/datos.csv
#   - entradas/datos.rds
#   - entradas/descripcion_cuentas.csv
#   - entradas/descripcion_cuentas.rds
# ===============================================================

# ===============================================================
# 0. CARGA DE PAQUETES
# ===============================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(httr)
  library(jsonlite)
  library(lubridate)
  library(here)
  library(tidyr)
})

# ===============================================================
# 1. DESCARGA DE DATOS DESDE EL API SUGEF
# ===============================================================

url <- "https://www.sugef.fi.cr/Bccr.Sugef.Reportes_SitioWeb.API/ReportesFinancieraContable/MAPI/ReporteBalanzaComprobacionEntidad"

# Códigos de cuentas contables de interés
codigoCuenta_raw <- "
  11000000, 12000000, 13000000, 14000000, 15000000, 
  16000000, 17000000, 18000000, 19000000, 13900000,
  21000000, 22000000, 23000000, 24000000, 25000000,
  26000000, 29000000,
  31000000, 32000000, 33000000, 34000000, 35000000,
  36000000, 38000000
"

cuentas <- unique(strsplit(gsub("\\s+", "", codigoCuenta_raw), ",")[[1]])

# División en bloques para evitar límites del API
bloques <- split(cuentas, ceiling(seq_along(cuentas) / 20))

consultar_bloque <- function(cuentas_bloque) {
  
  payload <- list(
    parametrosEntidad = list(
      codigoEntidad = "",
      # Se usa una fecha futura como límite superior para
      # garantizar la descarga completa hasta el último dato disponible
      periodos = "20150101-20431201",
      codigoCuenta = paste(cuentas_bloque, collapse = ",")
    )
  )
  
  response <- POST(
    url,
    add_headers(
      "accept"       = "text/plain",
      "Content-Type" = "application/json"
    ),
    body   = toJSON(payload, auto_unbox = TRUE),
    encode = "json"
  )
  
  if (http_type(response) == "application/json") {
    res <- content(response, as = "parsed", encoding = "UTF-8")
    if (!is.null(res[[1]])) return(res[[1]])
  }
  
  return(NULL)
}

df <- bloques %>%
  lapply(consultar_bloque) %>%
  bind_rows() %>%
  filter(!is.na(periodo)) %>%
  mutate(
    periodo        = as.Date(ymd_hms(periodo)),
    codigoEntidad  = as.character(codigoEntidad),
    saldoFinal     = as.numeric(saldoFinal),
    codigoSector   = as.numeric(codigoSector)
  )

# ===============================================================
# 2. DEPURACIÓN Y DESCRIPCIONES
# ===============================================================

df <- df %>%
  mutate(cuenta = paste0("C", cuentaCatalogoSugef / 100000))

# Descripción de cuentas contables
descripcion_ctas <- df %>% 
  select(cuenta, cuentaCatalogoSugef, nombreCuenta) %>% 
  distinct()

# Descripción de sectores
descripcion_sectores <- df %>% 
  select(codigoSector, descripcionSector) %>% 
  distinct()

# ===============================================================
# 3. CONTROL DE COBERTURA POR ENTIDAD
# ===============================================================

fecha_max <- df %>% 
  summarise(fecha = max(periodo, na.rm = TRUE)) %>% 
  pull(fecha)

entidades_en_max <- df %>% 
  filter(periodo == fecha_max) %>% 
  distinct(codigoEntidad)

entidades_no_estan <- df %>% 
  distinct(
    codigoEntidad,
    nombreEntidad,
    codigoSector,
    descripcionSector
  ) %>% 
  anti_join(entidades_en_max, by = "codigoEntidad") %>% 
  arrange(codigoSector, codigoEntidad)

# ===============================================================
# 4. TRANSFORMACIÓN A FORMATO ANCHO
# ===============================================================

df_ancho <- df %>% 
  filter(codigoSector %in% c(1:4, 6)) %>%
  filter(codigoEntidad != "3007078890") %>%  # Excluir BANHVI
  filter(
    codigoEntidad %in% c(
      unique(df %>% filter(periodo == fecha_max) %>% pull(codigoEntidad)),
      "3101135871",  # Desyfin
      "3004045111"   # CoopeServidores
    )
  ) %>%
  mutate(cuenta = factor(cuenta, levels = sort(unique(cuenta)))) %>% 
  select(
    codigoSector,
    descripcionSector,
    codigoEntidad,
    nombreEntidad,
    periodo,
    cuenta,
    saldoFinal
  ) %>% 
  pivot_wider(
    names_from  = cuenta,
    values_from = saldoFinal,
    values_fill = 0
  )

# ===============================================================
# 5. NORMALIZACIÓN DE NOMBRES DE ENTIDADES
# ===============================================================

df_ancho$nombreEntidad <- df_ancho$nombreEntidad %>%
  sub(" -.*", "", .) %>%
  sub("^BANCO DE COSTA RICA$", "BCR", .) %>%
  sub("^BANCO BAC SANJOSE$", "BAC", .) %>%
  sub("^COOPEANDE\\s*(N[º°o]?\\s*1.*)?$", "COOPEANDE", .) %>%
  sub("^BANCO ", "", .) %>%
  sub(" BANK$", "", .) %>%
  sub("^FINANCIERA ", "", .) %>%
  gsub("\\s+", "_", .) %>%
  toupper() %>%
  trimws()

# ===============================================================
# 6. GUARDADO DE RESULTADOS
# ===============================================================

dir.create(here::here("entradas"), showWarnings = FALSE, recursive = TRUE)

write.csv2(df_ancho, here::here("entradas/datos.csv"), row.names = FALSE)
saveRDS(df_ancho,  here::here("entradas/datos.rds"))

write.csv2(descripcion_ctas, here::here("entradas/descripcion_cuentas.csv"), row.names = FALSE)
saveRDS(descripcion_ctas,  here::here("entradas/descripcion_cuentas.rds"))
