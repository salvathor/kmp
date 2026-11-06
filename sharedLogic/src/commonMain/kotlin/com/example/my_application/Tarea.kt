package com.example.my_application

data class Tarea(
    val id: String,
    val titulo: String,
    val completada: Boolean = false
)

interface TareasRepositorio {
    fun obtenerTodas(): List<Tarea>
    fun agregar(titulo: String): Tarea
    fun alternarCompletada(id: String): Tarea?
}

class TareasEnMemoria: TareasRepositorio{
    private val tareas = mutableListOf<Tarea>()
    override fun obtenerTodas(): List<Tarea> = tareas.toList()

    override fun agregar(titulo: String): Tarea {
        val nueva = Tarea(id = "${tareas.size + 1}", titulo = titulo)
        tareas.add(nueva)
        return  nueva
    }

    // Invierte el estado `completada` de la tarea con el id dado; regresa null si no existe.
    override fun alternarCompletada(id: String): Tarea? {
        val indice = tareas.indexOfFirst { it.id == id }
        if (indice == -1) return null
        val actualizada = tareas[indice].copy(completada = !tareas[indice].completada)
        tareas[indice] = actualizada
        return actualizada
    }
}
