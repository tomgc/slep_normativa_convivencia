# Migración del legado de encargos

> Generada por `plantillas/98_migrar_encargos.R` sobre `e2b4885`, plan_md5 `dae7de78aa3df5f4dbe9a4c0573d5410`.
> Puente entre las rutas que citan los traspasos viejos y las nuevas. No se
> edita: `historico/` está congelado (`POLITICA_PROYECTO.md` §1.3.2 punto 8).
> El cierre descuenta de IE1 e IE4 las filas con `clase = queda`.

| ruta_original | ruta_nueva | fecha_primer_commit | clase | motivo |
|---|---|---|---|---|
| 50_documentacion/andamios/20260825_encargo_bootstrap_v1.md | 50_documentacion/encargos/historico/202608/andamios/20260825_encargo_bootstrap_v1.md | 2026-08-25 | mueve | — |
| 50_documentacion/andamios/20260825_encargo_fase2_v1.md | 50_documentacion/encargos/historico/202608/andamios/20260825_encargo_fase2_v1.md | 2026-08-25 | mueve | — |
| 50_documentacion/andamios/20260826_encargo_auditoria_y_cierre_v3.md | 50_documentacion/encargos/historico/202608/andamios/20260826_encargo_auditoria_y_cierre_v3.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/20260826_encargo_avance_maquina_v1.md | 50_documentacion/encargos/historico/202608/andamios/20260826_encargo_avance_maquina_v1.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/20260826_encargo_avance_maquina_v2.md | 50_documentacion/encargos/historico/202608/andamios/20260826_encargo_avance_maquina_v2.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/20260826_encargo_correcciones_v4.md | 50_documentacion/encargos/historico/202608/andamios/20260826_encargo_correcciones_v4.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/20260826_encargo_endurecimiento_v5.md | 50_documentacion/encargos/historico/202608/andamios/20260826_encargo_endurecimiento_v5.md | 2026-08-27 | mueve | — |
| 50_documentacion/andamios/20260827_encargo_cierre_calidad_v7.md | 50_documentacion/encargos/historico/202608/andamios/20260827_encargo_cierre_calidad_v7.md | 2026-08-27 | mueve | — |
| 50_documentacion/andamios/20260827_encargo_ensayo_general_v6.md | 50_documentacion/encargos/historico/202608/andamios/20260827_encargo_ensayo_general_v6.md | 2026-08-27 | mueve | — |
| 50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md | 50_documentacion/encargos/historico/202609/andamios/20260904_encargo_alcance_motor_busqueda_v1.md | 2026-09-05 | mueve | — |
| 50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md | 50_documentacion/encargos/historico/202609/andamios/20260908_encargo_correcciones_visibles_v1.md | 2026-09-09 | mueve | — |
| 50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md | 50_documentacion/encargos/historico/202609/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md | 2026-09-09 | mueve | — |
| 50_documentacion/andamios/20260908_encargo_revision_externa_motor_v1.md | 50_documentacion/encargos/historico/202609/andamios/20260908_encargo_revision_externa_motor_v1.md | 2026-09-09 | mueve | — |
| 50_documentacion/andamios/20260908_juicio_encargo_v9_v1.md | 50_documentacion/encargos/historico/202609/andamios/20260908_juicio_encargo_v9_v1.md | 2026-09-09 | mueve | — |
| 50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md | 50_documentacion/encargos/historico/202609/andamios/20260909_encargo_v11_indice_y_expansion_v1.md | 2026-09-10 | mueve | — |
| 50_documentacion/andamios/20260910_encargo_v12_precedencia_v1.md | 50_documentacion/encargos/historico/202610/andamios/20260910_encargo_v12_precedencia_v1.md | 2026-10-07 | mueve | — |
| 50_documentacion/andamios/logs/20260825_bootstrap_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260825_bootstrap_log.md | 2026-08-25 | mueve | — |
| 50_documentacion/andamios/logs/20260825_fase2_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260825_fase2_log.md | 2026-08-25 | mueve | — |
| 50_documentacion/andamios/logs/20260825_ocr_curaduria_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260825_ocr_curaduria_log.md | 2026-08-25 | mueve | — |
| 50_documentacion/andamios/logs/20260825_resolucion_dudas_fase2_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260825_resolucion_dudas_fase2_log.md | 2026-08-25 | mueve | — |
| 50_documentacion/andamios/logs/20260826_auditoria_y_cierre_v3_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260826_auditoria_y_cierre_v3_log.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/logs/20260826_avance_maquina_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260826_avance_maquina_log.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/logs/20260826_avance_maquina_v2_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260826_avance_maquina_v2_log.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/logs/20260826_correcciones_v4_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260826_correcciones_v4_log.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/logs/20260826_endurecimiento_v5_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260826_endurecimiento_v5_log.md | 2026-08-27 | mueve | — |
| 50_documentacion/andamios/logs/20260826_fixes_remision_grupo_acto_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260826_fixes_remision_grupo_acto_log.md | 2026-08-26 | mueve | — |
| 50_documentacion/andamios/logs/20260827_cierre_calidad_v7_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260827_cierre_calidad_v7_log.md | 2026-08-27 | mueve | — |
| 50_documentacion/andamios/logs/20260827_ensayo_general_v6_log.md | 50_documentacion/encargos/historico/202608/andamios/logs/20260827_ensayo_general_v6_log.md | 2026-08-27 | mueve | — |
| 50_documentacion/andamios/logs/20260904_alcance_motor_busqueda_v9_log.md | 50_documentacion/encargos/historico/202609/andamios/logs/20260904_alcance_motor_busqueda_v9_log.md | 2026-09-05 | mueve | — |
| 50_documentacion/andamios/logs/20260908_correcciones_visibles_v10_log.md | 50_documentacion/encargos/historico/202609/andamios/logs/20260908_correcciones_visibles_v10_log.md | 2026-09-08 | mueve | — |
| 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md | 50_documentacion/encargos/historico/202609/andamios/logs/20260909_indice_y_expansion_v11_log.md | 2026-09-10 | mueve | — |
