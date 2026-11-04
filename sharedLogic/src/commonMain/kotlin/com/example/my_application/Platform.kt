package com.example.my_application

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform