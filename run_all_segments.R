# ============================================================
# run_all_segments.R
# EJECUCIÓN COMPLETA POR SEGMENTO
# OUTPUTS ORGANIZADOS POR CARPETAS
# ============================================================

library(rmarkdown)
library(here)
library(glue)
library(fs)

# ------------------------------------------------------------
# INICIO GLOBAL
# ------------------------------------------------------------
inicio_global <- Sys.time()

# ------------------------------------------------------------
# SEGMENTOS
# ------------------------------------------------------------
segmentos <- c("bancos", "cooperativas", "financieras")

# ------------------------------------------------------------
# DIRECTORIO BASE DE OUTPUTS
# ------------------------------------------------------------
dir_out <- here("salidas")
dir_create(dir_out)

# ------------------------------------------------------------
# SETUP GLOBAL (una sola vez)
# ------------------------------------------------------------
render(
  input       = here("01_setup.Rmd"),
  output_dir  = dir_out,
  output_file = "01_setup.html"
)

# ------------------------------------------------------------
# LOOP POR SEGMENTO
# ------------------------------------------------------------
for (seg in segmentos) {
  
  inicio_segmento <- Sys.time()
  
  # ----------------------------
  # CARPETA DEL SEGMENTO
  # ----------------------------
  dir_seg <- path(dir_out, seg)
  dir_create(dir_seg)
  
  # ----------------------------
  # DATOS
  # ----------------------------
  render(
    input       = here(glue("02_data_{seg}.Rmd")),
    output_dir  = dir_seg,
    output_file = glue("02_data_{seg}.html")
  )
  
  # ----------------------------
  # UTILIDADES
  # ----------------------------
  render(
    input       = here("03_utils.Rmd"),
    output_dir  = dir_seg,
    output_file = glue("03_utils_{seg}.html")
  )
  
  # ----------------------------
  # MODELOS
  # ----------------------------
  render(
    input       = here("04_mlp.Rmd"),
    output_dir  = dir_seg,
    output_file = glue("04_mlp_{seg}.html")
  )
  
  render(
    input       = here("05_rf.Rmd"),
    output_dir  = dir_seg,
    output_file = glue("05_rf_{seg}.html")
  )
  
  render(
    input       = here("06_dt.Rmd"),
    output_dir  = dir_seg,
    output_file = glue("06_dt_{seg}.html")
  )
  
  # ----------------------------
  # COMPARATIVO
  # ----------------------------
  render(
    input       = here("07_comparativo.Rmd"),
    output_dir  = dir_seg,
    output_file = glue("07_comparativo_{seg}.html")
  )
  
  fin_segmento <- Sys.time()
  
  message(
    glue(
      "SEGMENTO {toupper(seg)} | Duración: ",
      round(difftime(fin_segmento, inicio_segmento, units = "mins"), 2),
      " minutos"
    )
  )
}

# ------------------------------------------------------------
# FIN GLOBAL
# ------------------------------------------------------------
fin_global <- Sys.time()

message(
  glue(
    "DURACIÓN TOTAL: ",
    round(difftime(fin_global, inicio_global, units = "hours"), 2),
    " horas"
  )
)
