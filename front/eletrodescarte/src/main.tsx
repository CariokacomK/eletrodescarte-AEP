import React from 'react'
import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import './global.css'

import { Home } from './pages/Home'
import { Login } from './pages/Login'
import { Cadastro } from './pages/Cadastro'
import { PontosDeColeta } from './pages/PontosDeColeta'
import { Educativo } from './pages/Educativo'
import { MeusIndicadores } from './pages/MeusIndicadores'
import App from './App'
import { AuthProvider } from './context/AuthContext'

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      {
        path: "/",
        element: <Home />,
      },
      {
        path: "/login",
        element: <Login />,
      },
      {
        path: "/cadastrar",
        element: <Cadastro />,
      },
      {
        path: "/pontos-de-coleta",
        element: <PontosDeColeta />,
      },
      {
        path: "/educativo",
        element: <Educativo />,
      },
      {
        path: "/meus-indicadores",
        element: <MeusIndicadores />,
      },
    ]
  }
]);

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AuthProvider>
      <RouterProvider router={router} />
    </AuthProvider>
  </React.StrictMode>,
)