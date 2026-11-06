import SwiftUI
// SharedLogic es el framework generado por el módulo `sharedLogic` del proyecto
// Kotlin Multiplatform (KMP). Ahí viven el modelo `Tarea`, la interfaz
// `TareasRepositorio` y su implementación `TareasEnMemoria`, escritos en Kotlin
// (sharedLogic/src/commonMain) y compartidos entre Android e iOS.
//
// Dependencia: esta app de iOS depende del módulo `sharedLogic`. El framework
// (baseName = "SharedLogic", estático) se compila desde Gradle mediante la fase
// "Run Script" del target, que ejecuta:
//     ./gradlew :sharedLogic:embedAndSignAppleFrameworkForXcode
// Por eso, cualquier cambio en el código Kotlin se refleja al volver a compilar en Xcode.
import SharedLogic

/// Pantalla principal: permite capturar nuevas tareas y mostrarlas en una lista.
/// Toda la lógica de datos se delega al repositorio compartido de KMP.
struct TareasView: View {

    /// Repositorio definido en Kotlin (SharedLogic). Swift lo ve como un protocolo
    /// y una clase normales gracias a la interoperabilidad de Kotlin/Native.
    let repositorio: TareasRepositorio = TareasEnMemoria()

    /// Copia local de las tareas para que SwiftUI pueda redibujar la lista.
    @State private var tareas: [Tarea] = []
    /// Texto que el usuario está escribiendo en el campo de nueva tarea.
    @State private var nuevaTarea: String = ""

    /// Indica si el texto actual es válido (no vacío tras quitar espacios).
    private var puedeAgregar: Bool {
        !nuevaTarea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        // Contenedor vertical; `spacing` separa 16 pt cada sección.
        VStack(spacing: 16) {

            // MARK: - Captura de nueva tarea
            // Fila horizontal con el campo de texto y el botón, separados 12 pt.
            HStack(spacing: 12) {
                TextField("Escribe una nueva tarea", text: $nuevaTarea)
                    // Espacio interno para que el texto no quede pegado al borde.
                    .padding(12)
                    // Fondo del sistema (claro/oscuro) con esquinas redondeadas.
                    .background(.background, in: RoundedRectangle(cornerRadius: 12))
                    // Borde sutil en gris neutro en lugar de un borde grueso.
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    // Sombra ligera para dar sensación de profundidad.
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    // Inclina ligeramente el campo (con su fondo, borde y sombra) 3 grados.
                    .rotationEffect(.degrees(3))
                    // Cambia la tecla de retorno del teclado a "Listo".
                    .submitLabel(.done)
                    // Al presionar retorno en el teclado se agrega la tarea.
                    .onSubmit {
                        agregarTarea()
                    }

                Button("Agregar") {
                    agregarTarea()
                }
                // Botón relleno con el color de tinte (estilo destacado).
                .buttonStyle(.borderedProminent)
                // Forma de cápsula (extremos completamente redondeados).
                .buttonBorderShape(.capsule)
                // Tinte gris oscuro neutro; mantiene buen contraste con el texto blanco en claro y oscuro.
                .tint(Color(.darkGray))
                // Texto del botón en semi-negritas.
                .fontWeight(.semibold)
                // Desactiva el botón mientras el campo esté vacío.
                .disabled(!puedeAgregar)
            }
            // Margen a los lados y arriba de la fila de captura.
            .padding(.horizontal)
            .padding(.top)

            // MARK: - Encabezado de la lista
            Label("Lista de tareas", systemImage: "checklist")
                // Tipografía de título, en negritas y adaptable a Dynamic Type.
                .font(.title2.bold())
                // Color principal del sistema para el texto y el ícono (se adapta a claro/oscuro).
                .foregroundStyle(.primary)
                // Ocupa todo el ancho y alinea el contenido a la izquierda.
                .frame(maxWidth: .infinity, alignment: .leading)
                // Margen lateral para alinearse con la fila de captura.
                .padding(.horizontal)

            // MARK: - Lista de tareas (datos provenientes de SharedLogic)
            List(tareas, id: \.id) { tarea in
                // Toda la fila funciona como checkbox: al tocarla se alterna `completada`.
                Button {
                    alternarCompletada(tarea)
                } label: {
                    HStack(spacing: 12) {
                        // SwiftUI no tiene checkbox nativo en iOS, así que se simula con SF Symbols.
                        Image(systemName: tarea.completada ? "checkmark.square.fill" : "square")
                            // Tamaño del ícono acorde al texto.
                            .font(.title3)
                            // Color principal cuando está marcada, gris cuando no.
                            .foregroundStyle(tarea.completada ? .primary : .secondary)
                            // Anima el cambio entre los dos íconos.
                            .contentTransition(.symbolEffect(.replace))

                        Text(tarea.titulo)
                            // Tipografía estándar para el cuerpo del texto.
                            .font(.body)
                            // Tacha el texto cuando la tarea está completada.
                            .strikethrough(tarea.completada)
                            // Atenúa el texto de las tareas completadas.
                            .foregroundStyle(tarea.completada ? .secondary : .primary)
                    }
                    // Un poco más de aire arriba y abajo de cada fila.
                    .padding(.vertical, 4)
                }
                // Quita el estilo de botón por defecto para que la fila se vea como texto normal.
                .buttonStyle(.plain)
                // VoiceOver anuncia la fila como seleccionada cuando la tarea está completada.
                .accessibilityAddTraits(tarea.completada ? .isSelected : [])
            }
            // Estilo de lista con filas agrupadas y márgenes redondeados.
            .listStyle(.insetGrouped)
            // Oculta el fondo por defecto de la lista para que se vea el degradado.
            .scrollContentBackground(.hidden)
        }
        // Fondo con un degradado gris muy suave que ocupa toda la pantalla.
        .background(
            LinearGradient(
                colors: [Color.gray.opacity(0.12), Color.gray.opacity(0.04)],
                startPoint: .top,
                endPoint: .bottom
            )
            // Extiende el degradado detrás de las áreas seguras (notch, barra inferior).
            .ignoresSafeArea()
        )
    }

    /// Agrega una tarea usando el repositorio de KMP y refresca la lista local.
    private func agregarTarea() {
        let titulo = nuevaTarea.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !titulo.isEmpty else { return }

        // `agregar` y `obtenerTodas` están implementadas en Kotlin (TareasEnMemoria).
        _ = repositorio.agregar(titulo: titulo)
        tareas = repositorio.obtenerTodas()

        nuevaTarea = ""
    }

    /// Marca o desmarca una tarea usando el repositorio de KMP y refresca la lista local.
    private func alternarCompletada(_ tarea: Tarea) {
        // `alternarCompletada` está implementada en Kotlin (TareasEnMemoria).
        _ = repositorio.alternarCompletada(id: tarea.id)
        withAnimation {
            tareas = repositorio.obtenerTodas()
        }
    }
}


// PREVISUALIZA TareasView
struct TareasView_Previews: PreviewProvider {
    static var previews: some View {
        TareasView()
    }
}
