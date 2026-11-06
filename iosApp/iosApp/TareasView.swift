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
        VStack(spacing: 16) {

            // MARK: - Captura de nueva tarea
            HStack(spacing: 12) {
                TextField("Escribe una nueva tarea", text: $nuevaTarea)
                    .padding(12)
                    .background(.background, in: RoundedRectangle(cornerRadius: 12))
                    // Borde sutil con el color de acento en lugar de un borde grueso.
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .submitLabel(.done)
                    .onSubmit {
                        agregarTarea()
                    }

                Button("Agregar") {
                    agregarTarea()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.blue)
                .fontWeight(.semibold)
                .disabled(!puedeAgregar)
            }
            .padding(.horizontal)
            .padding(.top)

            // MARK: - Encabezado de la lista
            Label("Lista de tareas", systemImage: "42.circle")
                .font(.title2.bold())
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            // MARK: - Lista de tareas (datos provenientes de SharedLogic)
            List(tareas, id: \.id) { tarea in
                Text(tarea.titulo)
                    .font(.body)
                    .padding(.vertical, 4)
            }
            .listStyle(.insetGrouped)
            // Oculta el fondo por defecto de la lista para que se vea el degradado.
            .scrollContentBackground(.hidden)
        }
        // Fondo con un degradado suave que ocupa toda la pantalla.
        .background(
            LinearGradient(
                colors: [Color.cyan.opacity(0.15), Color.blue.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
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
}


// PREVISUALIZA TareasView
struct TareasView_Previews: PreviewProvider {
    static var previews: some View {
        TareasView()
    }
}
