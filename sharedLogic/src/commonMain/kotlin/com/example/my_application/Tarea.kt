package com.example.my_application

data class Tarea(
    val id: String,
    val titulo: String,
    val completada: Boolean = false
)

interface TareasRepositorio {
    fun obtenerTodas(): List<Tarea>
    fun agregar(titulo: String): Tarea
}

class TareasEnMemoria: TareasRepositorio{
    private val tareas = mutableListOf<Tarea>()
    override fun obtenerTodas(): List<Tarea> = tareas.toList()

    override fun agregar(titulo: String): Tarea {
        val nueva = Tarea(id = "${tareas.size + 1}", titulo = titulo)
        tareas.add(nueva)
        return  nueva
    }

}
