# Modelos de aprendizaje supervisado aplicados a la vigilancia prudencial del sistema financiero costarricense

## Repositorio de reproducibilidad

### Autores

Hazel Brenes Umaña
Minor Acuña Araya

### Programa

Programa Iberoamericano de Formación en Minería de Datos
**Máster Ejecutivo en Ciencia de Datos e Inteligencia Artificial**

---

## 1. Propósito del repositorio

Este repositorio contiene **todo el código y los insumos necesarios para reproducir los resultados empíricos** desarrollados en la tesina de graduación *“Modelos de aprendizaje supervisado aplicados a la vigilancia prudencial del sistema financiero costarricense”*.

El objetivo es garantizar:

* Transparencia metodológica
* Reproducibilidad computacional
* Trazabilidad entre datos, modelos y conclusiones

El proyecto se estructura explícitamente en **tres componentes complementarios**, siguiendo buenas prácticas académicas en ciencia de datos y aprendizaje automático:

1. Construcción y análisis exploratorio de los datos
2. Experimento principal de modelación y validación
3. Caso de estudio aplicado a entidades intervenidas

---

## 2. Descripción general del proyecto

El trabajo desarrolla y compara distintos **modelos de aprendizaje supervisado** aplicados a información financiera institucional, con énfasis en:

* Evaluación rigurosa del desempeño predictivo
* Uso de métricas de clasificación (F1 macro, precisión, entre otras)
* Repeticiones múltiples para reducir la variabilidad de los resultados
* Análisis segmentado por tipo de entidad financiera

Adicionalmente, se incorpora un **caso de estudio** orientado a evaluar el comportamiento de los modelos frente a **entidades efectivamente intervenidas**, con fines ilustrativos y de validación aplicada.

---

## 3. Estructura del repositorio

```
├── README.md
├── renv.lock
│
├── 00_data_pipeline/                 # Fase previa: construcción del insumo
│   ├── 0_01_Generar_Base.R
│   ├── 0_02_Analisis_Exploratorio_Datos.Rmd
│   └── salidas/
│       ├── datos.rds / .csv
│       ├── descripcion_cuentas.rds / .csv
│       ├── datos_bancos_limpio.rds / .csv
│       ├── datos_financieras_limpio.rds / .csv
│       ├── datos_cooperativas_limpio.rds / .csv
│
├── analysis/                         # Experimento principal
│   ├── 01_setup.Rmd
│   ├── 02_data_bancos.Rmd
│   ├── 02_data_financieras.Rmd
│   ├── 02_data_cooperativas.Rmd
│   ├── 03_utils.Rmd
│   ├── 04_mlp.Rmd
│   ├── 05_rf.Rmd
│   ├── 06_dt.Rmd
│   ├── 07_comparativo.Rmd
│   └── 08_caso_estudio_entidades_intervenidas.Rmd
│
└── run_all_segments.R                # Orquestador del experimento
```

---

## 4. Fase previa: extracción y análisis exploratorio de datos

### 4.1 Objetivo

La carpeta `00_data_pipeline/` contiene scripts destinados a:

* Descarga de datos desde fuentes externas (API institucional)
* Depuración y transformación de información contable
* Análisis exploratorio inicial
* Apoyo a la selección preliminar de variables

Esta fase **no forma parte del experimento automático**, ya que su objetivo es comprender y preparar los datos, no evaluar modelos predictivos.

---

### 4.2 Script `0_01_Generar_Base.R`

Este script realiza la extracción de datos desde el API institucional, su depuración inicial y la construcción de la base analítica.

**Salidas generadas:**

* `salidas/datos.rds` / `salidas/datos.csv`
* `salidas/descripcion_cuentas.rds` / `salidas/descripcion_cuentas.csv`

---

### 4.3 Script `0_02_Analisis_Exploratorio_Datos.Rmd`

Este documento desarrolla un análisis exploratorio estructurado, orientado a evaluar la calidad de los datos y apoyar la selección preliminar de variables.

**Salidas generadas por segmento:**

* Bancos: `datos_bancos_limpio.rds / .csv`
* Financieras: `datos_financieras_limpio.rds / .csv`
* Cooperativas: `datos_cooperativas_limpio.rds / .csv`

Estos archivos constituyen los **insumos directos del experimento principal**.

---

## 5. Experimento principal: modelación y validación

El análisis central se ejecuta mediante un **flujo reproducible basado en RMarkdown**, orquestado por el script:

```r
source("run_all_segments.R")
```

Este script:

* Ejecuta secuencialmente la preparación de datos, la modelación y la validación
* Repite los experimentos por segmento institucional
* Registra tiempos de ejecución
* Genera reportes reproducibles en formato HTML

---

## 6. Caso de estudio: entidades intervenidas

El archivo:

```
analysis/08_caso_estudio_entidades_intervenidas.Rmd
```

desarrolla un **caso de estudio aplicado**, orientado a analizar el comportamiento de los modelos entrenados frente a **entidades financieras que fueron efectivamente intervenidas**.

Este análisis:

* Utiliza los modelos y métricas definidos en el experimento principal
* No forma parte del proceso de entrenamiento ni validación cruzada
* Tiene un carácter ilustrativo y analítico, no inferencial
* Busca complementar los resultados agregados con evidencia aplicada

El caso de estudio permite conectar los resultados cuantitativos del experimento con situaciones reales relevantes para la **vigilancia prudencial**.

---

## 7. Reproducibilidad

La reproducción de los resultados requiere una instalación funcional de R.

El repositorio permite **dos modalidades de reproducción**:

### Opción A: Reproducción completa con snapshot de datos (recomendada)

1. Restaurar el entorno de trabajo:

```r
renv::restore()
```

2. Ejecutar el experimento completo:

```r
source("run_all_segments.R")
```

Los datos necesarios ya se encuentran incluidos en `00_data_pipeline/salidas/`.

---

### Opción B: Reproducción desde cero (descarga desde API)

Esta modalidad permite reconstruir los datos originales ejecutando los scripts de `00_data_pipeline/`.
Se incluye por **transparencia metodológica**, aunque la reproducibilidad final depende de la estabilidad de las fuentes externas.

---

## 8. Sobre los datos

Los datos incluidos se proporcionan **exclusivamente con fines académicos**, en el contexto de una tesina de graduación.

Corresponden a bases construidas a partir de información institucional que fue:

* Descargada mediante código automatizado
* Depurada y transformada
* Segmentada por tipo de entidad financiera

En entornos profesionales o regulatorios, el uso de estos datos debe ajustarse a las políticas institucionales correspondientes.

---

## 9. Alcance académico

Este repositorio forma parte de una **tesina de graduación de un máster ejecutivo**, pero su estructura y metodología son coherentes con estándares utilizados en:

* Proyectos profesionales de ciencia de datos
* Evaluaciones técnicas en entornos financieros
* Investigaciones con potencial de publicación académica

---

## 10. Contacto

Para cualquier consulta relacionada con el código o la metodología, se puede contactar a los autores.
