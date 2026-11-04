import SwiftUI
import SharedLogic

struct TareasView: View {

    let repositorio: TareasRepositorio = TareasEnMemoria()

    @State private var tareas: [Tarea] = []
    @State private var nuevaTarea: String = ""

    var body: some View {
        VStack(spacing: 16) {

            HStack {
                TextField("Escribe una nueva tarea", text: $nuevaTarea)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        agregarTarea()
                    }

                Button("Agregar") {
                    agregarTarea()
                }
                .disabled(nuevaTarea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()

            List(tareas, id: \.id) { tarea in
                Text(tarea.titulo)
            }
        }
        .background(Color.cyan.opacity(0.1))
    }

    private func agregarTarea() {
        let titulo = nuevaTarea.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !titulo.isEmpty else { return }

        _ = repositorio.agregar(titulo: titulo)
        tareas = repositorio.obtenerTodas()

        nuevaTarea = ""
    }
}

struct TareasView_Previews: PreviewProvider {
    static var previews: some View {
        TareasView()
    }
}
