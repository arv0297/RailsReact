import "./controllers"
import React from "react"
import { createRoot } from "react-dom/client"

document.addEventListener("DOMContentLoaded", () => {
    const el = document.getElementById("root")
    if (el) createRoot(el).render(<div>Hello from React</div>)
})