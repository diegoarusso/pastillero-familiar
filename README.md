# Pastillero Familiar

Una app de seguimiento de medicación y fiebre para toda la familia. La construí para un problema que teníamos en casa todos los días, y hoy la usamos a diario.

**▶️ Probala acá: [pastillero-familiar.netlify.app?demo=1](https://pastillero-familiar.netlify.app/?demo=1)**
*(modo demo con una familia y datos ficticios — nada de lo que toques afecta datos reales)*

---

## El problema

Empezó simple: llevar la cuenta de qué toma cada uno y a qué hora. Pero el uso real la llevó a otro lado.

Cuando mi hijo de 5 años entra en un cuadro febril, el cuidado se vuelve un problema de precisión bajo presión:

- Hay que respetar una ventana de horas entre tomas del antipirético. **A las 3 de la mañana, medio dormido, ese cálculo se hace mal.**
- Si la fiebre no cede, se puede dar un antipirético intermedio — pero a mitad de la ventana del anterior. Otro cálculo, en el peor momento.
- Cuando fuimos a la guardia, la médica preguntó *cómo venía la tendencia*. La respuesta estaba en nuestra memoria, no en ningún lado.
- Y el que cuida no siempre es el mismo: si mi señora le da una dosis a la madrugada, yo tengo que saberlo cuando me despierto.

## Qué hace

**Seguimiento diario**
- Agenda por persona, con múltiples horarios y frecuencias (diaria, días específicos, cada N días)
- Registro retroactivo: si te olvidaste de marcar una toma ayer, navegás al día y la marcás
- Control de stock con aviso de reposición
- Racha y % de adherencia, para que la constancia tenga algún refuerzo

**Modo Fiebre** — se activa cuando alguien está cursando un cuadro y concentra todo en una pantalla:
- **Reloj de próxima dosis**: cuenta regresiva en vivo hasta cuándo se puede volver a dar el antipirético
- **Guía de alternancia**: si la fiebre no cede, avisa la franja en la que se puede dar el intermedio
- **Gráfico de tendencia**: la curva de temperatura con marcas de cada dosis, exportable como imagen para mostrarle al pediatra
- **Línea de tiempo unificada**: fiebre y medicación juntas, en orden, sin tener que entrar a ningún lado
- Todo sincronizado entre los teléfonos de la familia

## Decisiones que valen la pena contar

**El error peligroso tiene una sola dirección.** Habilitar una dosis *antes de tiempo* puede sobredosificar a un chico; esperar de más solo molesta. Todo el cálculo se diseñó para errar hacia el lado seguro:

- Nunca muestra un "ya podés" a secas: siempre con la última toma, el intervalo y el horario habilitado a la vista, para que un adulto medio dormido pueda contrastar con la realidad.
- La ventana **depende de la dosis**, no solo de la droga: 400 mg y 600 mg de ibuprofeno no se renuevan igual.
- La cuenta regresiva se recalcula contra el reloj real en cada tick y al despertar la pantalla — los timers de JavaScript se suspenden con el teléfono bloqueado, y esa diferencia importa justo a las 4 AM.
- Cuando dos indicadores pueden contradecirse, gana el más conservador y el otro se oculta.
- La app no diagnostica: describe lo que se registró. La interpretación clínica es del pediatra, y eso está escrito en pantalla.

## Cómo está hecho

- **Frontend**: un único `index.html` — JavaScript vanilla, sin build ni framework. Tailwind por CDN.
- **Backend**: Supabase (Postgres) para que los datos sincronicen entre dispositivos.
- **Deploy**: Netlify, con despliegue automático desde este repo.
- **Gráficos**: SVG generado a mano, sin librerías.

Se puede abrir el archivo y entender todo de arriba a abajo. Para una app que tiene que funcionar a las 3 de la mañana, esa simplicidad es una decisión, no una limitación.

## Modo demo

`?demo=1` levanta una familia ficticia con un episodio febril en curso, usando un cliente de datos en memoria que reemplaza a la base. Sirve para mostrar la app sin exponer ni tocar datos de salud reales. Cada recarga vuelve a un estado limpio.

---

*Construida con Claude Code, iterando sobre necesidades que aparecieron usándola de verdad.*
