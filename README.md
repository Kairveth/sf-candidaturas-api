# sf-candidaturas-api

API y automatizaciones en Salesforce para gestionar candidaturas de empleo: entrada por REST, control de estados, notificación a un destino externo, retención RGPD y una vista de estado en el registro.

Proyecto de portfolio sobre una Developer Edition. Los tickets (DEMO-100X) son ficticios y sirven para organizar el trabajo por ramas y PR.

## Qué incluye

| Pieza | Qué hace |
|---|---|
| `CandidaturaRest` | Endpoint `POST /services/apexrest/candidaturas`. Crea o actualiza por `IdExterno__c`. Responde 201, 200, 400, 403, 409 o 500. |
| `CandidaturaService` | Comprueba permisos de escritura, mapea el payload, hace el upsert y traduce los errores de transición. |
| `CandidaturaTrigger` + `CandidaturaTriggerHandler` | Valida transiciones de estado en `before update`. Encola la notificación en `after update`. |
| `CandidaturaNotificacionQueueable` | Envía `idExterno` y `estado` de las candidaturas que pasan a `Entrevista`, en un solo callout por lote. Marca `EstadoEnvio__c = Enviado` si el destino responde 2xx. |
| `CandidaturaReintentoFinalizer` | Reencola una vez si el job falla. Un segundo fallo marca las candidaturas como `Fallido` y guarda el error en `UltimoErrorEnvio__c`. |
| `CandidaturaRetencionBatch` | Batch RGPD: anonimiza (renombra) las candidaturas cuya `FechaDescarte__c` ya venció. |
| `CandidaturaEstadoController` + LWC `candidaturaEstado` | Botones de transición en la ficha, solo con las transiciones permitidas. |
| `postman/candidaturas.postman_collection.json` | 9 peticiones que prueban el CRUD y las respuestas de error. |

## Decisiones

**API REST propia frente a la API estándar.** La API estándar sirve para CRUD genérico. Aquí hace falta un contrato con idempotencia por `idExterno`, códigos HTTP concretos (400, 403, 409) y validación de transiciones. Con la API estándar, esa lógica tendría que vivir en el sistema que llama.

**Lógica de transiciones en el trigger, no en el endpoint.** Así la regla se aplica tanto a la API como a la ficha, a la edición manual y a cualquier otro origen. El trigger solo delega en el handler.

**Validación en `before update`, notificación en `after update`.** La validación cambia el mismo registro y no hace DML. La notificación necesita el registro ya guardado y no hace callouts desde el trigger.

**Un callout por lote, no por registro.** El trigger recoge todos los IDs de la transacción y encola un único Queueable. Con 200 registros, son 200 filas en el payload y una petición.

**Datos enviados al destino.** Solo se envían `idExterno` y `estado`. El nombre de la candidatura no sale de Salesforce porque el destino no lo usa (confirmado el 30/10/2026).

**Registro del envío.** `EstadoEnvio__c` pasa a `Enviado` tras una respuesta 2xx y a `Fallido` tras el segundo fallo, con el último error en `UltimoErrorEnvio__c`. Si el destino acepta el lote pero falla el marcado de `Enviado`, el error se registra en el debug log y no se reenvía: el destino no recibe el lote dos veces. Esas candidaturas quedan en `Pendiente` hasta que se revisen a mano.

**Reintento con Finalizer, no con Schedulable.** El reintento depende del resultado del job, no de un calendario. Un Schedulable añadiría complejidad sin beneficio. El reintento sigue siendo inmediato: un espera antes del segundo intento está pendiente de decidir.

**Batch solo para retención.** Es el único proceso que recorre todos los registros elegibles en bloques con estado. El resto va en Queueable.

**Permisos.** El endpoint REST comprueba `isCreateable()` e `isUpdateable()` del objeto y de los campos que llegan en el payload antes de escribir. Si falta permiso, responde 403 sin crear ni modificar nada. El controlador de la ficha valida acceso con `isUpdateable()` y `WITH USER_MODE`. Las clases usan `with sharing`.

**Sin credenciales en el repo.** El destino y su autenticación viven en Named Credential y External Credential de la org.

## Cómo probarlo

1. Desplegar en una Developer Edition propia:

   ```
   sf project deploy start --source-dir force-app --target-org <tu-org>
   ```

2. En Setup, crear la External Credential `Destino_Candidaturas` (No Authentication, principal `Anonimo`) y la Named Credential `Destino_Candidaturas` apuntando a tu URL de destino. Sin ellas, el Queueable falla en la org nueva. La URL no va en el repo.
3. En Lightning App Builder, asignar la página `Candidatura_Record_Page1` a `Candidatura__c`. El deploy no la activa.
4. Importar `postman/candidaturas.postman_collection.json` y configurar `client_id`, `client_secret` y `base_url` en el entorno.
5. Ejecutar las peticiones en orden: Login, crear, reenviar misma clave, sin clave, buscar, actualizar estado, transición inválida, borrar, leer tras borrar.
6. Abrir una candidatura en la org y probar los botones del componente de estado y la sección de envío.
7. Para la retención RGPD, ejecutar en Developer Console (Anonymous Apex): `Database.executeBatch(new CandidaturaRetencionBatch());`. Confirmar antes que el constructor no pide parámetros.

## Límites y escalado

Volumen supuesto, sin dato real: 1.000 candidaturas al día, con lotes de hasta 200 registros por transacción.

- **Hoy:** un job por transacción de trigger. No verificado: que aguante lotes de cientos de registros sin problemas.
- **10 veces más (10.000 al día):** partir el lote en bloques de 100 dentro del Queueable o encolar varios jobs desde el trigger.
- **Más de 1 millón de registros:** pasar la notificación a Batch con estado y revisar índices en `Estado__c` e `IdExterno__c`.
- **Destino:** si el endpoint externo cae, el reintento cubre un fallo. Para más, hace falta una cola propia o Platform Events.

No verificado: los límites de gobernador del job con 10.000 registros en una sola transacción.

## Estado

- Desplegado y probado en Developer Edition con dry run y deploy real.
- Pendiente: decidir si el reintento espera antes del segundo intento.
- Pendiente: test del flujo completo del Finalizer (la lógica de marcado sí tiene test).

## Aviso

Los tickets DEMO-100X son ficticios. El proyecto no tiene datos reales de personas.